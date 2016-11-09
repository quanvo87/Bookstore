# Bookstore

A simple application showing how to use Swift-Kuery 

## Getting started

1. **Load the schema**

  Load psql: `psql -d bookstoredb`

  Load the schema: `\i Database/schema.sql`

2. **Compile**:

  `swift build`

3. **Run**:

  `.build/debug/bookstore`

4. **Test**:

  `curl localhost:8090`


## Queries

### Get cart data

select * from books, carts where books.id=carts.book_id and user_id=1;