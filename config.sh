#!/bin/bash
#------------------------------------------------------------
# Script: config.sh
# Author: Swift@IBM
# -----------------------------------------------------------
# 
# -----------------------------------------------------------

VERSION="1.0"
BUILD_DIR=".build-linux"
BRIDGE_APP_NAME="containerbridge2"
DATABASE_NAME="Bookstore-postgresql2"
REGISTRY_URL="registry.ng.bluemix.net"
DATABASE_TYPE="compose-for-postgresql"
DATABASE_LEVEL="Standard"

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

runDocker () {
	if [ -z "$1" ]
	then
		echo "Error: run failed, docker name not provided."
		return
	fi
	docker run --name $1 -d -p 8090:8090 $1
}

stopDocker () {
	if [ -z "$1" ]
	then
		echo "Error: clean failed, docker name not provided."
		return
	fi
	docker rm -fv $1 || true
}

buildDocker () {
	if [ -z "$1" ]
	then
		echo "Error: build failed, docker name not provided."
		return
	fi
	docker build -t $1 --force-rm .
}

pushDocker () {
	if [ -z "$1" ]
	then
		echo "Error: Pushing Docker container to Bluemix failed."
		return
	fi

    namespace=$(cf ic namespace get)
	docker tag $1 $REGISTRY_URL/$namespace/$1
	docker push $REGISTRY_URL/$namespace/$1
}

createBridge () {
	mkdir $BRIDGE_APP_NAME
	cd $BRIDGE_APP_NAME
	touch empty.txt
	cf push $BRIDGE_APP_NAME -p . -i 1 -d mybluemix.net -k 1M -m 64M --no-hostname --no-manifest --no-route --no-start
	rm empty.txt
	cd ..
	rm -rf $BRIDGE_APP_NAME
}

createDatabase () {
	cf create-service $DATABASE_TYPE $DATABASE_LEVEL $DATABASE_NAME
	cf bind-service $BRIDGE_APP_NAME $DATABASE_NAME
	cf restage $BRIDGE_APP_NAME
}

deployContainer () {
	if [ -z "$1" ]
	then
		echo "Error: Could not deploy container to Bluemix."
		return
	fi

	namespace=$(cf ic namespace get)
	cf ic group create \
	--anti \
	--auto \
	-m 128 \
	--name $1 \
	-p 8090 \
	-n "$1" + "-app" \
	-e "CCS_BIND_APP=" + $BRIDGE_APP_NAME \
	-d mybluemix.net $REGISTRY_URL/$namespace/$1
}

populateDB () {
	if [ -z "$1" ]
	then
		echo "Error: Could not populate database."
		return
	fi

	COMMAND_TO_RUN=$(cf env $(name) | grep 'uri_cli' | awk -F: '{print $$2}')
	echo COMMAND_TO_RUN
	# $(eval COMMAND_TO_RUN := $(shell cf env $(name) | grep 'uri_cli' | awk -F: '{print $$2}'))
	# $(eval PASSWORD := $(shell cf env $(name) | grep 'postgres://' | sed -e 's/@bluemix.*$$//' -e 's/^.*admin://'))
	# @echo Run: "cat Database/schema.sql | "$(COMMAND_TO_RUN)
	# @echo Password: $(PASSWORD)
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
"run")					 runDocker "$2";;
"stop")				     stopDocker "$2";;
"build")				 buildDocker "$2";;
"push-docker")			 pushDocker "$2";;
"create-bridge")		 createBridge;;
"create-database")		 createDatabase;;


"deploy")				 deployContainer "$2";;
"populate-db")			 populateDB "$2";;
*)                       help;;
esac