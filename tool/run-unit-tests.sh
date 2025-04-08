#!/bin/bash

# Set environment variables to optimize JVM for Docker
export MAVEN_OPTS="-Xmx1024m -XX:+TieredCompilation -XX:TieredStopAtLevel=1 -XX:+UseParallelGC -Djava.security.egd=file:/dev/./urandom"

# Run only the ContactFormTest with a timeout and skip frontend processing
mvn clean test -Dtest=ContactFormTest -DexcludedGroups=e2e,integration,slow -DskipFrontend=true -Dsurefire.timeout=300 -Dmaven.test.failure.ignore=true -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn -B
