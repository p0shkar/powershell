function Test-MSOLConnection {
    Get-MsolDomain -ErrorAction SilentlyContinue | Out-Null
    $Result = $?
    return $Result
}

function Test-EXOConnection {
    if (!(Get-PSSession | ? { $_.ComputerName -eq "outlook.office365.com" -and $_.ConfigurationName -eq "Microsoft.Exchange" -and $_.State -eq "Opened" })) {
        return $false
    }
    else{
        return $true
    }
}

function Test-AADConnection {
    try{
        $SessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction SilentlyContinue
        return $true
    }
    catch{
        return $false
    }
}

function Get-CurrentUserEmail {
    (([ADSI]"LDAP://$(whoami /fqdn)").mail).ToString()
}