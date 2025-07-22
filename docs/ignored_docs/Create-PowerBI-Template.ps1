# PowerBI Template Creation Script
# Run this PowerShell script to help create a clean PowerBI template

Write-Host "=== PowerBI Template Creation Assistant ===" -ForegroundColor Green
Write-Host "This script will guide you through creating a secure PowerBI template." -ForegroundColor Yellow
Write-Host ""

# Check if PowerBI Desktop is running
$powerBIProcess = Get-Process -Name "PBIDesktop" -ErrorAction SilentlyContinue
if ($powerBIProcess) {
    Write-Host "⚠️  WARNING: PowerBI Desktop is currently running." -ForegroundColor Red
    Write-Host "Please close PowerBI Desktop before proceeding to ensure clean template creation." -ForegroundColor Red
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "Exiting. Please close PowerBI Desktop and run this script again." -ForegroundColor Yellow
        exit
    }
}

Write-Host "Step 1: Backup Original File" -ForegroundColor Cyan
Write-Host "Before creating template, we'll backup your original .pbix file"
Write-Host ""

# Get the current directory and look for .pbix files
$currentDir = Get-Location
$pbixFiles = Get-ChildItem -Path $currentDir -Filter "*.pbix" | Where-Object { $_.Name -notlike "*TEMPLATE*" -and $_.Name -notlike "*template*" }

if ($pbixFiles.Count -eq 0) {
    Write-Host "❌ No .pbix files found in current directory." -ForegroundColor Red
    Write-Host "Please navigate to the directory containing your PowerBI file and run this script again." -ForegroundColor Yellow
    exit
}

Write-Host "Found PowerBI files:" -ForegroundColor Green
for ($i = 0; $i -lt $pbixFiles.Count; $i++) {
    Write-Host "  [$($i+1)] $($pbixFiles[$i].Name)" -ForegroundColor White
}

if ($pbixFiles.Count -eq 1) {
    $selectedFile = $pbixFiles[0]
    Write-Host "Automatically selected: $($selectedFile.Name)" -ForegroundColor Green
} else {
    Write-Host ""
    $selection = Read-Host "Select file number (1-$($pbixFiles.Count))"
    try {
        $selectedFile = $pbixFiles[$selection - 1]
        Write-Host "Selected: $($selectedFile.Name)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Invalid selection. Exiting." -ForegroundColor Red
        exit
    }
}

# Create backup
$backupName = $selectedFile.BaseName + "_BACKUP_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".pbix"
Write-Host ""
Write-Host "Creating backup: $backupName" -ForegroundColor Yellow
try {
    Copy-Item -Path $selectedFile.FullName -Destination $backupName
    Write-Host "✅ Backup created successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create backup: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Create template name
$templateName = $selectedFile.BaseName + "_TEMPLATE.pbix"
Write-Host ""
Write-Host "Step 2: Create Template File" -ForegroundColor Cyan
Write-Host "Template will be named: $templateName" -ForegroundColor Yellow

try {
    Copy-Item -Path $selectedFile.FullName -Destination $templateName
    Write-Host "✅ Template file created" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create template: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Step 3: Manual Template Cleaning Required" -ForegroundColor Cyan
Write-Host "⚠️  IMPORTANT: You must now manually clean the template file!" -ForegroundColor Red
Write-Host ""
Write-Host "📋 Complete these steps in PowerBI Desktop:" -ForegroundColor Yellow
Write-Host "1. Open the template file: $templateName" -ForegroundColor White
Write-Host "2. Follow the cleaning process in POWERBI_LICENSE_PROTECTION.md" -ForegroundColor White
Write-Host "3. Complete the security checklist in DATA_SECURITY_VERIFICATION.md" -ForegroundColor White
Write-Host "4. Test the template on a clean environment" -ForegroundColor White
Write-Host ""

Write-Host "📂 Files created:" -ForegroundColor Green
Write-Host "  - Backup: $backupName" -ForegroundColor White
Write-Host "  - Template: $templateName" -ForegroundColor White
Write-Host ""

Write-Host "📖 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Open PowerBI Desktop" -ForegroundColor White
Write-Host "2. Open: $templateName" -ForegroundColor White
Write-Host "3. Follow: DATA_SECURITY_VERIFICATION.md checklist" -ForegroundColor White
Write-Host "4. Review: TEMPLATE_SETUP_INSTRUCTIONS.md for user guidance" -ForegroundColor White
Write-Host ""

# Offer to open documentation
$openDocs = Read-Host "Open security documentation now? (Y/n)"
if ($openDocs -ne "n" -and $openDocs -ne "N") {
    if (Test-Path "DATA_SECURITY_VERIFICATION.md") {
        Start-Process "DATA_SECURITY_VERIFICATION.md"
        Write-Host "✅ Opened security verification checklist" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Security documentation not found in current directory" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🔒 CRITICAL REMINDER:" -ForegroundColor Red
Write-Host "Do NOT publish the template until you have:" -ForegroundColor Red
Write-Host "  ✅ Completed full security verification" -ForegroundColor Red
Write-Host "  ✅ Tested template on clean environment" -ForegroundColor Red
Write-Host "  ✅ Confirmed no sensitive data remains" -ForegroundColor Red
Write-Host ""
Write-Host "Template creation script completed!" -ForegroundColor Green
