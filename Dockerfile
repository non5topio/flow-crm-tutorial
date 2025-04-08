# ---------------- Base Stage ----------------
    FROM eclipse-temurin:17-jdk AS base
    ENV VAADIN_PRO_KEY=no
    ENV VAADIN_NPM_ENABLE_PNPM=true
    ENV DEBIAN_FRONTEND=noninteractive

    WORKDIR /app
    
    # Install Redis (optional, only if your tests need it)
    RUN apt-get update && apt-get install -y redis-server maven
    
    # Copy only files needed for dependency resolution first (better caching)
    COPY mvnw .
    COPY .mvn .mvn
    COPY pom.xml .
    
    # ✅ Ensure mvnw is executable
    RUN chmod +x ./mvnw
    
    # ✅ Optional: Debug versions (helps identify environment issues)
    RUN ./mvnw --version && java -version
    
    # Pre-download dependencies to leverage Docker cache
    RUN ./mvnw dependency:go-offline
    
    # Copy the rest of the project
    COPY . .
    
    # ---------------- Test Stage ----------------
    FROM base AS test

    ENV VAADIN_PRO_KEY=no
    ENV VAADIN_NPM_ENABLE_PNPM=true
    ENV DEBIAN_FRONTEND=noninteractive
    
    # Start Redis and run tests
    # ✅ Use CMD for container execution (Qodo will override if needed)
    CMD redis-server --daemonize yes && ./mvnw test
    
    # ---------------- Build Stage ----------------
    FROM base AS builder
    
    # ✅ Package the application, skipping tests
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
    