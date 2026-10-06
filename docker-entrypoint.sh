#!/bin/sh
set -e

# If the PORT environment variable is set by the cloud platform (Render, Railway, etc.),
# dynamically update Tomcat's server.xml HTTP connector port
if [ -n "$PORT" ] && [ "$PORT" != "8080" ]; then
    echo "[ServiceConnect] Configuring Tomcat to listen on cloud port: $PORT"
    sed -i "s/port=\"8080\"/port=\"$PORT\"/g" /usr/local/tomcat/conf/server.xml
fi

exec "$@"
