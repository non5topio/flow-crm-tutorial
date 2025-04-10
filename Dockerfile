    # # ---------------- Base Stage ----------------
    #     FROM eclipse-temurin:17-jdk AS base
    #     ENV VAADIN_PRO_KEY=no
    #     ENV VAADIN_NPM_ENABLE_PNPM=true
    #     ENV DEBIAN_FRONTEND=noninteractive
    #     ENV VAADIN_PRODUCTION_MODE=true

    #     RUN export DYNACONF_TESTS__MAX_ALLOWED_RUNTIEM_SECONDS=1800

    #     WORKDIR /app

    #     # Install Redis (optional, only if your tests need it)
    #     RUN apt-get update && apt-get install -y redis-server maven

    #     # Copy only files needed for dependency resolution first (better caching)
    #     COPY mvnw .
    #     COPY .mvn .mvn
    #     COPY pom.xml .

    #     # ✅ Ensure mvnw is executable
    #     RUN chmod +x ./mvnw

    #     # ✅ Optional: Debug versions (helps identify environment issues)
    #     RUN ./mvnw --version && java -version

    #     # Pre-download dependencies to leverage Docker cache
    #     RUN ./mvnw dependency:go-offline

    #     # Copy the rest of the project
    #     COPY . .

    #     # ---------------- Test Stage ----------------
    #     FROM base AS test

    #     ENV VAADIN_PRO_KEY=no
    #     ENV VAADIN_NPM_ENABLE_PNPM=true
    #     ENV DEBIAN_FRONTEND=noninteractive
    #     ENV VAADIN_PRODUCTION_MODE=true

    #     # Start Redis and run tests
    #     # ✅ Use CMD for container execution (Qodo will override if needed)
    #     CMD redis-server --daemonize yes && ./mvnw test

    #     # ---------------- Build Stage ----------------
    #     FROM base AS builder

    #     # ✅ Package the application, skipping tests
    #     RUN ./mvnw clean package -DskipTests

    #     # ---------------- Runtime Stage ----------------
    #     FROM eclipse-temurin:17-jre

    #     WORKDIR /app

    #     # Use non-root user for better security
    #     RUN useradd -m appuser
    #     USER appuser

    #     # Copy jar file from build stage
    #     COPY --from=builder /app/target/*.jar app.jar

    #     # Expose the default Spring Boot port
    #     EXPOSE 8080

    #     # Run the application
    #     ENTRYPOINT service redis-server start && "$@"
    #     ENTRYPOINT ["java", "-jar", "app.jar"]


