::::::::::::::: PROPERTY::::::::::OF::::::::::::ARCLIGHT:::::::::::::WIRELESS:::::::::::::
::::::::::::::::::::::::::::AUTHOR:::::::::FORREST HOLUB::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::COPYWRITE: 2020::::::::::::::::::::::::::::::::::::::::::
::Project Name: Inventory Add-Device Tool
::Version: 

::Revision Date: 2021 0102
::Author: Forrest Holub
::Company: Arclight Wireless
::Copywrite: MIT Open Source License

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO Welcome to the inventory tool.
ECHO.
ECHO Be sure to close the inventory file before attempting to add, otherwise it will not be saved.
ECHO.
ECHO.

::setup excel sheet for first time 
IF EXIST Device_Inventory_Sprint.csv SET firstentry=0
IF NOT "%firstentry%"=="0" ECHO Carrier,OEM,Model,MEID,IMEI,SKU,Activation Status,Other Comments>>Device_Inventory_Sprint.csv

REM SHORTEN THE DATE

REM FOR /F "tokens=5-14 delims=" %%A in ("%date%") do SET date_small=%%A%%B%%C%%D%%E%%F%%G%%H%%I%%J%%K

REM Manufacture
FOR /f "delims=" %%A in ('adb shell getprop ro.product.brand') do SET oem=%%A
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


REM DUPLICATE SKU IF NOT PRESENT WITH MODEL VALUE 
IF "%sku%"=="" (SET skued=%model%
)ELSE ( SET skued=%sku%)

REM 4: carrier
FOR /f "delims=" %%A in ('adb shell getprop ro.carrier') do SET carrier1=%%A
FOR /f "delims=" %%A in ('adb shell getprop ro.cdma.home.operator.alpha') do SET carrier2=%%A

REM default carrier selection
SET carrier=%carrier1%

REM --conditionals on carrier selection--
IF /i "%carrier1%"=="" SET carrier=%carrier2%

IF /i "%carrier1%"=="unknown" SET carrier=%carrier2%

IF /i "%carrier2%"=="unknown" SET carrier=%carrier1%

REM IMEI ----iphonesubinfo 3 (MEID)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 3') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET meid=%%i 
IF EXIST temp.txt del temp.txt >nul 2>&1


REM IMEI ----iphonesubinfo 4 (IMEI)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 4') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET imei=%%i 
IF EXIST temp.txt del temp.txt >nul 2>&1


REM Serial Number
FOR /f "delims=" %%A in ('adb shell getprop ro.boot.serialno') do SET serial=%%A
REM Barcode 
REM DON'T KNOW! DON'T CARE?

REM HW (DVT or PVT) __CURRENTLY BEST WAY TO DETERMINE HW____
FOR /f "delims=" %%A in ('adb shell getprop ro.vendor.hw.revision') do SET hardware=%%A

REM ICCID ----11 (ICCID)-moto?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 11') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET iccid1=%%i
IF EXIST temp.txt del temp.txt >nul 2>&1

REM ICCID ----12 (ICCID) -samsung?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 12') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET iccid2=%%i
IF EXIST temp.txt del temp.txt >nul 2>&1

REM SET ICCID CORRECTLY
IF "%ICCID1%"=="" (SET iccid=%ICCID2%
)ELSE ( SET iccid=%ICCID1%) >nul 2>&1

REM IMSI -----iphonesubinfo 7 (IMSI)
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 7') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET imsi=%%i
IF EXIST temp.txt del temp.txt >nul 2>&1

REM : MDN ----iphonesubinfo 17 (MDN)-moto?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 17') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET mdn1=%%i
IF EXIST temp.txt del temp.txt >nul 2>&1

REM : MDN ----iphonesubinfo 18 (MDN)-samsung?
FOR /F "skip=1 tokens=2,3,4,5,6,7,8,9 delims='.)" %%i IN ('adb shell service call iphonesubinfo 18') DO <NUL SET /P result=%%i%%j%%k%%l%%m%%n%%o%%p>>temp.txt
IF EXIST temp.txt FOR /F "tokens=1 delims= " %%i IN (temp.txt) DO SET mdn2=%%i
IF EXIST temp.txt del temp.txt >nul 2>&1

REM SET MDN CORRECTLY
IF "%mdn1%"=="" (SET mdn=%mdn2%
)ELSE ( SET mdn=%mdn1%)

:additional_info
REM activation status
SET /p activation="Activation status details:"

REM other comments
SET /p comments="14: Enter any additional information about device here:"


:output
ECHO %carrier%,%oem%,%model%,'%meid%','%imei%',%skued%,%activation%,%comments%>>Device_Inventory_Sprint.csv
IF "%ERRORLEVEL%"=="1" do ECHO Be sure to close the CSV file before attempting to write to inventory. 

ENDLOCAL
:EOF
EXIT /b 0