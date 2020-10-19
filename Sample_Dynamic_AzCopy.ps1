<# 
.SYNOPSIS
Dynamically Move Local Files to Azure Blob Storage using AzCopy

.DESCRIPTION
The sample scripts are not supported under any Microsoft standard support program or service. 
The sample scripts are provided AS IS without warranty of any kind. 
Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of 
fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation 
remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of 
the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, 
business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the 
sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages. 
#>

##############################################################
# Dynamic AzCopy to Blob
# Version:        1.2
# Author:         jessica.johnson@microsoft.com
# Last Update :   10-19-2020
##############################################################

[CmdletBinding()]
Param(

    # Script Params for Azure Storage Blob info.
    [Parameter(Mandatory=$TRUE, HelpMessage="Name of targeted Azure Storage Blob Account.")]
    [string]$StorageAccount,

    [Parameter(Mandatory=$TRUE, HelpMessage="Name of targeted Azure Storage Blob Container.")]
    [string]$StorageContainer,

    [Parameter(Mandatory=$TRUE, HelpMessage="SAS Token for access to targeted Azure Storage Blob Container.")]
    [string]$SASToken,

    # Param for local file path for files that will be uploaded to Blob.
    [Parameter(Mandatory=$TRUE, HelpMessage="Local source directory for processing.")]
    [string]$LocalDirPath
)

function CheckPSExecutionPolicy{
    # Store to variable current PowerShell ExecutionPolicy 
    $OrigExecutionPolicy =  Get-ExecutionPolicy

    # DEBUG - Print Current Execution Policy.
    #Write-Host "---------[[DEBUG]] Current Execution Policy = $OrigExecutionPolicy"

    # Check proper Execution Policy is set to run script.
    if($OrigExecutionPolicy -ne "RemoteSigned"){
        Set-ExecutionPolicy RemoteSigned -Force
    }

    return $OrigExecutionPolicy
}

function UploadDirFilesToBlob{

    param([string]$StorageAccount,[string]$StorageContainer,[string]$SASToken,[string]$LocalDirPath)

    # Initialize Variables
    $StorageContainerEndpoint = ''

    # Build dynamic Azure Storage Blob endpoint based on user input.
    $StorageContainerEndpoint = "https://$StorageAccount.blob.core.windows.net/$StorageContainer"

    # DEBUG - Print user input for local file path.
    Write-Host "---------[[DEBUG]] Local File Path = '$LocalDirPath'"

    # Check user input local file path exists before moving on.
    if(-not(Test-Path -Path "$LocalDirPath")){
        Write-Host "!! Error '$LocalDirPath' does not exist !!"
        return $false
        #exit 1
    }
    else{

        # Get only CSV files in local file path and loop through result list.
        Get-ChildItem -Path "$LocalDirPath" -Filter *.csv |

        ForEach-Object {
            
            # Create dynamic azure blob storage container path for current file.
            $StorageBlobPath = "$StorageContainerEndpoint/$($_.BaseName)/$SASToken"

            # DEBUG - Print user input for local file path.
            #Write-Host "---------[[DEBUG]] Azure Blob Storage Path = $StorageBlobPath"
    
            # Use AzCopy to copy current local file to azure blob storage path.
            azcopy cp $('"' + $_.FullName + '"') $('"' + $StorageBlobPath + '"')

            Write-Host "[LOG] Successfully copied '$($LocalDirPath)\$_' to '$StorageContainerEndpoint/$($_.BaseName)/$_'"
        }

        return $true
    }
}

# Start watch to measure E2E time duration
$StopWatch = [System.Diagnostics.StopWatch]::StartNew()

$CurrentExecutionPolicy = CheckPSExecutionPolicy

$result_UploadToBlob = UploadDirFilesToBlob $StorageAccount $StorageContainer $SASToken $LocalDirPath

if($result_UploadToBlob){
    Write-Host
    Write-Host "========================================================================================================================" -ForegroundColor DarkGreen
    Write-Host "                                           Completed Successfully" -ForegroundColor DarkGreen
    Write-Host "                                              Total Duration" -ForegroundColor DarkGreen
    Write-Host "                                            "$StopWatch.Elapsed -ForegroundColor DarkGreen
    Write-Host "========================================================================================================================" -ForegroundColor DarkGreen

}

