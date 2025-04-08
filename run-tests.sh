#!/bin/bash

# Set JVM options to limit memory usage and optimize for CI environment
export MAVEN_OPTS="-Xmx1024m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Run tests with specific settings
mvn -s settings.xml test -Dtest='!*E2E*' -DskipFrontend=true -Dsurefire.timeout=300
