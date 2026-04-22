$RepoUrl = "https://github.com/finhay-pro/finhay-skills-hub.git"
$WorkDir = "_tmp_finhay_skills_hub"
$CurDir = Get-Location

Remove-Item -Path "$CurDir\finhay-market", "$CurDir\finhay-portfolio" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$CurDir\finhay-market.zip", "$CurDir\finhay-portfolio.zip" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$CurDir\$WorkDir" -Recurse -Force -ErrorAction SilentlyContinue

git clone $RepoUrl "$CurDir\$WorkDir"

Set-Location "$CurDir\$WorkDir\skills"
Compress-Archive -Path "finhay-market" -DestinationPath "$CurDir\finhay-market.zip" -Force
Compress-Archive -Path "finhay-portfolio" -DestinationPath "$CurDir\finhay-portfolio.zip" -Force

Set-Location "$CurDir"
Remove-Item -Path "$CurDir\$WorkDir" -Recurse -Force

Write-Host "Done. Created $CurDir\finhay-market.zip and $CurDir\finhay-portfolio.zip."
