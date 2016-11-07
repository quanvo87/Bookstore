# Bookstore

A simple application showing how to use Swift-Kuery 

## Getting started

1. **Load the schema**

  Load psql: `psql -U rfdickerson -dbookstoredb`

  Load the schema: `\i schema.sql`

2. **Compile**:

  `swift build`

3. **Run**:

  `.build/debug/bookstore`

4. **Test**:

  `curl localhost:8090`
