param(
    [string]$Destination
)

$ErrorActionPreference = "Stop"

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if ([string]::IsNullOrWhiteSpace($Destination)) {
    $DistDir = Join-Path $ProjectRoot "dist"
    New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $Destination = Join-Path $DistDir "qr_coder_source_$Timestamp.zip"
}
elseif (-not [System.IO.Path]::IsPathRooted($Destination)) {
    $Destination = Join-Path $ProjectRoot $Destination
}

$Destination = [System.IO.Path]::GetFullPath($Destination)
$DestinationParent = Split-Path -Parent $Destination
New-Item -ItemType Directory -Force -Path $DestinationParent | Out-Null

$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) (
    "qr_coder_source_" + [guid]::NewGuid().ToString("N")
)
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

$ExcludedDirectoryNames = @(
    ".git",
    ".dart_tool",
    ".gradle",
    ".idea",
    ".vscode",
    "build",
    "dist",
    "coverage",
    "Pods",
    "ephemeral",
    ".symlinks"
)

$ExcludedExactPaths = @(
    ".env",
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    "android/key.properties",
    "android/local.properties",
    "android/app/google-services.json",
    "ios/Flutter/.last_build_id",
    "ios/Flutter/Generated.xcconfig",
    "ios/Flutter/flutter_export_environment.sh",
    "ios/Runner/GoogleService-Info.plist"
)

$ExcludedExtensions = @(
    ".jks",
    ".keystore",
    ".apk",
    ".aab",
    ".apks"
)

function Normalize-RelativePath([string]$Path) {
    return $Path.Replace("\", "/")
}

function Should-ExcludeDirectory([string]$RelativePath) {
    $Normalized = Normalize-RelativePath $RelativePath
    $Segments = $Normalized.Split("/")

    foreach ($Segment in $Segments) {
        if ($ExcludedDirectoryNames -contains $Segment) {
            return $true
        }
    }

    return $false
}

function Should-Exclude([string]$RelativePath) {
    $Normalized = Normalize-RelativePath $RelativePath

    if (Should-ExcludeDirectory $Normalized) {
        return $true
    }

    if ($ExcludedExactPaths -contains $Normalized) {
        return $true
    }

    $Leaf = Split-Path $Normalized -Leaf
    if ($Leaf.StartsWith(".env") -and $Normalized -ne ".env.example") {
        return $true
    }

    if ($Leaf -like "GeneratedPluginRegistrant.*") {
        return $true
    }

    $Extension = [System.IO.Path]::GetExtension($Leaf).ToLowerInvariant()
    if ($ExcludedExtensions -contains $Extension) {
        return $true
    }

    return $false
}

function Get-SourceFiles([string]$Directory) {
    foreach ($Item in Get-ChildItem -LiteralPath $Directory -Force -ErrorAction Stop) {
        if ($Item.PSIsContainer) {
            $RelativeDirectory = $Item.FullName.Substring($ProjectRoot.Length).TrimStart("\", "/")

            # Prune generated/transient directories before descending into them.
            # This avoids races with Gradle/Flutter deleting build outputs while
            # the archive is being created.
            if (Should-ExcludeDirectory $RelativeDirectory) {
                continue
            }

            Get-SourceFiles $Item.FullName
            continue
        }

        Write-Output $Item
    }
}

try {
    Get-SourceFiles $ProjectRoot |
        ForEach-Object {
            $Relative = $_.FullName.Substring($ProjectRoot.Length).TrimStart("\", "/")

            if (Should-Exclude $Relative) {
                return
            }

            $Target = Join-Path $TempRoot $Relative
            $TargetDir = Split-Path -Parent $Target
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            Copy-Item -LiteralPath $_.FullName -Destination $Target
        }

    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Force
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $TempRoot,
        $Destination,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false
    )

    # Verify the archive itself contains no forbidden local/signing files.
    $Archive = [System.IO.Compression.ZipFile]::OpenRead($Destination)
    try {
        foreach ($Entry in $Archive.Entries) {
            $EntryPath = Normalize-RelativePath $Entry.FullName

            if (
                $EntryPath -eq ".env" -or
                $EntryPath -eq "android/key.properties" -or
                $EntryPath -eq "android/local.properties" -or
                $EntryPath -eq "android/app/google-services.json" -or
                $EntryPath -eq "ios/Runner/GoogleService-Info.plist" -or
                $EntryPath -eq ".flutter-plugins" -or
                $EntryPath -eq ".flutter-plugins-dependencies" -or
                $EntryPath -eq "ios/Flutter/Generated.xcconfig" -or
                $EntryPath -eq "ios/Flutter/flutter_export_environment.sh" -or
                $EntryPath.Contains("/ephemeral/") -or
                $EntryPath.EndsWith(".jks") -or
                $EntryPath.EndsWith(".keystore")
            ) {
                throw "Unsafe file found in source archive: $EntryPath"
            }
        }
    }
    finally {
        $Archive.Dispose()
    }

    Write-Host "Safe source archive created:"
    Write-Host $Destination
}
finally {
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
}
