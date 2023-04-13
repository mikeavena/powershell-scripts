# Author: Mike Avena
# License: MIT
# Purpose: Compares the contents of two directories by calculating the MD5 hash of each file within. Used to verify copy/backup integrity.
# Output: Table of files which have mismatching MD5 hashes between the source and target directories.

Param
(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateScript({ Test-Path $_ })]
    [string] $Source,
    [Parameter(Mandatory=$true, Position=1)]
    [ValidateScript({ Test-Path $_ })]
    [string] $Target
)

$tempdir = "C:\CopyIntegrityCheck"

if(!(Test-Path -Path $tempdir))
{
    New-Item -Path $tempdir -ItemType Directory
}

$SourceHashOutPath = "$tempdir\sourcehashlist.csv"
$TargetHashOutPath = "$tempdir\targethashlist.csv"

Get-FileHash -Algorithm MD5 -Path (Get-ChildItem "$Source\*.*" -Recurse) -ErrorAction SilentlyContinue | Export-CSV $SourceHashOutPath -NoTypeInformation

Get-FileHash -Algorithm MD5 -Path (Get-ChildItem "$Target\*.*" -Recurse) -ErrorAction SilentlyContinue | Export-CSV $TargetHashOutPath -NoTypeInformation

$SourceHashFile = Import-Csv $SourceHashOutPath
$TargetHashFile = Import-Csv $TargetHashOutPath

Compare-Object $SourceHashFile $TargetHashFile -Property Hash -PassThru | Select-Object Hash, Path