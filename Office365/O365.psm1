function Test-MSOLConnection {
    Get-MsolDomain -ErrorAction SilentlyContinue | Out-Null
    $Result = $?
    return $Result
}

function Test-EXOConnection {
    if (!(Get-PSSession | ? { $_.ComputerName -eq "outlook.office365.com" -and $_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened" })) {
        return $false
    }
    else {
        return $true
    }
}

function Test-AADConnection {
    try {
        $SessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction SilentlyContinue
        return $true
    }
    catch {
        return $false
    }
}

function Get-CurrentUserEmail {
    (([ADSI]"LDAP://$(whoami /fqdn)").mail).ToString()
}

function Get-MailboxLocation {
    param(
        [Parameter(Mandatory = $true)][Microsoft.Online.Administration.User[]]$MSOLUsers,
        [switch]$OnlyCloud,
        [switch]$OnlyOnPrem
    )

    $Report = $MSOLUsers |
    Select-Object -Property DisplayName, UserPrincipalName,
    @{Label = 'MailboxLocation'; Expression = {
            switch ($_.MSExchRecipientTypeDetails) {
                1 { 'OnPrem'; break }
                2147483648 { 'Office365'; break }
                default { 'Unknown' }
            }
        }
    },
    @{Label = 'Enabled'; Expression = {
            switch ($_.BlockCredential) {
                true { $false; break }
                false { $true; break }
                default { 'Unknown' }
            }
        }
    },
    isLicensed, Licenses

    if ($OnlyCloud) {
        return ($Report | ? { $_.MailboxLocation -eq "Office365" })
    }
    elseif ($OnlyOnPrem) {
        return ($Report | ? { $_.MailboxLocation -eq "OnPrem" })
    }
    else {
        return $Report
    }
}