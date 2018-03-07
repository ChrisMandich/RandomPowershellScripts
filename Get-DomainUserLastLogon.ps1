<#

.SYNOPSIS
This is a simple Powershell Script to get LastLogon time for a user. 

.DESCRIPTION
The script itself iterates through the global catalog servers for the current AD Forest and gets the LastLogon time for the user. The script returns an object containing the Hostname, DistinguishedName, Identity and LastLogon. 

.EXAMPLE
.\Get-DomainUserLastLogon.ps1 -identity username


.LINK


#>

param (
[string]$identity = $(throw "-identity is required.")
)

#Loop through Global Catalog Servers
(Get-ADForest).globalcatalogs | ForEach-Object{
    #Collect information about Computer and Last Logong 
    $test = $_ -match "^(?<hostname>[^\.]+)"
    $DC = Get-adcomputer -Identity $Matches.hostname -Server $_ -Properties DistinguishedName
    $LastLogon = try{(Get-ADUser -Identity $identity -Properties lastlogon -server $_ | Select-Object @{Name="LastLogon";Expression={[datetime]::FromFileTime($_.lastlogon)}}).LastLogon}catch{"n/a"}
    
    #Create Object for Domain User 
    $DomainUser = New-Object -TypeName psobject
    $DomainUser | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $Matches.hostname
    $DomainUser | Add-Member -MemberType NoteProperty -Name "DistinguishedName" -Value $DC.DistinguishedName
    $DomainUser | Add-Member -MemberType NoteProperty -Name "Identity" -Value $identity
    $DomainUser | Add-Member -MemberType NoteProperty -Name "LastLogon" -Value $LastLogon

    #Output Object for Domain User 
    Write-Output $DomainUser 
}
