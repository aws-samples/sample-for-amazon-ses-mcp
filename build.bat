@echo off
setlocal enabledelayedexpansion

REM Log prefix
set "PREFIX=[Build Script]"

REM Check requirements
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %PREFIX% Error: git is required but not installed >&2
    exit /b 1
)

where java >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %PREFIX% Error: Java is required but not installed >&2
    exit /b 1
)

REM Check Java version
for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set JAVA_VERSION=%%g
)
set JAVA_VERSION=!JAVA_VERSION:"=!
for /f "delims=. tokens=1" %%a in ("!JAVA_VERSION!") do set JAVA_MAJOR=%%a
if !JAVA_MAJOR! LSS 21 (
    echo %PREFIX% Error: Java 21 or later is required >&2
    exit /b 1
)

REM Save the original directory
set "ORIGINAL_DIR=%CD%"

REM Create temporary directory
set "TEMP_DIR=%TEMP%\smithy-build-%RANDOM%"
mkdir "%TEMP_DIR%"
echo %PREFIX% Created temporary directory: %TEMP_DIR%

REM Build smithy-java dependency
echo %PREFIX% Building smithy-java dependency in %TEMP_DIR%
cd /d "%TEMP_DIR%"

REM Clone and build smithy-java
git clone https://github.com/smithy-lang/smithy-java.git
cd smithy-java
git checkout 15b66e859bd56337352295736a6364f4961f1e07
call gradlew --no-daemon publishToMavenLocal
if %ERRORLEVEL% neq 0 (
    echo %PREFIX% Error: Failed to build smithy-java >&2
    goto cleanup
)

REM Return to original directory
cd /d "%ORIGINAL_DIR%"

REM Build the main project
echo %PREFIX% Building main project...
call gradlew --no-daemon shadowJar
if %ERRORLEVEL% neq 0 (
    echo %PREFIX% Error: Failed to build main project >&2
    goto cleanup
)

REM Verify the jar location
set "JAR_PATH=%ORIGINAL_DIR%\artifacts\sample-for-amazon-ses-mcp-all.jar"
if exist "%JAR_PATH%" (
    echo %PREFIX% Successfully built jar under: %JAR_PATH%
) else (
    echo %PREFIX% Error: Failed to find JAR at expected location: %JAR_PATH% >&2
    goto cleanup_with_error
)

:cleanup
REM Clean up temporary directory
echo %PREFIX% Cleaning up temporary directory: %TEMP_DIR%
rd /s /q "%TEMP_DIR%"
echo %PREFIX% Cleanup completed
exit /b 0

:cleanup_with_error
REM Clean up and exit with error
echo %PREFIX% Cleaning up temporary directory: %TEMP_DIR%
rd /s /q "%TEMP_DIR%"
echo %PREFIX% Cleanup completed
exit /b 1
