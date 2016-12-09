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

## Running in Docker

  1. Build the image

  ```
  $ docker build -t bookstore . 
  ```

  2. Run the image

  ```
  $ docker run --name bookstore -d -p 8090:8090 bookstore
  ```

## Deploying your Docker image


  ```
  $ cf create-service compose-for-postgresql Standard bookstore-postgresql
  ```

  Create a bridge

  ```
  cf push containerbridge -p containerbridge -i 1 -d mybluemix.net -k 1M -m 64M --no-hostname --no-manifest --no-route --no-start
  ```

  ```
  cf bind-service containerbridge bookstore-postgresql
  ```


  ```
  cf ic group update -e "CCS_BIND_APP=containerbridge" bookstore
  ```

  View the credentials

  ```
  cf ic group inspect bookstore
  ```
