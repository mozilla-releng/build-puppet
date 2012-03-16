@echo off

SET MOZ_MSVCVERSION=9
SET MOZBUILDDIR=%~dp0
SET MOZILLABUILD=%MOZBUILDDIR%

set log="c:\tmp\buildbot-startup.log"

echo "Mozilla tools directory: %MOZBUILDDIR%"

REM Get MSVC paths
echo "%date% %time% - About to call guess-msvc.bat" >> %log%
call "%MOZBUILDDIR%\guess-msvc.bat"

REM Use the "new" moztools-static
set MOZ_TOOLS=%MOZBUILDDIR%\moztools-x64

rem append moztools to PATH
SET PATH=%PATH%;%MOZ_TOOLS%\bin

if "%VC9DIR%"=="" (
    if "%VC9EXPRESSDIR%"=="" (
        ECHO "Microsoft Visual C++ version 9 (2008) was not found. Exiting."
        pause
        EXIT /B 1
    )

    if "%SDKDIR%"=="" (
    echo "%date% %time% - SDK not found" >> %log%
        ECHO "Microsoft Platform SDK was not found. Exiting."
        pause
        EXIT /B 1
    )

    rem Prepend MSVC paths
    echo "%date% %time% - About to call vcvars64.bat" >> %log%
    call "%VC9EXPRESSDIR%\Bin\amd64\vcvarsamd64.bat"

    rem Don't set SDK paths in this block, because blocks are early-evaluated.

    rem Fix problem with VC++Express Edition
    if "%SDKVER%" GEQ "6" (
        rem SDK Ver.6.0 (Windows Vista SDK) and newer
        rem do not contain ATL header files.
        rem We need to use the Platform SDK's ATL header files.
        SET USEPSDKATL=1
    )
    rem SDK ver.6.0 does not contain OleAcc.idl
    rem We need to use the Platform SDK's OleAcc.idl
    if "%SDKVER%" == "6" (
        if "%SDKMINORVER%" == "0" (
          SET USEPSDKIDL=1
        )
    )
) else (
    rem Prepend MSVC paths
    rem If the SDK is Win2k8, we want to use it.
    rem The Win7 SDK (or newer) should automatically integrate itself into vcvars32.bat
    if "%SDKVER%" == "6" (
        if "%SDKMINORVER%" == "1" (
          SET USESDK=1
        )
    )
    if "%USESDK%" == "0" (
        ECHO Using VC 2008 built-in SDK
    )
    echo "%date% %time% - Calling vcvars64.bat in VC9DIR" >> %log%
    call "%VC9DIR%\Bin\amd64\vcvarsamd64.bat"
)

if "%VC9DIR%"=="" (
    rem Prepend SDK paths - Don't use the SDK SetEnv.cmd because it pulls in
    rem random VC paths which we don't want.
    rem Add the atlthunk compat library to the end of our LIB
    set "PATH=%SDKDIR%\bin\x64;%SDKDIR%\bin;%PATH%"
    set "LIB=%SDKDIR%\lib\x64;%SDKDIR%\lib;%LIB%;%MOZBUILDDIR%atlthunk_compat"

    if "%USEPSDKATL%"=="1" (
        if "%USEPSDKIDL%"=="1" (
            set "INCLUDE=%SDKDIR%\include;%PSDKDIR%\include\atl;%PSDKDIR%\include;%INCLUDE%"
        ) else (
            set "INCLUDE=%SDKDIR%\include;%PSDKDIR%\include\atl;%INCLUDE%"
        )
    ) else (
        if "%USEPSDKIDL%"=="1" (
            set "INCLUDE=%SDKDIR%\include;%SDKDIR%\include\atl;%PSDKDIR%\include;%INCLUDE%"
        ) else (
            set "INCLUDE=%SDKDIR%\include;%SDKDIR%\include\atl;%INCLUDE%"
        )
    )
)

rem Set up Direct X 10 environment
set "INCLUDE=%INCLUDE%;c:\tools\sdks\dx10\include"
if "%WIN64%" == "1" (
  set "LIB=%LIB%;c:\tools\sdks\dx10\lib\x64"
) else (
  set "LIB=%LIB%;c:\tools\sdks\dx10\lib\x86"
)

cd "%USERPROFILE%"
:start

echo "%date% %time% - About to run runslave.py"

REM running this via 'bash' is critical - bash adds a bunch of items to PATH
REM which the build steps expect to find.

"%MOZILLABUILD%\msys\bin\bash" --login -c "python /c/runslave.py"

echo "%date% %time% - runslave.py finished"
