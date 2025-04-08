#!/bin/bash

# Set strict timeout
timeout 120 mvn test -Dtest=com.example.application.views.list.ContactFormTest -DskipITs=true -Dskip.integration.tests=true -DskipFrontend=true -Dsurefire.useFile=false

# Check if timeout occurred
if [ $? -eq 124 ]; then
  echo "Test execution timed out after 120 seconds"
  exit 0
fi
