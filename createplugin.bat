@echo off
rem get number of command line arguments by nimrodm, https://stackoverflow.com/questions/1291941
set argC=0
for %%x in (%*) do Set /A argC+=1

if %argC% == 1 goto havearg
echo Syntax: CreatePlugin.bat Plugin_Name
exit 1
:havearg
if NOT EXIST %1 goto notexist
echo Folder or file %1 already exists
exit 1
:notexist
git version
if %ERRORLEVEL% == 0 goto havegit
echo Git was not found. Please get git from https://git-scm.com/download/win
echo And make sure it's in your PATH
exit 1
:havegit
7z >nul
if %ERRORLEVEL% == 0 goto have7z
echo 7zip was not found. Please get 7zip from https://www.7-zip.org/
echo And make sure it's in your PATH
:have7z
echo Creating plugin %1
echo.
mkdir %1
cd %1
git init
git submodule add https://github.com/JustArchiNET/ArchiSteamFarm.git
git submodule foreach "git fetch origin; git checkout $(git rev-list --tags --max-count=1);"
git add -A
git commit -m "add ASF as submodule"
dotnet new classlib -f net5.0 -n %1
dotnet add %1/%1.csproj package System.Composition.AttributedModel -v *
dotnet add %1/%1.csproj reference ArchiSteamFarm\ArchiSteamFarm\ArchiSteamFarm.csproj
dotnet new sln -n %1
dotnet sln add %1
dotnet sln add ArchiSteamFarm\ArchiSteamFarm\ArchiSteamFarm.csproj --in-root
copy ..\build.bat .
copy ..\.gitignore .
rem search&replace by MC ND, https://stackoverflow.com/questions/23075953
    setlocal enableextensions disabledelayedexpansion

    set "search=net5.0"
    set "replace=net5.0;net48"

    set "textFile=%1\%1.csproj"

    for /f "delims=" %%i in ('type "%textFile%" ^& break ^> "%textFile%" ') do (
        set "line=%%i"
        setlocal enabledelayedexpansion
        >>"%textFile%" echo(!line:%search%=%replace%!
        endlocal
    )
rem one more search&replace
    setlocal enableextensions disabledelayedexpansion

    set "search=TargetFramework"
    set "replace=TargetFrameworks"

    set "textFile=%1\%1.csproj"

    for /f "delims=" %%i in ('type "%textFile%" ^& break ^> "%textFile%" ') do (
        set "line=%%i"
        setlocal enabledelayedexpansion
        >>"%textFile%" echo(!line:%search%=%replace%!
        endlocal
    )
rem end of search&replace

git add -A
git commit -m "add initial commit"

rem reading variable from stdout by Mechaflash, https://stackoverflow.com/questions/6359820
FOR /F "tokens=* USEBACKQ" %%F IN (`git config --global user.name`) DO (SET gituser=%%F)

if NOT %gituser%=="" goto havename
echo Git user was not set. Please set git user with 
echo   git config --global user.name "Your name here"
echo Make sure it's the same as your github username!
exit 1
:havename

git ls-remote http://github.com/%gituser%/%1.git
if %ERRORLEVEL% == 0 goto haverepo
echo Github repository %1 was not found. Did you forgot to create it?
echo Repository must be empty (no README.md etc)!
exit 1

:haverepo
git remote add origin https://github.com/%gituser%/%1.git
git push -u origin master

echo.
echo.
echo.
echo Plugin repo created
echo Things to consider next:
echo - Add AssemblyVersion and Autors to plugin project
echo - Add actual code!