#Requires -RunAsAdministrator

Write-Verbose -Verbose -Message ""
Write-Verbose -Verbose -Message "Updating Modules..."
Write-Verbose -Verbose -Message ""
Get-Module -ListAvailable | ?{$_.RepositorySourceLocation -ne $null} | %{
    Write-Verbose -Verbose -Message "Updating Module `"$($_.Name)`" ($($_.ModuleBase))..."
    Update-Module $_ -Confirm:$false #-Verbose
}

Write-Verbose -Verbose -Message ""
Write-Verbose -Verbose -Message "Updating Help..."
Write-Verbose -Verbose -Message ""
Get-Module -ListAvailable | %{
    Write-Verbose -Verbose -Message "Updating Help for module `"$($_.Name)`" ($($_.ModuleBase))..."
    Update-Help -Module $_.Name -Confirm:$false -ErrorAction SilentlyContinue #-Verbose
}