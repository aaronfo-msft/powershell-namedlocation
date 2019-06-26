$NamedLocationsKey = "HKCU:\NamedLocations\"
$ReservedNames = "PSPath","PSParentPath","PSChildName","PSDrive","PSProvider"
function Enter-NamedLocation
{
	[alias("goto")]
    [alias("go")]
	param(
		[Parameter()]
		[string]
		$Name
	)

    if(!(Test-Path -Path $NamedLocationsKey) -or !(Get-ItemProperty -Path $NamedLocationsKey).$Name)
	{
		throw 'Named location "'+$Name+'" not found.'
	}

	Set-Location ((Get-ItemProperty -Path $NamedLocationsKey).$Name)
}

function Add-NamedLocation
{
	param(
		[ValidateScript({
			if($ReservedNames -contains $_) { throw 'Cannot used reserved name "'+$_+'"' } return $true
		})]
		[ValidateScript({
			if((Get-ItemProperty -Path $NamedLocationsKey).$_){throw 'Named location "'+$_+'" already exists.'}; return $true
		})]
		[Parameter(Position=0,Mandatory=$true)]
		[string] 
		$Name,
		
		[ValidateScript({
			if(!(Test-Path $_ -PathType Container)) { throw 'Directory "'+ $_ +'" does not exist.' }
		})]
		[Parameter(Position=1)]
		[string]
		$Path = (Get-Location).Path
	)
	if(!(Test-Path -Path $NamedLocationsKey))
	{
		New-Item -Path $NamedLocationsKey | Out-Null
	}
	
	Set-ItemProperty -Path $NamedLocationsKey -Name $Name -Value $Path
    Get-NamedLocation $Name
}

function Get-NamedLocation
{
    Param(
        $Name
    )

	if(!(Test-Path -Path $NamedLocationsKey))
	{
		return
	}

	(Get-ItemProperty -Path $NamedLocationsKey).PSObject.Properties | where { $ReservedNames -notcontains $_.Name -and (!$Name -or $_.Name -eq $Name) } | % { New-Object PSObject -Property @{
		Name=$_.Name
		Path=$_.Value
		}}
}

function Remove-NamedLocation
{
	param(
		[Parameter(Position=0,Mandatory=$true)]
		[string] 
		$Name
	)
	
	if(!(Test-Path -Path $NamedLocationsKey) -or !(Get-ItemProperty -Path $NamedLocationsKey).$Name)
	{
		throw 'Named location "'+$Name+'" not found.'
	}
	
	Remove-ItemProperty -Path $NamedLocationsKey -Name $Name
}

Export-ModuleMember -Function *-NamedLocation -Alias go,goto
