@echo off
set version=2.0
set dirname=Picklemon%version%
cd %AppData%\
mkdir %dirname%\mods\
:: Copy required files from main MC installation
echo Copying settings and keybinds
xcopy /q .minecraft\launcher_accounts_microsoft_store.json %dirname%\ >nul
xcopy /q .minecraft\launcher_profiles.json %dirname%\ >nul
xcopy /q .minecraft\launcher_settings.json %dirname%\ >nul
xcopy /q .minecraft\options.txt %dirname%\ >nul
xcopy /q .minecraft\servers.dat %dirname%\ >nul
xcopy /q .minecraft\usercache.json %dirname%\ >nul
if exist .minecraft\optionsof.txt (
	xcopy /q .minecraft\optionsof.txt %dirname%\ >nul
)
echo Extracting mods to installation folder
powershell Expand-Archive -Path %~dp0\picklemon.zip -DestinationPath %dirname%\mods\
:: Get date so the installation is selected by default
FOR /F "tokens=* USEBACKQ" %%F IN (`echo %DATE%`) DO (
	SET timedate=%%F
)
:: Format it correctly with the time
set timedate=%timedate:/=-%T%TIME%0Z
:: Add installation profile
cd %dirname%
CALL :addmodprofile
cd ..\.minecraft\
CALL :addmodprofile
echo.
echo Picklemon successfully installed!
pause
EXIT /B %ERRORLEVEL%

:addmodprofile
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
