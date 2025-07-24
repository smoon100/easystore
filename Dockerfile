# Stage 1: Build the application using Maven
# We use a specific version of Maven and JDK 21 to match your pom.xml
FROM maven:3.9-eclipse-temurin-21 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml and download dependencies first to leverage Docker's layer caching
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of your application's source code
COPY src ./src

# Package the application, skipping the tests for faster builds
# The resulting JAR will be in /app/target/
RUN mvn package -DskipTests

# Stage 2: Create the final, lightweight runtime image
# We use a JRE (Java Runtime Environment) image which is smaller than a full JDK
FROM eclipse-temurin:21-jre-jammy

# Set the working directory
WORKDIR /app

# Copy the executable JAR file from the build stage
# The artifactId and version are taken from your pom.xml
COPY --from=build /app/target/eazystore-0.0.1-SNAPSHOT.jar app.jar

# Expose the port the application will run on (default for Spring Boot is 8080)
EXPOSE 8080

# The command to run the application when the container starts
# Using the exec form ensures the Java process is PID 1 for proper signal handling
ENTRYPOINT ["java", "-jar", "app.jar"]