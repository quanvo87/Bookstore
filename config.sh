#!/bin/bash
#------------------------------------------------------------
# Script: config.sh
# Author: Swift@IBM
# -----------------------------------------------------------
# 
# -----------------------------------------------------------

VERSION="1.0"
BUILD_DIR=".build-linux"

function help {
  cat <<-!!EOF
    Usage: $CMD [ build | run | debug ]

    Where:
      build                 Compiles your project
      run                   Runs your project at localhost:8090
      debug                 Debugs your container
      test                  Run the test cases
      install-system-libs   Install the system libraries from dependencies 
!!EOF
}

function install-tools {
	brew tap cloudfoundry/tap
	brew install cf-cli
	cf install-plugin https://static-ice.ng.bluemix.net/ibm-containers-mac
}

function login {
	echo "Setting api and logging in tools."
	cf api https://api.ng.bluemix.net
	cf login
	cf ic login
}

cleanDocker () {
	if [ "$1" ]
	then
		docker rm -fv $1 || true
	else
		echo "Error: clean failed, docker name not provided."
	fi
}

buildDocker () {
	if [ "$1" ]
	then
		echo "-Parameter #1 is \"$1\""
		docker build -t $1 --force-rm .
	else
		echo "Error: clean failed, docker name not provided."
	fi
}

#----------------------------------------------------------
# MAIN
# ---------------------------------------------------------

ACTION="$1"

[[ -z $ACTION ]] && help && exit 0

# Initialize the SwiftEnv project environment
eval "$(swiftenv init -)"


case $ACTION in
"install-tools")		 install-tools;;
"login")                 login;;
"clean")				 cleanDocker "$2";;
"build")				 buildDocker "$2";;
# "build")               installSystemLibraries && buildProject;;
# "debug")               debug;;
# "test")                runTests;;
# "install-system-libs") installSystemLibraries;;
*)                     help;;
esac