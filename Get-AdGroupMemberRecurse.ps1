
function Get-AdGroupMemberRecurse {

<#
.SYNOPSIS
This is a simple Powershell Script to retrieve all nested groups for an AD account.
.DESCRIPTION
The script uses Get-AdGroupMember to collect all associated groups for a parent group. The found groups are returned.
.EXAMPLE
Get-AdGroupMemberRecurse -identity <Group Name>
.LINK
https://github.com/ChrisMandich/RandomPowershellScripts
#>

    Param (
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $Identity
    )

    $Identity = Get-ADGroup -Identity $Identity

    function Add-ADGroupList{
        Param (
            $Identity
        )

        #Write identity out and add it to list.
        Write-Output $Identity
        $Global:GroupList += $Identity

        #Check for groups in group
        $GROUP = Get-ADGroupMember -Identity $Identity.DistinguishedName | where objectClass -eq "group"

        #Check new groups for child groups
        $GROUP | ForEach-Object{Get-AdGroupMemberRecurse -Identity $_.DistinguishedName}
    }

    #check to see if the grouplist has been created. If it has not been created, create and add identity.
    if($(Test-Path Variable:\GroupList) -eq $false){
        #Create Global Variable
        $Global:GroupList = @()
        Add-ADGroupList -Identity $Identity

    }
    elseif($Global:GroupList.DistinguishedName.contains($Identity.DistinguishedName) -eq $false -and -not $(Test-Path Variable:\Identity) -eq $false){
        #if group is not in list, add to grouplist.
        Add-ADGroupList -Identity $Identity

        #Exit function
        return;
    }
    else{

        #Exit function
        return;
    }

    #Remove variable
    Remove-Item Variable:\GroupList

    #Exit function
    Return;
}
