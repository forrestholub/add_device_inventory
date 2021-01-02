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

::setup excel sheet for first time 
IF EXIST Device_Inventory_Forrest.csv SET firstentry=0
IF NOT "%firstentry%"=="0" ECHO Manufacturer, Model, Codename, Model Number, Carrier, IMEI, Serial Number, Barcode, HW, ICCID, IMSI, MDN, Custody, Received, Transfer Dates, Additional info>>Device_Inventory_Forrest.csv

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
IF EXIST temp.txt del temp.txt


REM IMEI ----iphonesubinfo 4 (IMEI)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 4') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET imei=%%i 
IF EXIST temp.txt del temp.txt


REM Serial Number
FOR /f "delims=" %%A in ('adb shell getprop ro.boot.serialno') do SET serial=%%A
REM Barcode 
REM DON'T KNOW! DON'T CARE?

REM HW (DVT or PVT) __CURRENTLY BEST WAY TO DETERMINE HW____
FOR /f "delims=" %%A in ('adb shell getprop ro.vendor.hw.revision') do SET hardware=%%A

REM ICCID ----11 (ICCID)-moto?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 11') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET iccid1=%%i
IF EXIST temp.txt del temp.txt

REM ICCID ----12 (ICCID) -samsung?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 12') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET iccid2=%%i
IF EXIST temp.txt del temp.txt

REM SET ICCID CORRECTLY
IF "%ICCID1%"=="" (SET iccid=%ICCID2%
)ELSE ( SET iccid=%ICCID1%)

REM IMSI -----iphonesubinfo 7 (IMSI)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 7') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET imsi=%%i
IF EXIST temp.txt del temp.txt

REM : MDN ----iphonesubinfo 17 (MDN)-moto?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 17') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET mdn1=%%i
IF EXIST temp.txt del temp.txt

REM : MDN ----iphonesubinfo 18 (MDN)-samsung?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 18') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET mdn2=%%i
IF EXIST temp.txt del temp.txt

REM SET MDN CORRECTLY
IF "%mdn1%"=="" (SET mdn=%mdn2%
)ELSE ( SET mdn=%mdn1%)

CHOICE /C yn /T 5 /D n /N /M "Add additional info?: [y]for YES [n]for NO. You have [5]seconds to make up your mind"
IF %ERRORLEVEL% EQU 2 GOTO output
IF %ERRORLEVEL% EQU 1 GOTO additional_info

:additional_info
REM 7: Barcode
SET /p barcode="7: Enter Barcode:"
REM 11: Custody
SET /p custody="11: Enter Custody:"
REM 13: Transfers
SET /p transfer="13: Enter transfer date:"
REM 14: ADDITIONAL INFORMATION
SET /p comments="14: Enter any additional information about device here:"


REM FUTURE EXTRAS:?:
REM iphonesubinfo 28 (SIP_ID)
REM whoami => auto list custody -> parse : desktop-34pmf9p\forre

:output
ECHO %brand%,%model%,%codename%,%sku%,%carrier%,%imei%,%serial%,%barcode%,%hardware%,%iccid%,%imsi%,%mdn%,%custody%,%date%,%transfer%,%comments%>>Device_Inventory_Forrest.csv


ENDLOCAL

:EOF
EXIT /b 0