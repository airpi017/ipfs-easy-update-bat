@echo off
:: ipfs-easy-install.bat
:: Date: Sep 1, 2018
:: Feedback to: ej6809@gmail.com
:: No maintenance or replies guaranteed
::
:: Remember CWD
set return_dir=%cd%
:: Create install paths etc.
set updateVersion=v1.5.2
set IPFS_BIN=C:\ipfs\bin
set IPFS_INSTALL=C:\ipfs\install
if not exist %IPFS_BIN% md %IPFS_BIN%
if not exist %IPFS_INSTALL% md %IPFS_INSTALL%
cd %IPFS_INSTALL%
:: Format date and time.
:: https://superuser.com/questions/512163/using-date-and-times-in-a-batch-file-to-create-a-file-name
for /F "tokens=1-6* delims=.:-/ " %%i IN ("%DATE% %TIME%") DO Set "DDD=%%i"& Set "DD=%%j"& Set "MM=%%k"& Set "YYYY=%%l"& Set "HH=%%m"& Set "MI=%%n"
:: Determine which CPU is supported
set cpu=amd64
IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF NOT DEFINED PROCESSOR_ARCHITEW6432 set cpu=386
  )
echo ## Operating System is running on %cpu% compatible processor.
set /p InstallTheIpfs=## Ok to install the IPFS on this system [ y / n ] ? 
IF /i "%InstallTheIpfs%" == "n" (
  echo Cancelling the IPFS install ...
  cd %return_dir%
  goto Exit
)
Rem
Rem Download the IPFS Updater
Rem
IF not exist .\ipfs-update_%updateVersion%_windows-%cpu%.zip (
  echo ## Downloading .\ipfs-update_%updateVersion%_windows-%cpu%.zip
  curl http://dist.ipfs.io/ipfs-update/%updateVersion%/ipfs-update_%updateVersion%_windows-%cpu%.zip -o ./ipfs-update_%updateVersion%_windows-%cpu%.zip
  IF %errorlevel% NEQ 0 (
    echo curl failed with ErrorLevel %errorlevel% 
    goto Exit
  )
)
IF not exist .\ipfs-update (
  echo ## Extracting .zip file to %cd% ...
  powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('ipfs-update_%updateVersion%_windows-%cpu%.zip', '.'); }"
  IF %errorlevel% NEQ 0 (
    echo Unzip failed with ErrorLevel %errorlevel% 
    goto Exit
  )
)
:: Skip if latest already exists
cd .\ipfs-update
.\ipfs-update versions > versions.list
FOR /f "tokens=1* delims=" %%l IN (versions.list) DO Set LATEST=%%l

IF not exist %IPFS_BIN%\ipfs-%LATEST%.exe (
  echo ## Fetching latest ipfs binary via ipfs-update ... please wait.
  IF not exist .\ipfs-%LATEST% (
    .\ipfs-update fetch 
    IF %errorlevel% NEQ 0 (
      echo ipfs-update fetch failed with ErrorLevel %errorlevel%
      goto Exit
    )
  )
  Rem
  Rem Update the IPFS in Windows
  Rem
  echo ## Copying latest binary for the IPFS to %IPFS_BIN%\
  IF not exist %IPFS_BIN%\ipfs.exe ( 
    IF exist %IPFS_BIN%\ipfs.exe (
	  move /y %IPFS_BIN%\ipfs.exe %IPFS_BIN%\ipfs-%MM%%DD%-%HH%%MI%.exe
	)
  )
  copy /y %cd%\ipfs-%LATEST% %IPFS_BIN%\ipfs.exe
  IF %errorlevel% NEQ 0 (
    echo Copy of ipfs-%LATEST% to %IPFS_BIN%\ipfs.exe failed with ErrorLevel %errorlevel%
    echo The IPFS is probably running, Run Task Manager and End 'ipfs' under Command prompt task.
    goto Exit
  )
  move /y ipfs-%LATEST% %IPFS_BIN%\ipfs-%LATEST%.exe
  IF %errorlevel% NEQ 0 (
    echo Backup move of ipfs-%LATEST% to %IPFS_BIN%\ipfs-%LATEST%.exe failed with ErrorLevel %errorlevel%
    goto Exit
  )
)
:: not exist %IPFS_BIN%\ipfs-%LATEST%.exe

