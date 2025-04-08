#!/bin/bash

# Set JVM options to limit memory usage and optimize for CI environment
export MAVEN_OPTS="-Xmx1024m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Run only the fastest test
mvn -s settings.xml test -Dtest=ContactFormTest -DskipFrontend=true -Dsurefire.timeout=300
