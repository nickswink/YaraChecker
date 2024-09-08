# Get the target executable as a parameter
param (
    [string]$targetFile
)

# Define the path to the YARA binary and the rules directory
$yaraPath = "C:\Tools\yara-win64\yara64.exe"  # Change this to the path of your YARA executable
$rulesDirectory = "C:\Tools\yara-win64\yara\rules"  # Change this to your rules directory
$logFile = "output.log"  # Log file to store the output

# Function to write both to the console and log file
function Write-Log {
    param (
        [string]$message
    )
    Write-Host $message
    Add-Content -Path $logFile -Value $message
}

# Clear existing log file if it exists
if (Test-Path $logFile) {
    Remove-Item $logFile
}

# Check if the YARA executable exists
if (-Not (Test-Path $yaraPath)) {
    Write-Log "Error: YARA binary not found at $yaraPath"
    exit
}

# Check if the rules directory exists
if (-Not (Test-Path $rulesDirectory)) {
    Write-Log "Error: Rules directory not found at $rulesDirectory"
    exit
}

# Validate the input parameter
if (-Not $targetFile) {
    Write-Log "Error: No target file provided. Usage: .\Run-YaraRules.ps1 -targetFile <path_to_test.exe>"
    exit
}

# Check if the target file exists
if (-Not (Test-Path $targetFile)) {
    Write-Log "Error: Target file not found at $targetFile"
    exit
}

# Get all YARA rule files in the rules directory with .yar or .yara extension
$ruleFiles = Get-ChildItem -Path $rulesDirectory -Filter "*.yar"

if ($ruleFiles.Count -eq 0) {
    Write-Log "No YARA rule files found in the directory $rulesDirectory"
    exit
}

# Loop through each YARA rule file and run it against the target file
foreach ($rule in $ruleFiles) {
    #Write-Log "Running rule: $($rule.FullName)"
    
    # Run YARA against the target file using the current rule and capture the output
    $output = & $yaraPath $rule.FullName $targetFile 2>&1
    
    # Log the output
    if ($output) {
        Write-Log "[!] DETECTED: $output"
    }

    # Check the exit code for errors
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Error running rule: $($rule.FullName)"
    } else {
        #Write-Log "Rule executed successfully."
    }
}
Write-Log "[+] Finished."
