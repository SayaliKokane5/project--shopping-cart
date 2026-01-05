########################################
# Stage 1: Build the application (Maven)
########################################
FROM maven:3.9.6-eclipse-temurin-8 AS builder

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies (cache optimization)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy full source code
COPY src ./app

# Build WAR file
RUN mvn clean package -DskipTests

########################################
# Stage 2: Run the application (Tomcat)
########################################
FROM tomcat:9.0-jdk8

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from builder stage
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
