# ---------------- Build Stage ----------------
    FROM eclipse-temurin:17-jdk AS builder

    WORKDIR /app
    
    # Copy only files needed for dependency resolution first (better caching)
    COPY mvnw .
    COPY .mvn .mvn
    COPY pom.xml .
    
    # Pre-download dependencies to leverage Docker cache
    RUN ./mvnw dependency:go-offline
    
    # Copy rest of the code
    COPY . .
    
    # Package the application, skipping tests
    RUN ./mvnw clean package -DskipTests
    
    # ---------------- Runtime Stage ----------------
    FROM eclipse-temurin:17-jre
    
    WORKDIR /app
    
    # Use non-root user for better security
    RUN useradd -m appuser
    USER appuser
    
    # Copy jar file from build stage
    COPY --from=builder /app/target/*.jar app.jar
    
    # Expose the default Spring Boot port
    EXPOSE 8080
    
    # Run the application
    ENTRYPOINT ["java", "-jar", "app.jar"]
    