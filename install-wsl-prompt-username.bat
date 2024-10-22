@echo off
setlocal

:: Get new user
set /p username=Ange ett användarnamn:

:: Define WSL distribution and user details
set DISTRO_NAME=Ubuntu
set NEW_USER=%username%

:: Check if WSL is installed
wsl --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo WSL is not installed. Installing WSL...
    wsl --install
    echo WSL installed. Please restart your computer and run this script again.
    exit /b
)

:: Check if the selected distribution is installed
wsl -l -v | findstr /I "%DISTRO_NAME%" >nul
if %ERRORLEVEL% neq 0 (
    echo Installing %DISTRO_NAME%...
    wsl --install -d %DISTRO_NAME%
    echo %DISTRO_NAME% installation completed.
)

:: Launch the distro to set it up
echo Launching %DISTRO_NAME% for initial setup...
wsl -d %DISTRO_NAME%

:: Set the new user
echo Setting default user to: %NEW_USER%
wsl -d %DISTRO_NAME% --user %NEW_USER%

echo WSL setup complete with user %NEW_USER%.
pause
