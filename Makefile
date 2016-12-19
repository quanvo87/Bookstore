name = bookstore
hostname = bookstore-app
port = 8090
database-type = compose-for-postgresql
database-level = Standard
database-name = Bookstore-postgresql
registry-url = registry.ng.bluemix.net
memory = 128

# Other parameters outside of application

all: build

login:
	cf api https://api.ng.bluemix.net
	cf login
	cf ic login

install-tools:
	brew tap cloudfoundry/tap
	brew install cf-cli
	cf install-plugin https://static-ice.ng.bluemix.net/ibm-containers-mac

clean:
	docker rm -fv $(name) || true

build: 
	docker build -t $(name) --force-rm .

run: 
	docker run --name $(name) -d -p $(port):$(port) $(name)
	@echo "To stop container, run 'docker ps' and plug the corresponding ID into the following: 'docker stop <container_id>'"

clean-bluemix:
	cf ic group rm $(name)

create-bridge:
	mkdir containerbridge
	cd containerbridge
	touch empty.txt
	cf push containerbridge -p . -i 1 -d mybluemix.net -k 1M -m 64M --no-hostname --no-manifest --no-route --no-start
	rm empty.txt
	cd ..
	rm -rf containerbridge

create-database: 
	cf create-service $(database-type) $(database-level) $(database-name)
	cf bind-service containerbridge $(database-name)
	cf restage containerbridge

push-bluemix: 
	docker tag $(name) $(registry-url)/$(shell cf ic namespace get)/$(name)
	docker push $(registry-url)/$(shell cf ic namespace get)/$(name)

deploy-bluemix: 
	cf ic group create \
		--anti \
		--auto \
		-m $(memory) \
		--name $(name) \
		-p $(port) \
		-n $(hostname) \
		-e "CCS_BIND_APP=containerbridge" \
		-d mybluemix.net $(registry-url)/$(shell cf ic namespace get)/$(name)

get-db-info:
	$(eval COMMAND_TO_RUN := $(shell cf env $(name) | grep 'uri_cli' | awk -F: '{print $$2}'))
	$(eval PASSWORD := $(shell cf env $(name) | grep 'postgres://' | sed -e 's/@bluemix.*$$//' -e 's/^.*admin://'))
	@echo Run: "cat Database/schema.sql | "$(COMMAND_TO_RUN)
	@echo Password: $(PASSWORD)

delete-bookstore:
	cf ic group rm $(name)
	cf unbind-service containerbridge $(database-name)
	cf delete-service $(database-name)

