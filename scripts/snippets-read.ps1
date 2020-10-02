param (
    [Parameter(ValueFromPipeline)]
    [string]
    $Key
)

function GetParentProjectFilenames
{
    param ([Parameter(Mandatory)][string]$Path)

    $result = @()

    $filePath = [IO.Path]::Combine($Path, 'wurqon.json')

    if ([IO.File]::Exists($filePath))
    {
        $result += $filePath

        $parentPath = [IO.Path]::GetDirectoryName($Path)
        if ($null -ne $parentPath)
        {
            $parents = GetParentProjectFilenames -Path $parentPath
            $result += $parents
        }
    }

    return $result
}

function GetSnippets
{
    param([Parameter(Mandatory)][string]$RootDirectory, [Parameter(Mandatory)][string[]]$Paths)
    
    $hashtable = @{}

    $Paths |
        ForEach-Object {
            $currentSubdirectoryRelativePath = [IO.Path]::GetDirectoryName($_) -replace "$RootDirectory$([IO.Path]::DirectorySeparatorChar)?", ''
            $directoryNames = $currentSubdirectoryRelativePath.Split([IO.Path]::DirectorySeparatorChar)
            
            (Get-Content $_ | ConvertFrom-Json).snippets.PSObject.Properties | ForEach-Object {
                $hierarchy = if ([string]::IsNullOrEmpty($directoryNames)) { $_.Name } else { $directoryNames + $_.Name }
                $key = [string]::Join('.', $hierarchy)  
                $hashtable[$key] = $_.Value
            }
        } |
        Out-Null
    
    $hashtable
}

function FormatFixedWidth
{
    param([Parameter(Mandatory)][string]$Value, [Parameter(Mandatory)][int]$Length)

    if ($Value.Length -gt $Length)
    {
        $Value.Substring(0, $Length - 3) + '...'
    }
    else
    {
        $Value.PadRight($Length)
    }
}

$rootDirectory = if ($null -ne [Environment]::GetEnvironmentVariable('WQDR')) { $env:WQDR } else { [IO.Path]::Combine($env:HOME, 'w') }
$currentDirectory = if ($null -ne [Environment]::GetEnvironmentVariable('WQDC')) { $env:WQDC } else { [IO.Path]::Combine($env:HOME, 'w', 'amerisure') }

$filePaths = GetParentProjectFilenames -Path $currentDirectory

$snippets = GetSnippets -RootDirectory $rootDirectory -Paths $filePaths

if ([string]::IsNullOrEmpty($Key))
{
    $snippets.GetEnumerator() | ForEach-Object { $_.Name }
}
else
{
    $snippets[$Key]
}