
function Get-ADPrincipalGroupMembershipRecurse {

<#
.SYNOPSIS
This is a simple Powershell Script to retrieve all parents groups for an AD group. 
.DESCRIPTION
The script uses Get-ADPrincipalGroupMembership to collect all parent groups for a group.
.EXAMPLE
Get-ADPrincipalGroupMembershipRecurse -identity <Group Name>
.LINK
https://github.com/ChrisMandich/RandomPowershellScripts
#>

    Param (
        [Parameter(ValueFromPipeline=$true)]
        $Identity
    )

    $Identity = Get-ADGroup -Identity $Identity -ErrorAction Stop
    
    function Add-ADPrincipalGroupList{
        Param (
            $Identity
        )
        
        #Write identity out and add it to list. 
        Write-Output $Identity
        $Global:PrincipalGroupList += $Identity
        
        #Check for groups in group
        $GROUP = Get-ADPrincipalGroupMembership -Identity $Identity.DistinguishedName | where objectClass -eq "group"

        #Check new groups for child groups
        $GROUP | ForEach-Object{Get-ADPrincipalGroupMembershipRecurse -Identity $_.DistinguishedName}
    }

    #check to see if the PrincipalGroupList has been created. If it has not been created, create and add identity. 
    if($(Test-Path Variable:\PrincipalGroupList) -eq $false){
        #Create Global Variable
        $Global:PrincipalGroupList = @()
        Add-ADPrincipalGroupList -Identity $Identity 
                 
    }
    elseif($Global:PrincipalGroupList.DistinguishedName.contains($Identity.DistinguishedName) -eq $false -and -not $(Test-Path Variable:\Identity) -eq $false){
        #if group is not in list, add to PrincipalGroupList. 
        Add-ADPrincipalGroupList -Identity $Identity 

        #Exit function
        return;        
    }   
    else{

        #Exit function 
        return;
    }    

    #Remove variable
    Remove-Item Variable:\PrincipalGroupList
    
    #Exit function
    Return;
}
