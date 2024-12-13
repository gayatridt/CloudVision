# STAGE 1: Builder
FROM node:20-bullseye AS builder

ARG MB_EDITION=oss
ARG VERSION=latest

# Set working directory
WORKDIR /home/node

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    curl \
    git \
    build-essential \
    python3 \
    && curl -O https://download.clojure.org/install/linux-install-1.11.1.1262.sh \
    && chmod +x linux-install-1.11.1.1262.sh \
    && ./linux-install-1.11.1.1262.sh \
    && rm linux-install-1.11.1.1262.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME and add it to PATH
ENV JAVA_HOME=/opt/homebrew/opt/openjdk@17
ENV PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation
RUN java -version

# Verify Git version and repository status
RUN git --version
RUN git describe --tags || echo "Git describe failed, using default version"

# Copy project files into the container
COPY . .

# Verify project files are copied correctly
RUN ls -la /home/node

# Install frontend dependencies using Yarn
RUN yarn --frozen-lockfile

# Run the build script
RUN chmod +x bin/build.sh
RUN INTERACTIVE=false CI=true MB_EDITION=$MB_EDITION bin/build.sh :version ${VERSION}

# STAGE 2: Runner
FROM eclipse-temurin:17-jre AS runner

# Install necessary packages for runtime
RUN apt-get update && apt-get install -y \
    bash \
    fontconfig \
    curl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME and add it to PATH
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# Create a non-root user
RUN useradd -ms /bin/bash metabase

# Enable system CA certificates
ENV USE_SYSTEM_CA_CERTS=true

# Create directories with proper permissions
RUN mkdir -p /app/certs /app/metabase-data \
    && chown -R metabase:metabase /app

# Download and import certificates
RUN curl https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -o /app/certs/rds-combined-ca-bundle.pem \
    && curl https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem -o /app/certs/DigiCertGlobalRootG2.crt.pem \
    && keytool -noprompt -importcert -trustcacerts -alias aws-rds \
        -file /app/certs/rds-combined-ca-bundle.pem \
        -keystore $JAVA_HOME/lib/security/cacerts \
        -keypass changeit -storepass changeit \
    && keytool -noprompt -importcert -trustcacerts -alias azure-cert \
        -file /app/certs/DigiCertGlobalRootG2.crt.pem \
        -keystore $JAVA_HOME/lib/security/cacerts \
        -keypass changeit -storepass changeit

# Set environment variables for database configuration
ENV MB_DB_FILE=/app/metabase-data/metabase.db

ENV MB_DB_TYPE=postgres
ENV MB_DB_HOST=localhost
ENV MB_DB_PORT=5432
ENV MB_DB_DBNAME=test_db
ENV MB_DB_USER=your-username
ENV MB_DB_PASS=your-password

# Copy the built application from the builder stage
COPY --from=builder /home/node/target/uberjar/metabase.jar /app/

# Copy the custom entrypoint script
COPY bin/docker/run_metabase.sh /app/
RUN chmod +x /app/run_metabase.sh

# Configure volume for data persistence
VOLUME /app/metabase-data

# Expose port 3000
EXPOSE 3000

# Switch to non-root user
USER metabase

# Add health check
HEALTHCHECK --start-period=5m \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Set entrypoint
ENTRYPOINT ["/app/run_metabase.sh"]
