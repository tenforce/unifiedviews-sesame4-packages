#!/bin/bash

set -x

# Get the latest files needed.

wget_n() {
    pushd ../downloads
     wget -N $1
    popd
}

if [ ! -d debs ]
then
    # BUILD the required MAVEN docker image
    docker stop $(docker ps -a -q)    
    docker rm $(docker ps -a -q)    
    docker build -t my-maven .

    # Get the required files
    wget https://github.com/UnifiedViews/Core/archive/sesame4-include-updates.zip
    mv sesame4-include-updates.zip UV_Core.zip
    wget https://github.com/UnifiedViews/Plugins/archive/sesame4-include-updates.zip
    mv sesame4-include-updates.zip UV_Plugins.zip
    unzip UV_Core_*.zip
    unzip UV_Plugins*.zip

    # Build the debian packages as required (using the docker).
    rm -rf debs
 
    export SESAME_VERSION=4.1.0
    
    pushd Core-sesame4-include-updates
#     docker run -it --rm --name my-maven-script -v "$PWD":/usr/src/mymaven -w /usr/src/mymaven my-maven mvn -P java8,sesame4 -f pom.xml org.apache.maven.plugins:maven-help-plugin:2.2:effective-pom | tee tmp.pom

      docker run -it --rm --name my-maven-script -v "$PWD":/usr/src/mymaven -w /usr/src/mymaven my-maven mvn install -P java8,sesame4 | tee tmp.core

      # docker run -it --rm --name my-maven-script -v "$PWD":/usr/src/mymaven -w /usr/src/mymaven my-maven mvn -P java8,sesame4 -f debian/pom.xml org.apache.maven.plugins:maven-help-plugin:2.2:effective-pom | tee tmp.debian.pom

      docker run -it --rm --name my-maven-script -v "$PWD":/usr/src/mymaven -w /usr/src/mymaven my-maven mvn install package -P java8,sesame4 -f debian/pom.xml | tee tmp.core
    popd

    pushd Plugins-sesame4-include-updates
      docker run -it --rm --name my-maven-script -v "$PWD":/usr/src/mymaven -w /usr/src/mymaven  my-maven mvn install package -P java8,sesame4 -DskipTests -f debian/pom.xml | tee tmp.plugins
    popd

    # Replace the debian packages
    mkdir -p debs
    cp */*/target/*.deb debs
    cp */*/*/target/*.deb debs
else
    echo "packages should already exist in debs directory"
fi

dpkg-scanpackages debs /dev/null | gzip > debs/Packages.gz
rm -f /etc/apt/sources.list.d/odn.list

echo "deb file:/vagrantcp/unifiedviews-system debs/" > /etc/apt/sources.list.d/uv-update.list
echo "*** WARN: unhold the previous packages might be needed"
apt-get -y remove unifiedviews*
apt-get -y update
apt-get -y --force-yes install unifiedviews-mysql \
	unifiedviews-backend-shared \
	unifiedviews-backend-mysql \
	unifiedviews-backend \
	unifiedviews-webapp-shared \
	unifiedviews-webapp-mysql \
	unifiedviews-webapp \
	unifiedviews-plugins
apt-get -y --force-yes install
