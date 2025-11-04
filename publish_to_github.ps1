<#
Simple helper to publish this project to your GitHub account.
Usage: Open PowerShell in the project root and run:
    .\publish_to_github.ps1
You will be prompted for a repo name. If you prefer `gh` provide -UseGH.
#>

param(
    [string]$RepoName = $(Read-Host 'Enter GitHub repo name (e.g. AutoSteer)'),
    [switch]$UseGH
)

function FailIfNoGit() {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error 'git is not installed or not in PATH. Install Git (https://git-scm.com/) and try again.'
        exit 1
    }
}

FailIfNoGit

Push-Location -LiteralPath (Get-Location)

if (-not (Test-Path .git)) {
    Write-Output 'Initializing a new git repository and making initial commit...'
    git init
    git add .
    git commit -m "Initial commit"
} else {
    Write-Output '.git already exists; using existing repo.'
}

if ($UseGH) {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Output "gh CLI not found. Install from https://cli.github.com/ or run without -UseGH to use manual method."
    } else {
        gh auth status 2>$null
        if ($LASTEXITCODE -ne 0) { gh auth login }
        gh repo create yuviii21/$RepoName --public --source=. --remote=origin --push
        exit $LASTEXITCODE
    }
}

# Manual flow
Write-Output 'Using manual git remote flow...'

git branch -M main

# If origin exists, warn instead of overwriting
$originUrl = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    git remote add origin https://github.com/yuviii21/$RepoName.git
} else {
    Write-Output "Remote 'origin' already exists: $originUrl"
    Write-Output "If you want to replace it, run: git remote remove origin; then run this script again."
}

git push -u origin main

Pop-Location