:: Get Monthly GB input from user via link speed
echo.
echo ## FYI - default bandwidth for the IPFS has no throttling policy applied.
echo For maintaining your internet experience, ~30%% or less of your uplink speed is recommended.
echo   e.g. 1Mbps uplink speed and 100,000MB per month is about 300kbit/s or 38KBytes/s up+down link speed. 
echo.
echo This install will shape bandwidth around the level you like using the 'New-NetQosPolicy' command.
echo   Each   3,000MB per month requires a link speed of about   4kbps for each direction 'up/down'
echo   Each  10,000MB per month requires a link speed of about  15kbps for each direction 'up/down' 
echo   Each 100,000MB per month requires a link speed of about 145kbps for each direction 'up/down' 
echo.
set UserMthlyKB=4
set /p UserMthlyKB=## What link speed would you like to contribute to the IPFS [ %UserMthlyKB% ] kbps (as an integer) ? 
set /a MBperMth=657*%UserMthlyKB%
echo.
echo ## Using %UserMthlyKB%kbps for each 'up/down' link for ~%MBperMth%MB per month - shaping only, so be vigilant :)
echo.
set /p UserPause=## Hit Enter key to continue ...
:: echo %UserMthlyKB% >> %IPFS_BIN%\ipfs-link.speed
powershell.exe New-NetQosPolicy -Name "ipfs" -AppPathNameMatchCondition "ipfs.exe" -ThrottleRateActionBitsPerSecond %UserMthlyKB%KB -PolicyStore ActiveStore > nul
:: On error probably means an update instead of install - use Set instead of New
IF %errorlevel% NEQ 0 powershell.exe Set-NetQosPolicy -Name "ipfs" -AppPathNameMatchCondition "ipfs.exe"  -ThrottleRateActionBitsPerSecond %UserMthlyKB%KB -PolicyStore ActiveStore > nul
IF %errorlevel% NEQ 0 (
  echo Unable to setup bandwidth shaping policy, failed with ErrorLevel %errorlevel%
rem  goto Exit
)
echo Setting up the IPFS to start on boot
if not exist ipfs.exe setx PATH %PATH%;%IPFS_BIN%
if not exist "C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ipfs-start.bat" (
  echo :: ipfs-start.bat - created by ipfs-easy-install.bat > %IPFS_BIN%\ipfs-start.bat
  echo :: %DDD% %DD%, %HH%:%MI% %MM%-%YYYY% >> %IPFS_BIN%\ipfs-start.bat
  echo :: up and down link speeds limited to %UserMthlyKB%KB/s >> %IPFS_BIN%\ipfs-start.bat
rem  echo cd %IPFS_BIN% >> %IPFS_BIN%\ipfs-start.bat
rem  echo FOR /f tokens=1 %%L IN (ipfs-link.speed) DO (Set ^"UserMthlyKB=%%L^") >> %IPFS_BIN%\ipfs-start.bat
  echo start "The IPFS - %UserMthlyKB%KB" ipfs daemon --init >> %IPFS_BIN%\ipfs-start.bat
  echo powershell New-NetQosPolicy -Name "ipfs" -AppPathNameMatchCondition "ipfs.exe" -ThrottleRateActionBitsPerSecond %UserMthlyKB%KB -PolicyStore ActiveStore >> %IPFS_BIN%\ipfs-start.bat
  echo sudo ipfs-start.bat > %IPFS_BIN%\sudo-ipfs.bat
  mklink "C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\sudo-ipfs.bat" "%IPFS_BIN%\sudo-ipfs.bat"
)
echo.
echo ## Starting the IPFS Daemon and showing the readme and quick-start documents ...
set /p UserPause=## Hit Enter key to continue ...
start "The IPFS Daemon" ipfs daemon --init && timeout 6 > nul
echo.
echo ## You can find out configuration info by running: ipfs id --help
ipfs id -f "<id>\n" > peer.id
for /f "tokens=1 delims=" %%a in (peer.id) do (set "PEER_ID=%%a")
echo   e.g. ipfs id -f "<id>\n" reveals your IPFS Peer ID: %PEER_ID%
echo Welcome to the IPFS - directory HASH: QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv
echo Welcome to the IPFS - readme: ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme
echo Capability overview:  ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/quick-start|more
echo.
ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme
set /p UserPause=## Hit Enter key to continue ...
ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/quick-start|more
echo.
echo ## Opening the IPFS WebGUI and Intro Directory at HASH QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv ...
echo.
set /p UserPause=## Hit Enter key to continue ...
start http://localhost:5001/webui
start http://localhost:8080/ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv
:Exit
cd %return_dir%