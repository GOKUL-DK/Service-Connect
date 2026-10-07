package com.serviceconnect.filter;

import com.serviceconnect.util.AuthTokenUtil;
import com.serviceconnect.util.CookieUtil;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

/**
 * Filter that automatically restores user session attributes from cryptographically verified cookies
 * if Tomcat's in-memory session is lost (e.g. across serverless restarts on Vercel or container reboots).
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest) {
            HttpServletRequest req = (HttpServletRequest) request;

            // Skip static asset requests
            String path = req.getRequestURI();
            if (path != null && (path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".png")
                    || path.endsWith(".jpg") || path.endsWith(".svg") || path.endsWith(".ico")
                    || path.endsWith(".woff") || path.endsWith(".woff2") || path.endsWith(".ttf"))) {
                chain.doFilter(request, response);
                return;
            }

            HttpSession session = req.getSession(true);

            // If session was lost across serverless function instances / container restarts
            if (session.getAttribute("userId") == null) {
                String uid = CookieUtil.getCookieValue(req, "sc_user_id");
                String role = CookieUtil.getCookieValue(req, "sc_role");
                String username = CookieUtil.getCookieValue(req, "sc_username");
                String name = CookieUtil.getCookieValue(req, "sc_name");
                String providerId = CookieUtil.getCookieValue(req, "sc_provider_id");
                String sig = CookieUtil.getCookieValue(req, "sc_sig");

                if (uid != null && role != null && !uid.trim().isEmpty() && sig != null) {
                    String dataToVerify = uid.trim() + "|" + role.trim() + "|"
                            + (username != null ? username.trim() : "") + "|"
                            + (providerId != null ? providerId.trim() : "0");

                    if (AuthTokenUtil.verify(dataToVerify, sig)) {
                        try {
                            session.setAttribute("userId", Integer.parseInt(uid.trim()));
                            session.setAttribute("role", role.trim());
                            if (username != null) {
                                session.setAttribute("username", username.trim());
                            }
                            if (name != null && !name.trim().isEmpty()) {
                                session.setAttribute("name", URLDecoder.decode(name.trim(), StandardCharsets.UTF_8));
                            } else if (username != null) {
                                session.setAttribute("name", username.trim());
                            } else {
                                session.setAttribute("name", "User");
                            }
                            if (providerId != null && !providerId.trim().isEmpty()) {
                                session.setAttribute("providerId", Integer.parseInt(providerId.trim()));
                            }
                        } catch (Exception ignored) {
                        }
                    }
                }
            }
        }
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
