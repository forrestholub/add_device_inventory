::::::::::::::: PROPERTY::::::::::OF::::::::::::ARCLIGHT:::::::::::::WIRELESS:::::::::::::
::::::::::::::::::::::::::::AUTHOR:::::::::FORREST HOLUB::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::COPYWRITE: 2020::::::::::::::::::::::::::::::::::::::::::
::Project Name: Inventory Add-Device Tool
::Version: 

::Revision Date: 2021 0102
::Author: Forrest Holub
::Company: Arclight Wireless
::Copywrite: MIT Open Source License


::Changes: 
:: v201103--> Added iphoneusbinfo 12 and 18 for help with Samsung devices
:: 

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
adb kill-server 1>NUL
adb start-server 1>NUL


FOR /f "delims=" %%A in ('adb shell getprop ro.boot.serialno') DO SET serial=%%A

REM check for issues with device connecting to ADB
IF "%serial%"==""  ECHO Device not connected correctly. Please try authorizing ADB or enabling ADB debugging && exit /b 1


::setup excel sheet for first time 
IF EXIST Device_Inventory.csv SET firstentry=0
IF NOT "%firstentry%"=="0" ECHO Manufacturer,Model,Codename,Model Number,Carrier,IMEI,Serial Number,Barcode,HW,ICCID,IMSI,MDN,Owner,Custody,Received,Transfer Dates,Additional info>>Device_Inventory.csv

IF "%firstentry%"=="0" (
    GOTO :check_INVENTORY
)

:check_INVENTORY
REM IMEI ----iphonesubinfo 4 (IMEI)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 4') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET imei=%%i 
IF EXIST temp.txt del temp.txt 2>&1>NUL
:: remove whitespace
SET imei=%imei: =%
findstr /m "%imei%" Device_Inventory.csv 2>&1>NUL
if %errorlevel%==0 (
    GOTO :Stop_Script
) else GOTO :Start_Script

:Stop_Script
ECHO Device Found. Existing program.
exit /b 0 

:Start_Script
ECHO Starting inventory addition. Please wait while I break out my rolodex


REM SHORTEN THE DATE

REM FOR /F "tokens=5-14 delims=" %%A in ("%date%") do SET date_small=%%A%%B%%C%%D%%E%%F%%G%%H%%I%%J%%K

REM Manufacture
FOR /f "delims=" %%A in ('adb shell getprop ro.product.brand') do SET brand=%%A
REM Model 
FOR /f "delims=" %%A in ('adb shell getprop ro.product.model') do SET model=%%A
REM Code Name
FOR /f "delims=" %%A in ('adb shell getprop ro.boot.device') do SET devicecodename=%%A
REM Code name using Product name
for /f "delims=" %%A in ('adb shell getprop ro.product.device') do SET product=%%A
REM SET CODE NAME CORRECTLY
IF "%devicecodename%"=="" (SET codename=%product%)
IF "%product%"=="" (SET codename=%devicecodename%)

REM Model Number
FOR /f "delims=" %%A in ('adb shell getprop ro.boot.hardware.sku') do SET sku=%%A
REM 4: carrier
FOR /f "delims=" %%A in ('adb shell getprop gsm.operator.alpha') do SET carrier1=%%A
FOR /f "delims=" %%A in ('adb shell getprop ro.carrier') do SET carrier2=%%A
REM incase carrier info isn't present---
IF "%carrier1%"=="" (SET carrier=%carrier2%
) ELSE (SET carrier=%carrier1% )

REM IMEI ----iphonesubinfo 3 (MEID)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 3') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET meid=%%i 
IF EXIST temp.txt del temp.txt 2>&1>NUL


REM IMEI ----iphonesubinfo 4 (IMEI)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 4') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET imei=%%i 
IF EXIST temp.txt del temp.txt 2>&1>NUL


REM Serial Number
FOR /f "delims=" %%A in ('adb shell getprop ro.boot.serialno') do SET serial=%%A
REM Barcode 
REM DON'T KNOW! DON'T CARE?

REM HW (DVT or PVT) __CURRENTLY BEST WAY TO DETERMINE HW____
FOR /f "delims=" %%A in ('adb shell getprop ro.vendor.hw.revision') do SET hardware=%%A

REM ICCID ----11 (ICCID)-moto?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 11') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET iccid1=%%i
IF EXIST temp.txt del temp.txt 2>&1>NUL

REM ICCID ----12 (ICCID) -samsung?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 12') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET iccid2=%%i
IF EXIST temp.txt del temp.txt 2>&1>NUL

REM SET ICCID CORRECTLY
IF "%ICCID1%"=="" (SET iccid=%ICCID2%
)ELSE ( SET iccid=%ICCID1%)

REM IMSI -----iphonesubinfo 7 (IMSI)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 7') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET imsi=%%i
IF EXIST temp.txt del temp.txt 2>&1>NUL

REM : MDN ----iphonesubinfo 17 (MDN)-moto?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 17') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET mdn1=%%i
IF EXIST temp.txt del temp.txt 2>&1>NUL

REM : MDN ----iphonesubinfo 18 (MDN)-samsung?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 18') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET mdn2=%%i
IF EXIST temp.txt del temp.txt 2>&1>NUL

REM SET MDN CORRECTLY
IF "%mdn1%"=="" (SET mdn=%mdn2%
)ELSE ( SET mdn=%mdn1%)

ECHO. 
ECHO. [1] ARCLIGHT [REF]
ECHO. [2] T-MOBILE [REF]
ECHO. [3] SPRINT   [REF]
ECHO. [4] DUT      [DUT]

CHOICE /C 1234 /T 5 /D 4 /N /M "Who is owner?"
IF %ERRORLEVEL% EQU 1 SET owner=arclight (REF)
IF %ERRORLEVEL% EQU 2 SET owner=t-mobile (REF)
IF %ERRORLEVEL% EQU 3 SET owner=sprint (REF)
IF %ERRORLEVEL% EQU 4 SET owner=DUT

CHOICE /C yn /T 5 /D n /N /M "Add additional info?: [y]for YES [n]for NO. You have [5]seconds to make up your mind"
IF %ERRORLEVEL% EQU 1 GOTO additional_info
IF %ERRORLEVEL% EQU 2 GOTO output

:additional_info
REM 7: Barcode
SET /p barcode="7: Additional Barcode:"

REM 11: Custody
SET /p custody="11: Enter Custody:"
REM 13: Transfers
SET /p transfer="13: Enter transfer date:"
REM 14: ADDITIONAL INFORMATION
SET /p comments="14: Additional comments:"
4

REM FUTURE EXTRAS:?:
REM iphonesubinfo 28 (SIP_ID)
REM whoami => auto list custody -> parse : desktop-34pmf9p\forre

:output
ECHO %brand%,%model%,%codename%,%sku%,%carrier%,%imei%,%serial%,%barcode%,%hardware%,%iccid%,%imsi%,%mdn%,%owner%,%custody%,%date%,%transfer%,%comments%>>Device_Inventory.csv


ENDLOCAL

:EOF
EXIT /b 0