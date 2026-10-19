@echo off
rem Configure, build, test and package the project (Windows)
setlocal
cd /d "%~dp0"

set BUILD_DIR=build
set DIST_DIR=dist

echo == Configure ==
cmake -S . -B %BUILD_DIR% -DCMAKE_BUILD_TYPE=Release || goto :fail

echo == Build ==
cmake --build %BUILD_DIR% --config Release --parallel || goto :fail

echo == Test ==
ctest --test-dir %BUILD_DIR% -C Release --output-on-failure || goto :fail

echo == Package ==
if not exist %DIST_DIR% mkdir %DIST_DIR%
if exist %BUILD_DIR%\Release\hello.exe (
  copy /Y %BUILD_DIR%\Release\hello.exe %DIST_DIR%\hello.exe >nul || goto :fail
) else (
  copy /Y %BUILD_DIR%\hello.exe %DIST_DIR%\hello.exe >nul || goto :fail
)

echo == Smoke test ==
%DIST_DIR%\hello.exe || goto :fail

echo CI: SUCCESS
exit /b 0

:fail
echo CI: FAILED
exit /b 1
