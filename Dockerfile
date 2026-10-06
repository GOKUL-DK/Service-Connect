# ========================================================
# Stage 1: Build War with Maven and OpenJDK 21
# ========================================================
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

WORKDIR /build

# Copy Maven POM and dependency descriptors
COPY pom.xml .

# Download dependencies (cached layer)
RUN mvn dependency:go-offline -B || true

# Copy project source code
COPY src ./src

# Package WAR file (skipping Selenium tests during container build)
RUN mvn clean package -DskipTests

# ========================================================
# Stage 2: Runtime with Apache Tomcat 10.1 (Jakarta EE 10)
# ========================================================
FROM tomcat:10.1-jdk21-temurin

WORKDIR /usr/local/tomcat

# Clean default Tomcat sample apps
RUN rm -rf webapps/*

# Deploy ServiceConnect as ROOT application (serves on / directly)
COPY --from=builder /build/target/ServiceConnect.war webapps/ROOT.war

# Also keep context alias ServiceConnect.war for legacy route compatibility
COPY --from=builder /build/target/ServiceConnect.war webapps/ServiceConnect.war

# Copy container entrypoint script for dynamic cloud port binding ($PORT)
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i -e 's/\r$//' /usr/local/bin/docker-entrypoint.sh && chmod +x /usr/local/bin/docker-entrypoint.sh

# Default HTTP port
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
