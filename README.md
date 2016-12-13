# Bookstore

A simple application showing how to use Swift-Kuery 

## Getting started

1. Requires PostgreSQL and PostgreSQL client library

On macOS: `brew install postgresql`
On Linux: `sudo apt-get install libpq-dev`

2. Create database

`createdb bookstoredb`

3. **Load the schema**

  Load psql: `psql -d bookstoredb`

  Load the schema: `\i Database/schema.sql`

4. **Compile**:

  `swift build`

5. **Run**:

  `.build/debug/bookstore`

6. **Test**:

  `curl localhost:8090`


## SQL queries

***Get cart data***

```sql
select * from books, carts where books.id=carts.book_id and user_id=1;
```

***Get books with authors***

```sql
select * from books, authors, book_author where books.book_id=book_author.book_id and authors.author_id=book_author.author_id;
```

## Deploying to Bluemix

### Manually

Bluemix is a hosting platform from IBM that makes it easy to deploy your app to the cloud. Bluemix also provides various popular databases. Compose for PostgreSQL is an offering that is compatible with a PostgreSQL database, but provides additional features.

1. Get an account for [Bluemix](https://console.ng.bluemix.net/registration/)

2. Download and install the [Cloud Foundry tools](https://new-console.ng.bluemix.net/docs/starters/install_cli.html):

    ```
    cf api https://api.ng.bluemix.net
    cf login
    ```

    Be sure to run this in the directory where the manifest.yml file is located.

2. Create your Compose for PostgreSQL service

  ```
  cf create-service compose-for-postgresql Standard Bookstore-postgresql
  ```

3. Run `cf push`   

    ***Note** This step will take 3-5 minutes

    ```
    1 of 1 instances running 

    App started
    ```

4. Get the credential information:

   ```
   cf env Bookstore
   ```
   
   Note you will see something similar to the following, note the hostname, username, and password:
   
   ```json
	{
		"VCAP_SERVICES": {
			"compose-for-postgresql": [{
				"credentials": {
					"ca_certificate_base64": "<base64_string>",
					"db_type": "postgresql",
					"deployment_id": "584afe35475bb60013000023",
					"name": "bmix_dal_yp_77871416_ece6_4ebb_8aca_b1e02a39b7b1",
					"uri": "postgres://<user>:<password>@bluemix-sandbox-dal-9-portal.0.dblayer.com:19971/compose",
					"uri_cli": "psql \"sslmode=require host=bluemix-sandbox-dal-9-portal.0.dblayer.com port=19971 dbname=compose user=<user>\""
				},
				"label": "compose-for-postgresql",
				"name": "Bookstore-postgresql",
				"plan": "Standard",
				"provider": null,
				"syslog_drain_url": null,
				"tags": [
					"big_data",
					"data_management",
					"ibm_created"
				]
			}]
		}
	},
    ```

5. Setup your database

    From the output above, extract the `url_cli`, strip out escaping `\` characters and run a command like the following, replacing `<user>` with your user:

    ```bash
    cat Database/schema.sql | psql "sslmode=require host=bluemix-sandbox-dal-9-portal.0.dblayer.com port=19971 dbname=compose user=<user>"
    ```
If asked for a password, use the value in the `<password>` space from the `cf env` output above.

### Deploying Docker to IBM Bluemix Container

For the following instructions, we will be using our [Makefile](Makefile) located in the root directory.

1. Install the Cloud Foundry CLI tool and the IBM Containers plugin for CF with the following

  ```
  make install-tools
  ```
  
2. Build and run a Docker container with the following

  ```
  make build
  make run
  ```
  
3. Create a bridge CF application to later bind to your container

  ```
  make create-bridge
  ```
  
4. Create the Compose for PostgreSQL service and bind to your bridge CF application.

  ```
  make create-database
  ```
  
5. Push previously created Docker container to Bluemix

  ```
  make push-bluemix
  ```
  
6. Create a Bluemix container group where your app will live, binding it to your bridge CF application in the process

  ```
  make deploy-bluemix
  ```

  Afterwards, you can ensure PostgreSQL was bound correctly by viewing all credentials for your group

  ```
  cf ic group inspect bookstore
  ```
  
7. Lastly, we need to setup our database with some data. To get the command and password you need to use, enter the following

  ```
  make get-db-info
  ```
You should see something like this:

  ```
  Run: cat Database/schema.sql | psql "sslmode=require host=bluemix-sandbox-dal-9-portal.0.dblayer.com port=19971 dbname=compose user=<user>"
  Password: <Your-Password>
  ```
Once you run that command, you are done! Accessing your apps route with the path `/api/v1/books` should return a list of books. 
    