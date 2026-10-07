package com.serviceconnect.util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Utility helper class for creating, reading, and clearing HTTP cookies.
 * Supports cross-request persistence and modern browser security headers (SameSite=Lax, HttpOnly).
 */
public class CookieUtil {

    private static final int DEFAULT_COOKIE_MAX_AGE = 7 * 24 * 60 * 60; // 7 days in seconds

    /**
     * Adds or updates a cookie in the HTTP response.
     */
    public static void setCookie(HttpServletResponse response, String name, String value, int maxAge) {
        setCookie(response, name, value, maxAge, false);
    }

    /**
     * Adds or updates a cookie with customizable httpOnly attribute.
     */
    public static void setCookie(HttpServletResponse response, String name, String value, int maxAge, boolean httpOnly) {
        Cookie cookie = new Cookie(name, value);
        cookie.setPath("/");
        cookie.setMaxAge(maxAge);
        cookie.setHttpOnly(httpOnly);
        try {
            cookie.setAttribute("SameSite", "Lax");
        } catch (Throwable ignored) {}
        response.addCookie(cookie);
    }

    /**
     * Adds a cookie with default 7-day expiration.
     */
    public static void setCookie(HttpServletResponse response, String name, String value) {
        setCookie(response, name, value, DEFAULT_COOKIE_MAX_AGE, false);
    }

    /**
     * Retrieves the value of a cookie by name from the HTTP request.
     */
    public static String getCookieValue(HttpServletRequest request, String name) {
        if (request == null || name == null) return null;
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (name.equals(cookie.getName())) {
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
        if (response == null || name == null) return;
        Cookie cookie = new Cookie(name, "");
        cookie.setPath("/");
        cookie.setMaxAge(0);
        try {
            cookie.setAttribute("SameSite", "Lax");
        } catch (Throwable ignored) {}
        response.addCookie(cookie);
    }
}
