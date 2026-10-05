@echo off
setlocal
echo ===================================================================
echo   SERVICECONNECT - FAST AUTOMATED SELENIUM TEST RUNNER
echo ===================================================================

cd /d "%~dp0"

call mvn test -Dtest=ServiceConnectTest -o %*

if %ERRORLEVEL% equ 0 (
    echo.
    echo ===================================================================
    echo   [SUCCESS] All 12 automated test scenarios passed successfully!
    echo ===================================================================
) else (
    echo.
    echo ===================================================================
    echo   [FAILURE] Test suite encountered errors.
    echo ===================================================================
)
exit /b %ERRORLEVEL%
