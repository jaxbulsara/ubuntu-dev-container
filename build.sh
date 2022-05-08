# Builds the dockerfile and exports the image

version=$(<VERSION)
file_version=${version//"."/"-"}
file_name=ubuntu_dev_$file_version.tar
output_dir=$UBUNTU_DIR/image/$file_name

echo "Building ubuntu-dev v$version..."
docker build --tag ubuntu-dev:$version .

echo "Exporting ubuntu-dev v$version..."
container_id=$(docker run -dt --rm ubuntu-dev:$version) 
docker export $container_id -o $output_dir
docker stop $container_id

echo "Exported image to $output_dir."
