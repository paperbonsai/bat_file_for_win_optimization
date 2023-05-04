@echo off
setlocal enableextensions

echo Speeding up your Windows computer...
echo.

:: Check for admin privileges and request elevation if needed
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" && (
    echo Administrative privileges detected.
) || (
    echo Requesting administrative privileges...
    powershell start -verb runAs '%0'
    exit /b
)

:: Empty the Recycle Bin
echo Emptying the Recycle Bin...
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo Recycle Bin emptied.

:: Clean the temp directory
echo Cleaning the temp directory...
RD /S /Q "%temp%" && MD "%temp%"
echo Temp directory cleaned.

:: Define the services to stop
set "services=AVCTPService BDESVC bthserv Browser DiagTrack DPS TrkWks MapsBroker fhsvc iphlpsvc irmon SharedAccess Netlogon PcaSvc Spooler WPCSvc RemoteRegistry seclogon lmhosts WerSvc wia StorSvc wisvc WSearch"

echo Stopping unnecessary services if they are running...
for %%s in (%services%) do (
    sc query %%s | find /i "STATE" | find /i "RUNNING" > nul && (
        net stop %%s
    )
)



:: Optimization tasks
echo Updating Windows...
start /w wuauclt.exe /detectnow /updatenow
echo Windows update complete.
echo.

echo Removing bloatware...
powershell -command "Get-AppxPackage * | Remove-AppxPackage"
echo Bloatware removed.
echo.

echo Disabling unnecessary startup programs...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Program Name" /t REG_SZ /d "" /f
echo Startup programs disabled.
echo.

echo Disabling unnecessary services...
for %%s in (%services%) do (
    sc config "%%s" start= disabled
)
echo Services disabled.
echo.

echo Adjusting power settings...
powercfg /setactive "Power Plan Name"
echo Power settings adjusted.
echo.

echo Cleaning temporary files...
cleanmgr /sagerun:1
echo Temporary files deleted.
echo.

echo Optimizing hard drive...
defrag %systemdrive% /O
echo Hard drive optimization complete.
echo.

echo Running System File Checker...
sfc /scannow
echo System File Checker complete.
echo.

echo Updating drivers...
pnputil.exe -e > C:\drivers.txt
echo Driver update complete.
echo.

echo Disabling unnecessary visual effects...
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f
echo Visual effects disabled.
echo.

:: Prompt for stopping explorer.exe
echo Do you want to stop explorer.exe? Type "y" for yes or "n" for no.
set /p userChoice="> "
if /i "%userChoice%"=="y" (
    taskkill /IM explorer.exe /F
    echo Explorer stopped.
    timeout /t 1 /nobreak >nul
)

:: Restart explorer.exe and services if user choice was "y"
if /i "%userChoice%"=="y" (
    echo Starting explorer.exe and services that were stopped...
    timeout /
    echo Starting explorer.exe...
    start explorer.exe
    timeout /t 1 /nobreak >nul
    echo Starting services...
    for %%s in (%services%) do (
        sc query %%s | find /i "STATE" | find /i "STOPPED" > nul && (
            net start %%s
        )
    )
    echo Services started.
)

echo Done! Please restart your computer for the changes to take effect.
pause