# ---------------- Base Stage ----------------
    FROM eclipse-temurin:17-jdk AS base

    # --- Environment variables ---
    ENV DEBIAN_FRONTEND=noninteractive
    ENV VAADIN_PRODUCTION_MODE=true
    ENV VAADIN_PRO_KEY=no
    ENV VAADIN_NPM_ENABLE_PNPM=true
    # ENV DYNACONF_TESTS__MAX_ALLOWED_RUNTIEM_SECONDS=1800
    
    WORKDIR /app
    
    # --- Install required packages ---
    RUN apt-get update && apt-get install -y \
        redis-server \
        maven \
        curl \
        gnupg \
     && apt-get clean
    
    # --- Install Node.js and PNPM for Vaadin frontend builds ---
    RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
     && apt-get install -y nodejs \
     && npm install -g pnpm \
     && node -v && npm -v && pnpm -v
    
    # --- Copy files for dependency resolution ---
    COPY mvnw .
    COPY .mvn .mvn
    COPY pom.xml .
    
    # Make mvnw executable
    RUN chmod +x ./mvnw
    
    # --- Preload dependencies for Docker cache efficiency ---
    RUN ./mvnw dependency:go-offline
    
    # --- Copy full project source ---
    COPY . .
    
    # ---------------- Test Stage ----------------
    FROM base AS test
    
    ENV VAADIN_PRODUCTION_MODE=true
    ENV VAADIN_SKIP_DEVSERVER=true
    ENV DYNACONF_TESTS__MAX_ALLOWED_RUNTIEM_SECONDS=1800

    
    # --- Run Redis + Tests (skip E2E tests that need browser) ---
    CMD redis-server --daemonize yes && \
        ./mvnw test \
        -Dtest=\!*E2E* \
        -DskipFrontend=true \
        -Dvaadin.skip.devserver=true \
        -Dvaadin.productionMode=true
    
    # ---------------- Build Stage ----------------
    FROM base AS builder
    
    # --- Build application with frontend bundle (no tests) ---
    RUN ./mvnw clean package \
        -DskipTests \
        -DskipFrontend=false \
        -Dvaadin.skip.devserver=true \
        -Dvaadin.productionMode=true
    
    # ---------------- Runtime Stage ----------------
    FROM eclipse-temurin:17-jre
    
    WORKDIR /app
    
    # Use non-root user for better security
    RUN useradd -m appuser
    USER appuser
    
    # Copy final jar
    COPY --from=builder /app/target/*.jar app.jar
    
    EXPOSE 8080
    
    # --- Run the Spring Boot app ---
    ENTRYPOINT ["java", "-jar", "app.jar"]
















# # ---------------- Base Stage ----------------
#     FROM eclipse-temurin:17-jdk AS base

#     # --- Environment variables ---
#     ENV DEBIAN_FRONTEND=noninteractive
#     ENV VAADIN_PRODUCTION_MODE=true
#     ENV VAADIN_PRO_KEY=no
#     ENV VAADIN_NPM_ENABLE_PNPM=true
#     # ENV DYNACONF_TESTS__MAX_ALLOWED_RUNTIEM_SECONDS=1800
    
#     WORKDIR /app
    
#     # --- Install required packages ---
#     # Add Node.js (if not present)
#     RUN apt-get update && apt-get install -y curl gnupg \
#     && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
#     && apt-get install -y nodejs

#     RUN apt-get update && apt-get install -y \
#         redis-server \
#         maven \
#         curl \
#         gnupg \
#         python3 \
#         python3-pip \
#         python3-venv \
#      && apt-get clean
    
#     # --- Install Node.js and PNPM for Vaadin frontend builds ---
#     RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
#      && apt-get install -y nodejs \
#      && npm install -g pnpm \
#      && node -v && npm -v && pnpm -v
    
#     # --- Install Poetry (used by Qodo Cover) ---
#     RUN pip3 install --break-system-packages poetry
    
#     # --- Copy Qodo Cover Agent from local (now inside this directory) ---
#     COPY qodo-cover-private /qodo-cover
    
#     # --- Install Qodo Cover Agent ---
#     WORKDIR /qodo-cover

#     # Create virtual environment and install required tools
#     RUN python3 -m venv /opt/venv \
#     && /opt/venv/bin/pip install --upgrade pip \
#     && /opt/venv/bin/pip install poetry wandb tree_sitter diff-cover \
#     && /opt/venv/bin/poetry install    

#     # Switch back to app directory
#     WORKDIR /app
    
#     # --- Copy files for dependency resolution ---
#     COPY mvnw .
#     COPY .mvn .mvn
#     COPY pom.xml .
    
#     # Make mvnw executable
#     RUN chmod +x ./mvnw
    
#     # --- Preload dependencies for Docker cache efficiency ---
#     RUN ./mvnw dependency:go-offline
    
#     # --- Copy full project source ---
#     COPY . .
    
#     # ---------------- Test Stage ----------------
#     FROM base AS test
    
#     ENV VAADIN_PRODUCTION_MODE=true
#     ENV VAADIN_SKIP_DEVSERVER=true
#     ENV DYNACONF_TESTS__MAX_ALLOWED_RUNTIEM_SECONDS=1800
    
#     # --- Run Redis + Tests (skip E2E tests that need browser) ---
#     CMD redis-server --daemonize yes && \
#         ./mvnw test \
#         -Dtest=\!*E2E* \
#         -DskipFrontend=true \
#         -Dvaadin.skip.devserver=true \
#         -Dvaadin.productionMode=true
    
#     # ---------------- Coverage Evaluation Stage ----------------
#     FROM base AS cover
    
#     # Add this command as the main execution
#     CMD poetry run cover-agent \
#       --model "nvidia_nim/meta/llama-3.1-405b-instruct" \
#       --source-file-path="src/main/java/com/example/application/views/list/ContactForm.java" \
#       --test-file-path="src/test/java/com/example/application/views/list/ContactFormTest.java" \
#       --code-coverage-report-path="target/site/jacoco/jacoco.xml" \
#       --test-command="redis-server --daemonize yes && mvn test -Dtest='!*E2E*' -DskipFrontend=true -Dvaadin.skip.devserver=true -Dvaadin.productionMode=true" \
#       --test-command-dir="/app" \
#       --coverage-type="jacoco" \
#       --desired-coverage=100 \
#       --max-iterations=1
    
#     # ---------------- Build Stage ----------------
#     FROM base AS builder
    
#     # --- Build application with frontend bundle (no tests) ---
#     RUN ./mvnw clean package \
#         -DskipTests \
#         -DskipFrontend=false \
#         -Dvaadin.skip.devserver=true \
#         -Dvaadin.productionMode=true
    
#     # ---------------- Runtime Stage ----------------
#     FROM eclipse-temurin:17-jre
    
#     WORKDIR /app
    
#     # Use non-root user for better security
#     RUN useradd -m appuser
#     USER appuser
    
#     # Copy final jar
#     COPY --from=builder /app/target/*.jar app.jar
    
#     EXPOSE 8080
    
#     # --- Run the Spring Boot app ---
#     ENTRYPOINT ["java", "-jar", "app.jar", "--server.address=0.0.0.0"]

    