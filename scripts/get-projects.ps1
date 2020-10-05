[CmdletBinding()]
param
(
    [Parameter(ValueFromPipeline)]
    [int]
    $Index = -1
)

function GetProjects
{
    param([Parameter(Mandatory)][string]$Path)

    $PathParent = [IO.Path]::GetDirectoryName($Path)

    Get-ChildItem -Path $Path -Include @('wurqon.json') -Recurse | ForEach-Object { $_.DirectoryName.Replace($PathParent + [IO.Path]::DirectorySeparatorChar, '') }
}

$root = Resolve-Path '~/w'

$projects = GetProjects -Path $root

if ($Index -ge 0)
{
    [IO.Path]::Combine([IO.Path]::GetDirectoryName($root), $projects[$Index])
}
else
{
    $projects
}