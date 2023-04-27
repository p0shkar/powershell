#requires -Modules ActiveDirectory, dbatools

#region | RUN ONCE: CREATE DBA ROLE GROUP
New-ADGroup -Name "SQL-DBA" -Description "Ger sysadmin behörighet i SQL på alla servrar" -Path "OU=Roles,DC=domain,DC=com" -GroupCategory Security -GroupScope Global -Verbose
#endregion | RUN ONCE: CREATE DBA ROLE GROUP

param (
    [Parameter(Mandatory = $true)][string]$Server,
    [Parameter(Mandatory = $false)][string]$Domain = $env:USERDOMAIN,
    [Parameter(Mandatory = $false)][string]$SQLGroupPrefix = "SQL",
    [Parameter(Mandatory = $false)][string]$SQLGroupPath = "OU=Grupper,DC=domain,DC=com",
    [Parameter(Mandatory = $false)][string]$RoleGroupName = "SQL-DBA",
    [Parameter(Mandatory = $false)][string]$RoleGroupPath = "OU=Roles,DC=domain,DC=com"
)

#region | CREATE SERVER AD-GROUP
New-ADGroup -Name "$SQLGroupPrefix-$($Server.ToUpper())-Sysadmin" -Description "Ger sysadmin behörighet i SQL på $Server" -Path $SQLGroupPath -GroupCategory Security -GroupScope Global -Verbose
#endregion | CREATE SERVER AD-GROUP

#region | ADD DBA GROUP TO THE SERVER SYSADMIN GROUP
Get-ADGroup -Identity "CN=$SQLGroupPrefix-$($Server.ToUpper())-Sysadmin,$SQLGroupPath" | Add-ADGroupMember -Members "CN=$RoleGroupName,$RoleGroupPath" -Verbose
#endregion | ADD DBA GROUP TO THE SERVER SYSADMIN GROUP

#region | ADD SERVER SYSADMIN LOGIN AND ROLE
New-DbaLogin -SqlInstance $Server -Login "$Domain\$SQLGroupPrefix-$($Server.ToUpper())-Sysadmin"
Add-DbaServerRoleMember -SqlInstance $Server -ServerRole sysadmin -Login "$Domain\$SQLGroupPrefix-$($Server.ToUpper())-Sysadmin" -Confirm:$false
#endregion | ADD SERVER SYSADMIN LOGIN AND ROLE

foreach($Database in Get-DbaDatabase -SqlInstance $Server -ExcludeSystem){
    #region | CREATE DATABASE AD-GROUPS
    New-ADGroup -Name "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Read" -Description "Ger db_datareader behörighet till SQL Databasen $($Database.Name) på $Server" -Path $SQLGroupPath -GroupCategory Security -GroupScope Global -Verbose
    New-ADGroup -Name "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Write" -Description "Ger db_datawriter & db_datareader behörighet till SQL Databasen $($Database.Name) på $Server" -Path $SQLGroupPath -GroupCategory Security -GroupScope Global -Verbose
    New-ADGroup -Name "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Owner" -Description "Ger db_owner behörighet till SQL Databasen $($Database.Name) på $Server" -Path $SQLGroupPath -GroupCategory Security -GroupScope Global -Verbose
    #endregion | CREATE DATABASE AD-GROUPS

    #region | ADD DB READER LOGIN AND ROLE
    New-DbaLogin -SqlInstance $Server -Login "$Domain\$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Read"
    New-DbaDbUser -SqlInstance $Server -Database $Database.Name -Login "$Domain\$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Read" -Username "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Read"
    Add-DbaDbRoleMember -SqlInstance $Server -Database $Database.Name -User "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Read" -Role db_datareader -Confirm:$false
    #endregion | ADD DB READER LOGIN AND ROLE

    #region | ADD DB WRITER LOGIN AND ROLE
    New-DbaLogin -SqlInstance $Server -Login "$Domain\$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Write"
    New-DbaDbUser -SqlInstance $Server -Database $Database.Name -Login "$Domain\$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Write" -Username "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Write"
    Add-DbaDbRoleMember -SqlInstance $Server -Database $Database.Name -User "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Write" -Role db_datareader -Confirm:$false
    Add-DbaDbRoleMember -SqlInstance $Server -Database $Database.Name -User "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Write" -Role db_datawriter -Confirm:$false
    #endregion | ADD DB WRITER LOGIN AND ROLE

    #region | ADD DB OWNER LOGIN AND ROLE
    New-DbaLogin -SqlInstance $Server -Login "$Domain\$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Owner"
    New-DbaDbUser -SqlInstance $Server -Database $Database.Name -Login "$Domain\$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Owner" -Username "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Owner"
    Add-DbaDbRoleMember -SqlInstance $Server -Database $Database.Name -User "$SQLGroupPrefix-$($Server.ToUpper())-$($Database.Name)-Owner" -Role db_owner -Confirm:$false
    #endregion | ADD DB OWNER LOGIN AND ROLE
}
