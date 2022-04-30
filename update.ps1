# Imports the latest ubuntu-dev image to WSL

$version = Get-Content VERSION
$file_version = ${version} -replace "\.", "-"

wsl --import Ubuntu D:\ubuntu\wsl\ D:\ubuntu\image\ubuntu_dev_$file_version.tar