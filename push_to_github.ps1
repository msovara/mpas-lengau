# PowerShell script to push MPAS Lengau repository to GitHub
# Run this AFTER creating the repository on GitHub

Write-Host "=== MPAS Lengau Repository Push Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "install_mpas_lengau.sh")) {
    Write-Host "Error: install_mpas_lengau.sh not found. Please run this script from the mpas-lengau directory." -ForegroundColor Red
    exit 1
}

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
    git add .
    git commit -m "Initial commit: MPAS installation scripts for Lengau cluster"
}

# Set branch to main
Write-Host "Setting branch to main..." -ForegroundColor Yellow
git branch -M main

# Check if remote exists
$remoteExists = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Adding remote origin..." -ForegroundColor Yellow
    git remote add origin https://github.com/msovara/mpas-lengau.git
} else {
    Write-Host "Remote already configured: $remoteExists" -ForegroundColor Green
}

# Check if repository exists on GitHub
Write-Host ""
Write-Host "IMPORTANT: Make sure you've created the repository on GitHub first!" -ForegroundColor Yellow
Write-Host "1. Go to: https://github.com/new" -ForegroundColor Cyan
Write-Host "2. Repository name: mpas-lengau" -ForegroundColor Cyan
Write-Host "3. Description: MPAS installation scripts for CHPC Lengau cluster" -ForegroundColor Cyan
Write-Host "4. DO NOT initialize with README, .gitignore, or license" -ForegroundColor Red
Write-Host "5. Click 'Create repository'" -ForegroundColor Cyan
Write-Host ""
$confirm = Read-Host "Have you created the repository on GitHub? (y/n)"

if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Please create the repository first, then run this script again." -ForegroundColor Yellow
    exit 0
}

# Push to GitHub
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Success! Repository pushed to GitHub." -ForegroundColor Green
    Write-Host "Repository URL: https://github.com/msovara/mpas-lengau" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Security Note: Consider using Git Credential Manager for future pushes:" -ForegroundColor Yellow
    Write-Host "  git config --global credential.helper manager-core" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Error: Push failed. Make sure:" -ForegroundColor Red
    Write-Host "  1. Repository exists on GitHub" -ForegroundColor Yellow
    Write-Host "  2. You have push access" -ForegroundColor Yellow
    Write-Host "  3. Your PAT token is valid" -ForegroundColor Yellow
}

