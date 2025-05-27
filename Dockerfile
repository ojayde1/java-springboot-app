# --- Stage 1: Builder ---
# Use a Maven image with OpenJDK 8 for building and compiling a Java 8 app.
FROM maven:3-openjdk-8 AS builder

# Set the working directory inside the container for this stage.
WORKDIR /app

# Copy the Maven project files (pom.xml) first for build caching.
COPY pom.xml ./

## Copy the entire project source code.
# IMPORTANT: This must happen BEFORE any 'mvn' commands that compile or package.
COPY src ./src

# Build the application and package it into a JAR file.
# This single command will compile, run tests (if not skipped), and create the JAR.
# The JAR will be in /app/target/springboot-k8s-demo-0.0.1-SNAPSHOT.jar
RUN mvn clean package -Dmaven.test.skip=true

# --- Stage 2: Runner (Production Image) ---
FROM openjdk:8-jre-alpine

# Set environment variables for Java application.
ENV SPRING_PROFILES_ACTIVE=production
ENV JAVA_TOOL_OPTIONS="-XX:+ExitOnOutOfMemoryError"

# Default for Spring Boot is 8080.
EXPOSE 8080

# Set the working directory for the final image.
WORKDIR /app


# IMPORTANT: Replace 'springboot-k8s-demo-0.0.1-SNAPSHOT.jar' with your actual JAR filename.
# It's based on your <artifactId>-<version>.jar
COPY --from=builder /app/target/springboot-k8s-demo-0.0.1-SNAPSHOT.jar ./app.jar

# Define the command to run your Java application when the container starts.
CMD ["java", "-jar", "app.jar"]
