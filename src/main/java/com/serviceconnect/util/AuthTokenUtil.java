package com.serviceconnect.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;

/**
 * Utility for cryptographically signing and verifying session auth tokens.
 * Guarantees stateless authentication resilience across serverless containers / restarts
 * while preventing tampering with user ID or roles.
 */
public class AuthTokenUtil {

    private static final String HMAC_SHA256 = "HmacSHA256";
    private static final String SECRET_KEY;

    static {
        String envSecret = System.getenv("APP_SECRET");
        if (envSecret != null && !envSecret.trim().isEmpty()) {
            SECRET_KEY = envSecret.trim();
        } else {
            // Default application secret for consistent hashing across containers
            SECRET_KEY = "ServiceConnect-Auth-Secret-Key-2026-Lab!";
        }
    }

    /**
     * Signs data using HMAC-SHA256.
     * @param data The payload string (e.g. "userId|role|username|providerId")
     * @return Hex-encoded signature string
     */
    public static String sign(String data) {
        if (data == null) return "";
        try {
            Mac mac = Mac.getInstance(HMAC_SHA256);
            SecretKeySpec keySpec = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), HMAC_SHA256);
            mac.init(keySpec);
            byte[] hmacBytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hmacBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    /**
     * Verifies that the provided signature matches the payload.
     * @param data The payload string
     * @param signature The hex-encoded signature to verify
     * @return true if signature is valid, false otherwise
     */
    public static boolean verify(String data, String signature) {
        if (data == null || signature == null || signature.trim().isEmpty()) {
            return false;
        }
        String expected = sign(data);
        return expected.equalsIgnoreCase(signature.trim());
    }
}
