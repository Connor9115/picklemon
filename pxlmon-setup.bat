@echo off
set version=2.1
set mcVersion=1.16.5
set forgeVersion=36.2.34
set packName=Picklemon
set zipName=picklemon
set dirName=%zipName%%version%

if not exist %zipName%.zip (
	echo %zipName%.zip is not in the same folder!
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
if NOT EXIST .minecraft\versions\%mcVersion%-forge-%forgeVersion% (
	echo NOT installed! Installing...
	powershell Invoke-WebRequest -Uri https://maven.minecraftforge.net/net/minecraftforge/forge/%mcVersion%-%forgeVersion%/forge-%mcVersion%-%forgeVersion%-installer.jar -OutFile $env:USERPROFILE\Downloads\forge-%mcVersion%-%forgeVersion%-installer.jar | echo >nul 2>&1
	powershell java -jar %USERPROFILE%\Downloads\forge-%mcVersion%-%forgeVersion%-installer.jar >nul 2>&1
	ping 127.0.0.1 -n 1 -w 500 >nul
	del forge-%mcVersion%-%forgeVersion%-installer.jar.log
	del %USERPROFILE%\Downloads\forge-%mcVersion%-%forgeVersion%-installer.jar
) else (
	echo Installed
)
if exist %dirName%\ (
	echo %packName% already installed!
	pause
	EXIT /B 1
)
mkdir %dirName%\mods\
echo Extracting mods to installation folder
powershell Expand-Archive -Path %~dp0\%zipName%.zip -DestinationPath %dirName%\mods\

if EXIST .minecraft\ (
	setlocal enabledelayedexpansion
	:: Copy required files from main MC installation
	echo Copying settings and keybinds
	xcopy /q .minecraft\launcher_accounts_microsoft_store.json %dirName%\ >nul 2>&1
	xcopy /q .minecraft\launcher_profiles.json %dirName%\ >nul 2>&1
	xcopy /q .minecraft\launcher_settings.json %dirName%\ >nul 2>&1
	xcopy /q .minecraft\options.txt %dirName%\ >nul 2>&1
	xcopy /q .minecraft\servers.dat %dirName%\ >nul 2>&1
	xcopy /q .minecraft\usercache.json %dirName%\ >nul 2>&1
	if exist .minecraft\optionsof.txt (
		xcopy /q .minecraft\optionsof.txt %dirName%\ >nul 2>&1
	)
	:: Add installation profile
	cd %dirName%
	CALL :addmodprofile
	cd ..\.minecraft\
	CALL :addmodprofile
	endlocal
) else (
	echo Minecraft not detected. Skipping config edits.
)
echo.
echo %packName% successfully installed!
pause
EXIT /B %ERRORLEVEL%

:addmodprofile
if NOT EXIST launcher_profiles.json (
	goto:eof
)
(
echo {
echo   "profiles" : {
echo     "%dirName%" : {
echo       "gameDir" : "C:\\Users\\%USERNAME%\\AppData\\Roaming\\%dirName%",
echo       "icon" : "Furnace",
echo       "lastVersionId" : "%mcVersion%-forge-%forgeVersion%",
echo       "name" : "%dirName%",
echo       "type" : "custom"
echo     },
)>"launcher_profiles.json.new"
more +2 "launcher_profiles.json" >>"launcher_profiles.json.new"
move /y "launcher_profiles.json.new" "launcher_profiles.json" >nul
EXIT /B 0
