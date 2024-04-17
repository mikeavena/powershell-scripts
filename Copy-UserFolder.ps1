# Author: Mike Avena
# Purpose: Copies a specified user folder to a target location using Robocopy. Preserves file timestamps. Excludes AppData and Application Data folders.
# Output: Log file with errors.

Param
(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $User,
    [Parameter(Mandatory=$true, Position=1)]
    [ValidateScript({ Test-Path $_ })]
    [string] $Target
)

Robocopy C:\Users\$User $Target /XJ /XD C:\Users\$User\AppData /DCOPY:T /COPY:DAT /E /R:0 /LOG:C:\CopyUserFolder.LOG /nfl /ndl /njh /njs /ns /nc /np /tee