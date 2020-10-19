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
# Version:        1.1
# Author:         jessica.johnson@microsoft.com
# Last Update :   10-18-2020
##############################################################

$orig_execution_policy =  Get-ExecutionPolicy
$azblob_sas_token = '?sv=2019-12-12&ss=bfqt&srt=sco&sp=rwdlacupx&se=2020-10-21T09:30:12Z&st=2020-10-19T01:30:12Z&spr=https&sig=6HGaWAW6u2pw4vh8DY15GMp%2F1YhUaXggR8xaUwlE8Lo%3D'
$azblob_storage_acct = 'jejohndemoblob'
$azblob_storage_acct_container = 'azcopy-demo'
$azblob_storage_container_endpoint = "https://$azblob_storage_acct.blob.core.windows.net/$azblob_storage_acct_container"

# DEBUG - Print Current Execution Policy.
#Write-Host "---------[[DEBUG]] Current Execution Policy = $orig_execution_policy"

# Check proper Execution Policy is set to run script.
if($orig_execution_policy -ne "RemoteSigned"){
    Set-ExecutionPolicy RemoteSigned -Force
}

# Prompt user for local file path for files that will be uploaded to Blob.
[string]$local_file_path = Read-Host -Prompt 'Local File Path: '

# DEBUG - Print user input for local file path.
#Write-Host "---------[[DEBUG]] Local File Path = $local_file_path"

# Check user input local file path exists before moving on.
if(-not(Test-Path -Path "$local_file_path")){
    Write-Host "!! Error '$local_file_path' does not exist !!"
    #exit 1
}
else{

    # Get only CSV files in local file path and loop through result list.
    Get-ChildItem -Path "$local_file_path" -Filter *.csv |

    ForEach-Object {
        
        # Create dynamic azure blob storage container path for current file.
        $azblob_path = "$azblob_storage_container_endpoint/$($_.BaseName)/$azblob_sas_token"

        # DEBUG - Print user input for local file path.
        #Write-Host "---------[[DEBUG]] Azure Blob Storage Path = $azblob_path"
   
        # Use AzCopy to copy current local file to azure blob storage path.
        azcopy cp $('"' + $_.FullName + '"') $('"' + $azblob_path + '"')

        Write-Host "[LOG] Successfully copied '$($local_file_path)\$_' to '$azblob_storage_container_endpoint/$($_.BaseName)/$_'"
      }
}

