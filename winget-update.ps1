<#
  .SYNOPSIS
    by default the winget upgrades all the apps I dint want that and there is exclude options
  .DESCRIPTION
    This script mitigate the required exclude option in winget
  .EXCLUDE
    This argument takes array of strings to exclude during the upgrade, should take either the id or name of application
#>

[CmdletBinding()]

param(
  [Parameter()]
  [string[]]$Exclude
)
#TODO do id validation for applications
#TODO try implementing the select application like a cli tool
#TODO Remove the crap that gets store while checking for updates
$appIds=@()


try
{
  if( Get-Command -Name winget -ErrorAction SilentlyContinue)
  {
    $updates = winget update
    if( $null -ne $updates)
    {
      Write-Output 'The below mentioned apps will be excluded if they have updates available' $Exclude
      $updatesList = $updates | ForEach-Object{
        if($PSItem.Contains('.'))
        {
          return $PSItem
        }
      }
      $updatesList.Split(' ') | ForEach-Object {
        if(($PSItem -match "\W") -and ($psitem -notmatch "\d{1,}.\d{1,}.\d{1,}"))
        {
          $ids = $PSItem

          if(((winget search --id $Id) -match "No package") -and ($PSItem -ne "-"))
          {
            return $false
          } else
          {
            $appIds+=$ids
          }
        }
      }
    }
  }
  write-output $appIds
  $appIds | ForEach-Object{
    if($PSItem -notin $Exclude)
    {
      Write-Output "Updating $PSItem...."
      Winget update --id $PSItem
    }
  }
} catch
{
  Write-Error -Message $_.msg
}
