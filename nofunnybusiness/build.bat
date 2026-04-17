@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  DLL Tracer GUI - Build Script
::
::  Deps to drop into deps\ (all flat, no subfolders):
::
::    MinHook:
::      deps\MinHook.h
::      deps\MinHook.x64.lib
::      deps\MinHook.dll
::
::    Dear ImGui  (clone https://github.com/ocornut/imgui):
::      deps\imgui\imgui.h / .cpp
::      deps\imgui\imgui_draw.cpp
::      deps\imgui\imgui_tables.cpp
::      deps\imgui\imgui_widgets.cpp
::      deps\imgui\backends\imgui_impl_win32.h / .cpp
::      deps\imgui\backends\imgui_impl_dx11.h  / .cpp
:: ============================================================

set ARCH=x64
set BUILD_DIR=build\%ARCH%
set SRC_DIR=src
set DEPS_DIR=deps

:: ============================================================
::  Auto-detect Visual Studio
:: ============================================================
set VSWHERE="%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist %VSWHERE% set VSWHERE="%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe"

set VS_INSTALL=
if exist %VSWHERE% (
    for /f "usebackq tokens=*" %%i in (
        `%VSWHERE% -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`
    ) do set VS_INSTALL=%%i
)

if "!VS_INSTALL!"=="" (
    echo [ERR] Visual Studio not found.
    echo       Install VS 2019/2022 with "Desktop development with C++" workload.
    goto :fail
)
echo [*] Visual Studio: !VS_INSTALL!
call "!VS_INSTALL!\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1

:: ============================================================
::  Validate deps
:: ============================================================
set MISSING=0

if not exist "%DEPS_DIR%\MinHook.h"        ( echo [ERR] Missing: deps\MinHook.h        & set MISSING=1 )
if not exist "%DEPS_DIR%\MinHook.x64.lib"  ( echo [ERR] Missing: deps\MinHook.x64.lib  & set MISSING=1 )
if not exist "%DEPS_DIR%\MinHook.dll"      ( echo [ERR] Missing: deps\MinHook.dll       & set MISSING=1 )
if not exist "%DEPS_DIR%\imgui\imgui.h"    ( echo [ERR] Missing: deps\imgui\imgui.h     & set MISSING=1 )

if "!MISSING!"=="1" (
    echo.
    echo  See build.bat header comments for where to get each dependency.
    echo  MinHook   : https://github.com/TsudaKageyu/minhook/releases
    echo  Dear ImGui: https://github.com/ocornut/imgui  ^(just clone into deps\imgui\^)
    goto :fail
)

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

:: ImGui source files
set IMGUI_SRC=^
  "%DEPS_DIR%\imgui\imgui.cpp" ^
  "%DEPS_DIR%\imgui\imgui_draw.cpp" ^
  "%DEPS_DIR%\imgui\imgui_tables.cpp" ^
  "%DEPS_DIR%\imgui\imgui_widgets.cpp" ^
  "%DEPS_DIR%\imgui\backends\imgui_impl_win32.cpp" ^
  "%DEPS_DIR%\imgui\backends\imgui_impl_dx11.cpp"

set INCLUDES=^
  /I"%DEPS_DIR%" ^
  /I"%DEPS_DIR%\imgui" ^
  /I"%DEPS_DIR%\imgui\backends"

set CL_FLAGS=/nologo /W3 /O2 /EHsc /std:c++17 /MT

:: ============================================================
::  1. hook.dll
:: ============================================================
echo.
echo [1/2] Building hook.dll...
cl %CL_FLAGS% %INCLUDES% ^
    /LD ^
    "%SRC_DIR%\hook.cpp" ^
    /Fe:"%BUILD_DIR%\hook.dll" ^
    /Fo:"%BUILD_DIR%\hook_obj\\" ^
    /link "%DEPS_DIR%\MinHook.x64.lib" kernel32.lib ^
    /SUBSYSTEM:WINDOWS

if errorlevel 1 ( echo [ERR] hook.dll failed & goto :fail )
echo [OK] hook.dll

:: ============================================================
::  2. tracer.exe  (GUI)
:: ============================================================
echo.
echo [2/2] Building tracer.exe...

if not exist "%BUILD_DIR%\tracer_obj" mkdir "%BUILD_DIR%\tracer_obj"

cl %CL_FLAGS% %INCLUDES% ^
    "%SRC_DIR%\tracer.cpp" ^
    %IMGUI_SRC% ^
    /Fe:"%BUILD_DIR%\tracer.exe" ^
    /Fo:"%BUILD_DIR%\tracer_obj\\" ^
    /link d3d11.lib dxgi.lib psapi.lib kernel32.lib user32.lib ^
    /SUBSYSTEM:WINDOWS

if errorlevel 1 ( echo [ERR] tracer.exe failed & goto :fail )
echo [OK] tracer.exe

:: ============================================================
::  Copy runtime deps to output
:: ============================================================
copy /Y "%DEPS_DIR%\MinHook.dll" "%BUILD_DIR%\" >nul
echo [OK] MinHook.dll copied

:: ============================================================
::  Done
:: ============================================================
echo.
echo ============================================================
echo  Build complete ^>  %BUILD_DIR%\
echo ============================================================
echo.
echo  tracer.exe  -  run this. It does everything:
echo    1. Pick a running process from the list
echo    2. Click "Load DLL list" and select the DLL to trace
echo    3. Click "Inject + Hook"
echo    4. Watch the live call log on the right
echo.
echo  hook.dll + MinHook.dll must stay in the same folder as tracer.exe
echo.
goto :end

:fail
echo.
echo [FAIL] Build did not complete.
echo.

:end
endlocal
pause
