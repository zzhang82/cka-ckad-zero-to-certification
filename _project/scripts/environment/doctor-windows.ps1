param(
    [string]$DistroName = ''
)

$ErrorActionPreference = 'Continue'

$script:Failures = 0
$script:Warnings = 0

function Write-Pass([string]$Message) { Write-Host "PASS  $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { $script:Warnings++; Write-Host "WARN  $Message" -ForegroundColor Yellow }
function Write-Fail([string]$Message) { $script:Failures++; Write-Host "FAIL  $Message" -ForegroundColor Red }

try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

    if ($os.Caption -match 'Windows 11') { Write-Pass "$($os.Caption), build $($os.BuildNumber)" }
    else { Write-Fail "$($os.Caption), build $($os.BuildNumber); Windows 11 is the supported V1 host" }
    if ($cs.TotalPhysicalMemory -ge 16GB) { Write-Pass ("RAM {0:N1} GiB" -f ($cs.TotalPhysicalMemory / 1GB)) }
    else { Write-Fail ("RAM {0:N1} GiB; 16 GiB is the project floor" -f ($cs.TotalPhysicalMemory / 1GB)) }

    if ($cpu.VirtualizationFirmwareEnabled) { Write-Pass 'Firmware virtualization enabled' }
    else { Write-Fail 'Firmware virtualization is not enabled' }

    if ($cs.HypervisorPresent) { Write-Pass 'Windows hypervisor present' }
    else { Write-Fail 'Windows hypervisor not detected' }
} catch {
    Write-Fail "Unable to read Windows system information: $($_.Exception.Message)"
}

$requiredFeatures = @('VirtualMachinePlatform', 'Microsoft-Windows-Subsystem-Linux')

try {
    $features = Get-CimInstance Win32_OptionalFeature
    foreach ($name in $requiredFeatures) {
        $feature = $features | Where-Object Name -eq $name | Select-Object -First 1
        if ($feature -and $feature.InstallState -eq 1) { Write-Pass "$name enabled" }
        else { Write-Fail "$name is not enabled" }
    }

    $hyperV = $features | Where-Object Name -eq 'Microsoft-Hyper-V-All' | Select-Object -First 1
    if ($hyperV -and $hyperV.InstallState -eq 1) { Write-Pass 'Microsoft-Hyper-V-All enabled' }
    else { Write-Warn 'Full Hyper-V role is not enabled; Week 0 WSL/kind still works, but later disposable-node options may be limited' }
} catch {
    Write-Fail "Unable to inspect Windows optional features: $($_.Exception.Message)"
}

$projectDrive = (Get-Item -LiteralPath $PSScriptRoot).PSDrive.Name
$volume = Get-Volume -DriveLetter $projectDrive -ErrorAction SilentlyContinue
if ($volume) {
    if ($volume.SizeRemaining -ge 30GB) { Write-Pass ("${projectDrive}: free space {0:N1} GiB" -f ($volume.SizeRemaining / 1GB)) }
    else { Write-Warn ("${projectDrive}: free space {0:N1} GiB; keep at least 30 GiB free before multi-node labs" -f ($volume.SizeRemaining / 1GB)) }
}

$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wsl) {
    Write-Fail 'wsl.exe not found'
} else {
    $distros = (& wsl.exe --list --quiet 2>$null) -replace "`0", ''
    if ($DistroName) {
        if ($distros -contains $DistroName) { Write-Pass "$DistroName is installed and launched this check" }
        else { Write-Fail "$DistroName launched this check but is missing from wsl.exe --list" }
    } else {
        $ubuntu = $distros | Where-Object { $_ -match '^Ubuntu' } | Select-Object -First 1
        if ($ubuntu) { Write-Pass "$ubuntu is installed" }
        else { Write-Fail 'No Ubuntu WSL distribution is installed' }
    }
}

$dockerService = Get-Service com.docker.service -ErrorAction SilentlyContinue
if ($dockerService -and $dockerService.Status -eq 'Running') {
    Write-Warn 'Docker Desktop service is running; the canonical lane is native WSL Docker'
} else {
    Write-Pass 'Docker Desktop is not the active Windows service dependency'
}

$gh = Get-Command gh -ErrorAction SilentlyContinue
if ($gh) { Write-Pass "GitHub CLI found at $($gh.Source)" }
else { Write-Warn 'GitHub CLI not found; local Week 0 labs can still run' }

Write-Host "`nSummary: $script:Failures failure(s), $script:Warnings warning(s)"
if ($script:Failures -gt 0) { exit 1 }
exit 0
