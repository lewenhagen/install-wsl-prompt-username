@echo off
:: Step 1: Prompt for Username and Password
set /p username=Enter your desired username: 
set /p password=Enter your desired password: 

:: Step 2: Install WSL if not already installed
echo Installing WSL and Ubuntu...
wsl --install
if %errorlevel% neq 0 (
    echo "Enabling WSL..."
    dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
)

:: Enable Virtual Machine Platform if not already enabled
echo "Enabling Virtual Machine Platform..."
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

:: Step 3: Restart to apply changes
echo "Restarting to apply changes..."
shutdown /r /t 5
exit

:: Step 4: Install Ubuntu (after restart)
powershell -Command "Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu.appx"
Add-AppxPackage .\Ubuntu.appx

:: Step 5: Set WSL default version to 2
wsl --set-default-version 2

:: Step 6: Create cloud-init user-data configuration
echo #cloud-config > %USERPROFILE%\user-data
echo users: >> %USERPROFILE%\user-data
echo "  - name: %username%" >> %USERPROFILE%\user-data
echo "    gecos: %username%" >> %USERPROFILE%\user-data
echo "    sudo: ALL=(ALL) NOPASSWD:ALL" >> %USERPROFILE%\user-data
echo "    shell: /bin/bash" >> %USERPROFILE%\user-data
echo "    lock_passwd: false" >> %USERPROFILE%\user-data

:: Step 7: Generate the hashed password using openssl in WSL
wsl openssl passwd -6 %password% > %USERPROFILE%\passwdhash.txt

:: Read the password hash from the file
set /p hashedpassword=<%USERPROFILE%\passwdhash.txt

:: Append the hashed password to the cloud-init config
echo "    passwd: %hashedpassword%" >> %USERPROFILE%\user-data

:: Step 8: Move cloud-init config to the correct folder in Ubuntu (after Ubuntu installation)
echo "Log into Ubuntu and move the cloud-init file to /etc/cloud/cloud.cfg.d/"
ubuntu2004.exe

:: Step 9: Instructions to apply cloud-init (manual step)
echo "To apply the cloud-init configuration, run the following commands in Ubuntu:"
echo "sudo mv /mnt/c/Users/%username%/user-data /etc/cloud/cloud.cfg.d/"
echo "sudo cloud-init init"
echo "sudo cloud-init modules --mode=config"
echo "sudo cloud-init modules --mode=final"
