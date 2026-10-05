package com.serviceconnect.util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Utility helper class for creating, reading, and clearing HTTP cookies.
 * Used for remembering usernames and preferred search criteria.
 */
public class CookieUtil {

    private static final int DEFAULT_COOKIE_MAX_AGE = 7 * 24 * 60 * 60; // 7 days in seconds

    /**
     * Adds or updates a cookie in the HTTP response.
     */
    public static void setCookie(HttpServletResponse response, String name, String value, int maxAge) {
        Cookie cookie = new Cookie(name, value);
        cookie.setPath("/");
        cookie.setMaxAge(maxAge);
        cookie.setHttpOnly(false); // Accessible to client scripts if needed
        response.addCookie(cookie);
    }

    /**
     * Adds a cookie with the default 7-day expiration.
     */
    public static void setCookie(HttpServletResponse response, String name, String value) {
        setCookie(response, name, value, DEFAULT_COOKIE_MAX_AGE);
    }

    /**
     * Retrieves the value of a cookie by name from the HTTP request.
     */
    public static String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals(name)) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }

    /**
     * Deletes a cookie by setting its max age to 0.
     */
    public static void deleteCookie(HttpServletResponse response, String name) {
        Cookie cookie = new Cookie(name, "");
        cookie.setPath("/");
        cookie.setMaxAge(0);
        response.addCookie(cookie);
    }
}
