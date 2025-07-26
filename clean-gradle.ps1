# Xoá cache toàn cục
$globalCache = "$env:USERPROFILE\.gradle\caches"
if (Test-Path $globalCache) {
    Remove-Item "$globalCache\*" -Recurse -Force
    Write-Output "Đã dọn $globalCache"
}

# Xoá build và .gradle folder trong project
$projectPath = Get-Location
Get-ChildItem -Path $projectPath -Recurse -Include build, .gradle | ForEach-Object {
    Remove-Item $_.FullName -Recurse -Force
    Write-Output "Đã dọn $_.FullName"
}
