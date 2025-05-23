#!/bin/bash
set -e
set -o pipefail

# Log prefix
PREFIX="[Build Script]"

# Check requirements
if ! command -v git >/dev/null 2>&1; then
    echo "$PREFIX Error: git is required but not installed" >&2
    exit 1
fi

if ! command -v java >/dev/null 2>&1; then
    echo "$PREFIX Error: Java is required but not installed" >&2
    exit 1
fi

java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [ -z "$java_version" ] || [ "$java_version" -lt 21 ]; then
    echo "$PREFIX Error: Java 21 or later is required" >&2
    exit 1
fi

# Save the original directory
ORIGINAL_DIR=$(pwd)

# Create temporary directory
TEMP_DIR=$(mktemp -d)

# Ensure cleanup on exit or error
cleanup() {
    echo "$PREFIX Cleaning up temporary directory: $TEMP_DIR"
    rm -rf "$TEMP_DIR"
    echo "$PREFIX Cleanup completed"
}
trap cleanup EXIT

echo "$PREFIX Building smithy-java dependency in $TEMP_DIR"
cd "$TEMP_DIR"

# Build and publish smithy-java to maven local repository
git clone https://github.com/smithy-lang/smithy-java.git
cd smithy-java
git checkout 15b66e859bd56337352295736a6364f4961f1e07
./gradlew --no-daemon publishToMavenLocal

# Return to original directory
cd "$ORIGINAL_DIR"

# Build the main project
echo "$PREFIX Building main project..."
./gradlew --no-daemon shadowJar

# Verify the jar location
JAR_PATH="$ORIGINAL_DIR/artifacts/sample-for-amazon-ses-mcp-all.jar"
if [ -f "$JAR_PATH" ]; then
    echo "$PREFIX Successfully built jar under: $JAR_PATH"
else
    echo "$PREFIX Error: Failed to find JAR at expected location: $JAR_PATH" >&2
    exit 1
fi
