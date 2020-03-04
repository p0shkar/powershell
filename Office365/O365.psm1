function Get-MSOLSessionState {
    Get-MsolDomain -ErrorAction SilentlyContinue | Out-Null
    $Result = $?
    return $Result
}

function Get-EXOSessionState {
    if (!(Get-PSSession | ? { $_.ComputerName -eq "outlook.office365.com" -and $_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened" })) {
        return $false
    }
    else{
        return $true
    }
}

function Get-CurrentUserEmail {
    (([ADSI]"LDAP://$(whoami /fqdn)").mail).ToString()
}