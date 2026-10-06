#!/bin/sh
set -e

# If the PORT environment variable is set by the cloud platform (Vercel, Render, Railway, etc.),
# dynamically update Tomcat's server.xml HTTP connector port
TARGET_PORT="${PORT:-8080}"

if [ "$TARGET_PORT" != "8080" ]; then
    echo "[ServiceConnect] Configuring Tomcat to listen on cloud port: $TARGET_PORT"
    sed -i "s/port=\"8080\"/port=\"$TARGET_PORT\"/g" /usr/local/tomcat/conf/server.xml
fi

exec "$@"
