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

    Write-Pass "$($os.Caption), build $($os.BuildNumber)"
    if ($cs.TotalPhysicalMemory -ge 16GB) { Write-Pass ("RAM {0:N1} GiB" -f ($cs.TotalPhysicalMemory / 1GB)) }
    else { Write-Fail ("RAM {0:N1} GiB; 16 GiB is the project floor" -f ($cs.TotalPhysicalMemory / 1GB)) }

    if ($cpu.VirtualizationFirmwareEnabled) { Write-Pass 'Firmware virtualization enabled' }
    else { Write-Fail 'Firmware virtualization is not enabled' }

    if ($cs.HypervisorPresent) { Write-Pass 'Windows hypervisor present' }
    else { Write-Fail 'Windows hypervisor not detected' }
} catch {
    Write-Fail "Unable to read Windows system information: $($_.Exception.Message)"
}

$requiredFeatures = @(
    'Microsoft-Hyper-V-All',
    'VirtualMachinePlatform',
    'Microsoft-Windows-Subsystem-Linux'
)

try {
    $features = Get-CimInstance Win32_OptionalFeature
    foreach ($name in $requiredFeatures) {
        $feature = $features | Where-Object Name -eq $name | Select-Object -First 1
        if ($feature -and $feature.InstallState -eq 1) { Write-Pass "$name enabled" }
        else { Write-Fail "$name is not enabled" }
    }
} catch {
    Write-Fail "Unable to inspect Windows optional features: $($_.Exception.Message)"
}

$d = Get-Volume -DriveLetter D -ErrorAction SilentlyContinue
if ($d) {
    if ($d.SizeRemaining -ge 60GB) { Write-Pass ("D: free space {0:N1} GiB" -f ($d.SizeRemaining / 1GB)) }
    else { Write-Warn ("D: free space {0:N1} GiB; prune images before multi-node labs" -f ($d.SizeRemaining / 1GB)) }
}

$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wsl) {
    Write-Fail 'wsl.exe not found'
} else {
    $distros = (& wsl.exe --list --quiet 2>$null) -replace "`0", ''
    if ($distros -contains 'Ubuntu-24.04-D') { Write-Pass 'Ubuntu-24.04-D is installed' }
    else { Write-Fail 'Ubuntu-24.04-D is not installed' }
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
