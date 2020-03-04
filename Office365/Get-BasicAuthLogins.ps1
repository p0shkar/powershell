<#
.NAME
    Get-BasicAuthLogins
.SYNOPSIS
    Get recent logins from the Office 365 Security & Compliance Audit log which authenticates using Basic/Legacy Authentication.
.DESCRIPTION
    Get recent logins from the Office 365 Security & Compliance Audit log which authenticates using Basic/Legacy Authentication.

    Please suggest to me if you have a better name than "AuthMethod" and "DeviceOrProtocol" for those properties.

    Disclaimer: In the current version it is not totally clear if the search parameters used in this script returns 100% of
    basic auth types and if all of the returned auth types are indeed Basic Auth. However, modern auth types seems to reside
    in the operation "UserLoggedIn" and get workload "AzureActiveDirectory".

    This script uses ExchangeOnlineManagement (Exchange Online PowerShell V2) module to connect to EXO.
    This is still in Preview, use V1 if you prefer.
    https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/exchange-online-powershell-v2/exchange-online-powershell-v2

    This script uses the ImportExcel module to export the results, remove this and uncomment the rows above to print to screen or
    export to CSV instead. https://github.com/dfinke/ImportExcel
.NOTES
    Version:        1.0
    Author:         Oskar Noren
    Creation Date:  2020-03-03
#>

#----[ PARAMS ]----#
param(
    [Parameter(Mandatory = $false)][int]$DaysAgoStart = 1,
    [Parameter(Mandatory = $false)][int]$DaysAgoEnd = 0,
    [Parameter(Mandatory = $false)][int]$ResultSize = 5000,
    [Parameter(Mandatory = $false)][String[]]$Operations = "MailboxLogin", #"UserLoggedIn",
    [Parameter(Mandatory = $false)][String]$FileName = (Join-Path -Path $env:Temp -ChildPath "$(Get-Date -f "yyMMdd-HHmmss")-AuditLog")
)

#----[ CONNECT TO EXO ]----#
#require module: ExchangeOnlineManagement
if (!(Get-PSSession | ? { $_.ComputerName -eq "outlook.office365.com" -and $_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened" })) {
    Connect-ExchangeOnline
}

#----[ VARIABLES ]----#
$StartDate = ((Get-Date).AddDays(-$DaysAgoStart)).ToUniversalTime()
$EndDate = ((Get-Date).AddDays(-$DaysAgoEnd)).ToUniversalTime()

#----[ GET RESULT ]----#
$SearchResult = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -Formatted -ResultSize $ResultSize -Operations $Operations
$FilteredResult = $SearchResult | Select-Object -ExpandProperty AuditData | ConvertFrom-Json |
    Select CreationTime, Operation, RecordType, ResultStatus, Workload, UserId,
        @{N = "AuthMethod"; E = { (($_.ClientInfoString -split "=", 0)[1] -split ";")[0] } },
        @{N = "DeviceOrProtocol"; E = { (($_.ClientInfoString -split "=", 2)[1] -split ";", 2).TrimStart(" ")[1] } }

#----[ REPORT CONSOLE ]----#
#$FilteredResult | ft -AutoSize -Wrap

#----[ REPORT CSV ]----#
#$FilteredResult | Export-CSV -Path ($FileName + ".csv" ) -NoTypeInformation -Encoding Unicode
#& $FilePath

#----[ REPORT XLSX ]----#
#require module: ImportExcel
$FilteredResult | Export-Excel -Path ($FileName + ".xlsx") -WorksheetName $FileName -AutoFilter -AutoSize -FreezeTopRow -BoldTopRow -Show