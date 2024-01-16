@echo off
set version=2.1
set dirname=Picklemon%version%
if not exist picklemon.zip (
	echo picklemon.zip is not in the same folder!
	echo Make sure the zip is in the following folder:
	echo %~dp0
	pause
	EXIT /B 1
)
echo|set /p="Java? "
set jreInstalled=true
powershell "Get-Package java*" | find "Exception" >nul 2>&1 && set jreInstalled=false
if %jreInstalled%==false (
	echo NOT installed! Installing...
	winget install Oracle.JavaRuntimeEnvironment >nul 2>&1
) else (
	echo Installed
)
cd %AppData%\
echo|set /p="Forge? "
if NOT EXIST .minecraft\versions\1.16.5-forge-36.2.34 (
	echo NOT installed! Installing...
	powershell Invoke-WebRequest -Uri https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.34/forge-1.16.5-36.2.34-installer.jar -OutFile $env:USERPROFILE\Downloads\forge-1.16.5-36.2.34-installer.jar | echo >nul 2>&1
	java -jar %USERPROFILE%\Downloads\forge-1.16.5-36.2.34-installer.jar >nul 2>&1
	ping 127.0.0.1 -n 1 -w 500 >nul
	del forge-1.16.5-36.2.34-installer.jar.log
	del %USERPROFILE%\Downloads\forge-1.16.5-36.2.34-installer.jar
) else (
	echo Installed
)
if exist %dirname%\ (
	echo Picklemon already installed!
	pause
	EXIT /B 1
)
mkdir %dirname%\mods\
echo Extracting mods to installation folder
powershell Expand-Archive -Path %~dp0\picklemon.zip -DestinationPath %dirname%\mods\

if EXIST .minecraft\ (
	setlocal enabledelayedexpansion
	:: Copy required files from main MC installation
	echo Copying settings and keybinds
	xcopy /q .minecraft\launcher_accounts_microsoft_store.json %dirname%\ >nul 2>&1
	xcopy /q .minecraft\launcher_profiles.json %dirname%\ >nul 2>&1
	xcopy /q .minecraft\launcher_settings.json %dirname%\ >nul 2>&1
	xcopy /q .minecraft\options.txt %dirname%\ >nul 2>&1
	xcopy /q .minecraft\servers.dat %dirname%\ >nul 2>&1
	xcopy /q .minecraft\usercache.json %dirname%\ >nul 2>&1
	if exist .minecraft\optionsof.txt (
		xcopy /q .minecraft\optionsof.txt %dirname%\ >nul 2>&1
	)
	:: Get date so the installation is selected by default
	FOR /F "tokens=* USEBACKQ" %%F IN (`echo %DATE%`) DO (
		SET timedate=%%F
	)
	:: Format it correctly with the time
	set timedate=!timedate:/=-!T%TIME%0Z
	:: Add installation profile
	cd %dirname%
	CALL :addmodprofile
	cd ..\.minecraft\
	CALL :addmodprofile
	endlocal
) else (
	echo Minecraft not detected. Skipping config edits.
)
echo.
echo Picklemon successfully installed!
pause
EXIT /B %ERRORLEVEL%

:addmodprofile
if NOT EXIST launcher_profiles.json (
	goto:eof
)
(
echo {
echo   "profiles" : {
echo     "%dirname%" : {
echo       "created" : "%timedate%",
echo       "gameDir" : "C:\\Users\\%USERNAME%\\AppData\\Roaming\\%dirname%",
echo       "icon" : "Furnace",
echo       "lastUsed" : "%timedate%",
echo       "lastVersionId" : "1.16.5-forge-36.2.34",
echo       "name" : "%dirname%",
echo       "type" : "custom"
echo     },
)>"launcher_profiles.json.new"
more +2 "launcher_profiles.json" >>"launcher_profiles.json.new"
move /y "launcher_profiles.json.new" "launcher_profiles.json" >nul
EXIT /B 0
