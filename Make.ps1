<#
.Synopsis

.Description
 
.Parameter   
#>


# === Check if Makefile.txt exists ===
$dir = "$(Get-Location)\"
$path = "$($dir)Makefile.txt"
if(-not (Test-Path -LiteralPath $path)) {
    Write-Host "No Makefile.txt in current working directory ($dir) found!" -ForegroundColor Red
    exit
}

# === Read and process Makefile ===

# Data structures
$macros = @{} # maps every macro to its content
$phony = @() # list of all phony targets
$target = @() # list of all targets
$dependencies = @() # list of lists of all dependencies
$command = @() # list of all commands

$lines = Get-Content -LiteralPath $path -Force
$count = 0

# Read macros
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Length -eq 0) {
        # end of macro section reached
        $count++
        break
    }
    $tokens = $($lines[$i]).Split("=")
    if (-not ($tokens.Length -eq 2)) {
        Write-Host "Syntax error in line $($i + 1): $($lines[$i])" -ForegroundColor Red
        exit
    }
    $macros.Add($tokens[0], $tokens[1])
    $count++
}

# Skip blanck lines
for ($i = $count; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Length -eq 0) {
        $count++
    } else {
        break
    }
}

# Read optional .PHONY
if ($lines[$count] -like ".PHONY=*") {
    $l = $lines[$count] -replace ".PHONY="
    $phony = $l.Split(",")
    $count++
}

# Skip blanck lines
for ($i = $count; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Length -eq 0) {
        $count++
    } else {
        break
    }
}

# Read build rules
for ($i = $count; $i -lt $lines.Length; $i++) {
    # skip blanks
    if ($lines[$i].Length -eq 0) {
        $count++
        continue
    }
    # Process line
    $rest = $lines[$i]
    $start = 0
    $end = $rest.IndexOf('[')
    if ($end -lt 1) {
        Write-Host "Syntax error in line $($i + 1): $($lines[$i])" -ForegroundColor Red
        exit
    }
    $target += $rest.Substring($start, $end)
    $rest = $rest.Remove($start, $end)

    $start = $end + 1
    $end = $rest.IndexOf(']')
    if ($end -lt 1) {
        Write-Host "Syntax error in line $($i + 1): $($lines[$i])" -ForegroundColor Red
        exit
    }
    if ($end -ge $rest.Length) {
        continue
    }
    $ds = $rest.Substring($start, $end)
    Write-Host "$ds"
    $rest = $rest.Remove($start, $end)
}