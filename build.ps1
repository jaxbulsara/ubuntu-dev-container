# Builds the dockerfile and exports the image

$version = Get-Content VERSION
$file_version = ${version} -replace "\.", "-"

docker build --tag ubuntu-dev:${version} .
$container_id = docker run -dt --rm ubuntu-dev:${version} 
docker export $container_id -o D:\ubuntu\image\ubuntu_dev_${file_version}.tar
docker stop ${container_id}