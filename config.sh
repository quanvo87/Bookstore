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
    Usage: $CMD [ build | run | push-docker ] [arguments...]

    Where:
      install-tools         	Installs necessary tools for config, like Cloud Foundry CLI
      login                 	Logs into Bluemix and Container APIs
      build <name>          	Builds Docker container from Dockerfile
      run   <name>         		Runs Docker container, ensuring it was built properly
      stop  <name> 				Stops Docker container, if running
      push-docker <name>		Tags and pushes Docker container to Bluemix
	  create-bridge				Creates empty bridge application
	  create-database			Creates database service and binds to bridge
	  deploy <group-name>		Binds everything together (app, db, container) through container group
	  populate-db				Populates database with initial data
!!EOF
}

function install-tools {
	brew tap cloudfoundry/tap
	brew install cf-cli
	cf install-plugin https://static-ice.ng.bluemix.net/ibm-containers-mac
}

login () {
	echo "Setting api and logging in tools."
	cf api https://api.ng.bluemix.net
	cf login
	cf ic login
}

buildDocker () {
	if [ -z "$1" ]
	then
		echo "Error: build failed, docker name not provided."
		return
	fi
	docker build -t $1 --force-rm .
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

pushDocker () {
	if [ -z "$1" ]
	then
		echo "Error: Pushing Docker container to Bluemix failed."
		return
	fi
	echo "Tagging and pushing docker container..."
    namespace=$(cf ic namespace get) # TODO: should capitalize?
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
	# TODO: error if bridge app not named?
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
	hostname=$1"-app"

	cf ic group create \
	--anti \
	--auto \
	-m 128 \
	--name $1 \
	-p 8090 \
	-n $hostname \
	-e "CCS_BIND_APP="$BRIDGE_APP_NAME \
	-d mybluemix.net $REGISTRY_URL/$namespace/$1
}

populateDB () {
	if [ -z "$1" ]
	then
		echo "Error: Could not populate database."
		return
	fi


	rawValue=$(cf env $1 | grep 'uri_cli' | awk -F: '{print $2}')
	echo "First "$rawValue

	COMMAND_TO_RUN=$(echo $rawValue | tr -d '\' | sed -e 's/^"//' -e 's/"$//')
	echo "$COMMAND_TO_RUN"

	$COMMAND_TO_RUN # TODO: not working yet
	
	# $(eval PASSWORD := $(shell cf env $(name) | grep 'postgres://' | sed -e 's/@bluemix.*$$//' -e 's/^.*admin://'))
	# @echo Run: "cat Database/schema.sql | "$(COMMAND_TO_RUN)
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
"build")				 buildDocker "$2";;
"run")					 runDocker "$2";;
"stop")				     stopDocker "$2";;
"push-docker")			 pushDocker "$2";;
"create-bridge")		 createBridge;;
"create-database")		 createDatabase;;
"deploy")				 deployContainer "$2";;
"populate-db")			 populateDB "$2";;
*)                       help;;
esac