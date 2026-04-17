# PowerShell script to clone finhay-pro/finhay-skills-hub and zip 2 skills subfolders

$repoUrl = "https://github.com/finhay-pro/finhay-skills-hub.git"
$workDir = "_tmp_finhay_skills_hub"
$curDir = Get-Location

# Remove old folders/zips if exist
Remove-Item "$curDir/finhay-market.zip" -ErrorAction SilentlyContinue
Remove-Item "$curDir/finhay-portfolio.zip" -ErrorAction SilentlyContinue
Remove-Item "$curDir/$workDir" -Recurse -Force -ErrorAction SilentlyContinue

# Clone toàn bộ repo về
git clone $repoUrl "$curDir/$workDir"
if (!(Test-Path "$curDir/$workDir/skills/finhay-market")) { Write-Error "finhay-market folder not found"; exit 1 }
if (!(Test-Path "$curDir/$workDir/skills/finhay-portfolio")) { Write-Error "finhay-portfolio folder not found"; exit 1 }

# Zip 2 thư mục skills cần thiết
Compress-Archive -Path "$curDir/$workDir/skills/finhay-market" -DestinationPath "$curDir/finhay-market.zip" -Force
Compress-Archive -Path "$curDir/$workDir/skills/finhay-portfolio" -DestinationPath "$curDir/finhay-portfolio.zip" -Force

# Cleanup
Remove-Item "$curDir/$workDir" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done. Created $curDir/finhay-market.zip and $curDir/finhay-portfolio.zip."
