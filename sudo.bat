@echo off
REM
REM From https://stackoverflow.com/users/1311745/dheeraj-bhaskar
REM Windows sudo the easy way :) 
REM %1 must reference a self-contained runtime process
REM i.e. no runtime arguments are supported
REM
:: Keep window for debug or ipfs commands
powershell.exe -Command "Start-Process cmd \"/k %1\" -Verb RunAs
:: Close window when finished
rem powershell.exe -Command "Start-Process cmd \"/c %1\" -Verb RunAs