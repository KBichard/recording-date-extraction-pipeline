# OCR collection pipeline for document samples stored in county/document folders or ZIP archives.
# Public portfolio version: all paths are passed as parameters and no internal infrastructure is referenced.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputRoot,

    [Parameter(Mandatory = $true)]
    [string]$OutputRoot,

    [string]$Python = "python",
    [string]$OcrScript = ".\header_ocr.py",
    [int]$MaxDocsPerGroup = 10,
    [string[]]$GroupFolders = @()
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$TxtOutDir = Join-Path $OutputRoot "txt"
$WorkDir   = Join-Path $OutputRoot "work"
$PdfOutDir = Join-Path $OutputRoot "source_docs"

New-Item -ItemType Directory -Force -Path $TxtOutDir | Out-Null
New-Item -ItemType Directory -Force -Path $WorkDir   | Out-Null
New-Item -ItemType Directory -Force -Path $PdfOutDir | Out-Null

function Get-LatestZip {
    param ([string]$Path)

    if (-not (Test-Path $Path)) { return $null }

    Get-ChildItem $Path -Filter *.zip |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

if ($GroupFolders.Count -eq 0) {
    $GroupFolders = Get-ChildItem -Path $InputRoot -Directory | Select-Object -ExpandProperty Name
}

Write-Host "`n==== OCR COLLECTION START ===="

foreach ($group in $GroupFolders) {
    Write-Host "`nGroup: $group"

    $groupPath = Join-Path $InputRoot $group
    $zipFile = Get-LatestZip $groupPath

    if (-not $zipFile) {
        Write-Host "  No ZIP found"
        continue
    }

    Write-Host "  ZIP: $($zipFile.Name)"
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipFile.FullName)

    try {
        $entries = $zip.Entries |
            Where-Object { $_.Name -match '\.(pdf|tif|tiff)$' } |
            Sort-Object Name -Descending |
            Select-Object -First $MaxDocsPerGroup

        foreach ($entry in $entries) {
            $docId = [System.IO.Path]::GetFileNameWithoutExtension($entry.Name)
            $imgPath = Join-Path $WorkDir $entry.Name
            $txtPath = Join-Path $TxtOutDir "$docId.txt"
            $archivedPath = Join-Path $PdfOutDir $entry.Name

            Write-Host "  OCR: $($entry.Name)"

            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $imgPath, $true)
            Copy-Item $imgPath $archivedPath -Force

            $ocrText = & $Python $OcrScript $imgPath
            $ocrText | Out-File -FilePath $txtPath -Encoding UTF8

            Remove-Item $imgPath -Force
        }
    }
    finally {
        $zip.Dispose()
    }
}

Write-Host "`n==== OCR COLLECTION COMPLETE ===="
