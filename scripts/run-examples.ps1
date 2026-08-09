<##
.SYNOPSIS
    Opens every catalog example in order, waiting for each one to be closed.

.DESCRIPTION
    The example window (or console program) is launched through the repository
    build so the SDL runtime DLLs and example assets are configured correctly.
    Close the current example to advance to the next one. If an example fails
    to build or start, press Enter to continue or Ctrl+C to stop the sequence.

.PARAMETER StartAt
    Optional example name at which to begin.

.PARAMETER Filter
    Optional wildcard filter applied to example names.
##>
param(
    [string]$StartAt,
    [string]$Filter = "*"
)

$ErrorActionPreference = "Stop"
$repository = Split-Path -Parent $PSScriptRoot
Push-Location $repository
try {
    # Native Windows installs from Visual Studio may not put CMake on PATH.
    $cmakeDirectories = @(
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin"
    )
    foreach ($directory in $cmakeDirectories) {
        if (Test-Path (Join-Path $directory "cmake.exe")) {
            $env:Path = "$directory;$env:Path"
            break
        }
    }

    $catalogOutput = & zig build examples-list 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Could not list examples (zig exit code $LASTEXITCODE)."
    }

    $names = @(
        $catalogOutput |
            ForEach-Object {
                if ($_ -match '^\s{4}(\S+)\s+examples[\\/]') { $Matches[1] }
            } |
            Where-Object { $_ -like $Filter }
    )
    if ($names.Count -eq 0) { throw "No examples matched filter '$Filter'." }

    if ($StartAt) {
        $startIndex = [Array]::IndexOf($names, $StartAt)
        if ($startIndex -lt 0) { throw "Unknown or filtered-out example '$StartAt'." }
        $names = $names[$startIndex..($names.Count - 1)]
    }

    Write-Host "Running $($names.Count) examples in catalog order." -ForegroundColor Cyan
    Write-Host "Close each example window to continue; press Ctrl+C to stop.`n"

    for ($index = 0; $index -lt $names.Count; $index++) {
        $name = $names[$index]
        Write-Host ("[{0}/{1}] {2}" -f ($index + 1), $names.Count, $name) -ForegroundColor Yellow
        & zig build "run-$name"
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            Write-Host "  startup/build exited with code $exitCode" -ForegroundColor Red
            Read-Host "  Press Enter to continue, or Ctrl+C to stop"
        }
        Write-Host ""
    }
    Write-Host "Finished the example sequence." -ForegroundColor Green
}
finally {
    Pop-Location
}
