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

    Get-ChildItem -Path $Path -Recurse -Directory | ForEach-Object { $_.FullName.Replace($PathParent + [IO.Path]::DirectorySeparatorChar, '') } | Sort-Object
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