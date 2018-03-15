$Global:GroupList = @()

function Get-AdGroupMemberRecurse {

<#
.SYNOPSIS
This is a simple Powershell Script to retrieve all nested groups for an AD account. 
.DESCRIPTION
The script uses Get-AdGroupMember to collect all associated groups for a parent group. The found groups are added to a global Variable $global:GroupList
.EXAMPLE
Get-AdGroupMemberRecurse -identity <Group Name>
.LINK
https://github.com/ChrisMandich/RandomPowershellScripts
#>

    Param (
        [Parameter(ValueFromPipeline=$true)]
        $Identity
    )

    $GROUP = Get-ADGroupMember -Identity $Identity.toString() | where objectClass -eq "group" 

    #check to see if the group is empty. If it is empty add the current group to the list. 
    if($Global:GroupList.Count -eq 0){
        $Global:GroupList += Get-ADGroup -Identity $Identity 
    }

    #Iterate through group variable and add child groups to the global variable. 
    $GROUP | ForEach-Object {
        if($_.objectClass -eq "group" -and $Global:GroupList.name.contains($_.name) -eq $false){
            $Global:GroupList += $_
            #Recursively check new groups. 
            Get-AdGroupMemberRecurse -Identity $_.name
        }
    }
    
    #Output to console
    Write-Output $Global:GroupList
}