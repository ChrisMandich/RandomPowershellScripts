$Global:PrincipalGroupList = @()

function Get-ADPrincipalGroupMembershipRecurse {

<#
.SYNOPSIS
This is a simple Powershell Script to retrieve all parents groups for an AD group. 
.DESCRIPTION
The script uses Get-ADPrincipalGroupMembership to collect all parent groups for a group. The found groups are added to a global Variable $global:PrincipalGroupList
.EXAMPLE
Get-ADPrincipalGroupMembershipRecurse -identity <Group Name>
.LINK
https://github.com/ChrisMandich/RandomPowershellScripts
#>

    Param (
        [Parameter(ValueFromPipeline=$true)]
        $Identity
    )

    $GROUP = Get-ADGroupMember -Identity $Identity.toString() | where objectClass -eq "group" 

    #check to see if the group is empty. If it is empty add the current group to the list. 
    if($Global:PrincipalGroupList.Count -eq 0){
        $Global:PrincipalGroupList += Get-ADPrincipalGroupMembership -Identity $Identity 
    }

    #Iterate through group variable and add parent groups to the global variable. 
    $GROUP | ForEach-Object {
        if($_.objectClass -eq "group" -and $Global:PrincipalGroupList.name.contains($_.name) -eq $false){
            $Global:PrincipalGroupList += $_
            #Recursively check new groups. 
            Get-ADPrincipalGroupMembershipRecurse -Identity $_.name
        }
    }
    
    #Output to console
    Write-Output $Global:PrincipalGroupList
}