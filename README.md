# ipfs-easy-update-bat
BAT script for installing IPFS on windows

Separate `.sh` file written for installing on linux, freebsd and darwin.

**IPFS** is the **I**nter**P**lanetary **F**ile**S**ystem

Imagine `bit torrent` on a `blockchain`.

Files are accessed `bit torrent`-like using a `blockchain` file hash instead of a DNS based location.

Allows an IPFS based device to seed the IPFS when it's the nearest copy of the file hash.

This works great when you're on Mars with the family videos - no more 40min round-trip delays.

Also great for accessing recent content closer to you when sharing - the nearest p2p IPFS devices around you hold the content. 

The more p2p IPFS devices the faster it is accessing your content - so tell your friends !

For more information see [ipfs.io](https://ipfs.io/)

## Initial install and bandwidth shaping
Two `.bat` files are needed, 1. to emulate `sudo` or the Adminstrator and 2. to install the IPFS for you.

The `ipfs-easy-install.bat` file uses the following environment variables to install the IPFS for you.

`:: Create install paths etc.`

`set updateVersion=v1.5.2`

`set IPFS_BIN=C:\ipfs\bin`

`set IPFS_INSTALL=C:\ipfs\install`

%updateVersion% is used to set the %LATEST% variable when a later version is detected.

Uses `New-NetQosPolicy` or `Set-NetQosPolicy` in `powershell` to shape bandwidth usage - `be vigilant`.

Creates `c:\ipfs\bin\ipfs-start.bat` so IPFS starts on reboot for your usual `user` account.

Creates an admin `.bat` and Startup link to `c:\ipfs\bin\sudo-ipfs.bat` so IPFS starts as Admin on reboot for your usual `user` account.

Requires `sudo.bat` in current directory \[and later,`c:\ipfs\bin \]` and a `directoryname` to establish the IPFS install for you.

`> sudo ipfs-easy-install.bat ipfs-project-dir`

## Modify bandwidth shaping after install
Re-run the batch file and change bandwidth to the level you choose

Batch file uses `New-NetQosPolicy` or `Set-NetQosPolicy` in `powershell` to update the new level for you

New level is applied immediately.

## Overview of the steps used in batch file
 0. sudo with original `user` - say 'Yes' to Admin rights
 1. Selects Windows OS and CPU instruction set for you.
 3. Downloads specifc IPFS update `.zip` file for your system
 4. Runs `ipfs-update` and installs the latest version
 5. Shapes bandwidth usage using `XXX-NetQosPolicy` - `be vigilant`
 6. Sets up `sudo-ipfs.bat` and Startup link
 7. Initialises ipfs and includes `C:\ipfs\bin` in %PATH%
 8. Show ipfs readme and then the quick-start pages
 9. Launches WebUI using start command

`Tested for Windows 10 only.`

## Some Help
I can help with questions on the weekends for \[other\] platforms where I can, I only have Windows and Ubuntu environments to work with locally. `philiptwayne at yahoo com au`

## Behaviour on Startup
You will see 2 terminal windows appear after a restart.

One is starting the IPFS for you and stays open. This can be closed using `^C` twice. Ignore any error messages.

The second sets the bandwidth shaping you've chosen and closes once the IPFS has started - `be vigilant`.

## Behaviour after Hibernate
You will only see the original IPFS terminal window.

This can be closed using `^C` twice. You can ignore any error messages on your return.

The bandwidth shaping settings you've chosen have been re-applied - `be vigilant`.
