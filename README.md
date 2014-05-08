# Row-level security

## Summary

Use PostgreSQL to construct a user/team system allowing fine-grained access control to entities.

User/team management is built on top of the PostgreSQL roles system.

To simplify the example, entities are just a name (string).

## Knowledge tested

To solve this problem, you will use:

* temporary tables
* COPY command
* plpgsql
 * declaring types to match tables types
 * FOR ... LOOP
 * FOUND variable
 * IF ... END IF
 * EXECUTE and exception handling
* CREATE ROLE
* GRANT
* DDL
 * SERIAL type
 * PRIMARY KEY
 * constraints and REFERENCES
 * NOT NULL
* anonymous function blocks
* testing using pgtap
* customized options

## Overview

Entities/Type

* Every entity has a type
* Types are also entities with a type "Type"
* Every entity has a string name

Security:

* there are three parts: subject (role), object (entity) and operations (query)
* operations are:
 * query: can retrieve the document
* operations can be: true (allow), false (disallow) or unspecified (null)
* We want to be able to specify down to the entity / user level
* User-specified rights override teams rights
* Any user allow overrides other user disallow
* Any team allow overrides other teams disallow
* if no rights are specified for the entity, we default to the entity type rights
* if no rights record are found, we deny access

See rights.xlsx for the expected result.

## Example data

Look at the data/ directory for example input data.

entities:

* entity name
* entity type name

relationships:

* source entity name (detail)
* relationship description
* target entity name (master)

rights:

* role name
* entity or type name
* query allowed or disallowed (boolean)

roles:

* role name

teams:

* role name
* comma-separated list of roles

## TODO

* clone this repository to your computer
* In your postgresql.conf, setup a new customized option ```var.role_name = 'unknown'```
* sql/ddl.sql: DDL for normalized data with the following tables:
 * Entity: contains all entities (including types which are also entities)
 * RelationshipDescription: contains the description text
 * RelationshipInstance: links the source, target entity and relationship description
 * Right: refers to the entity id, the role and value for the query operation
* sql/ddl_drop.sql: reverse operation from ddl.sql in the correct order
 * should NOT use CASCADE
* sql/import.sql: import script
 * create import data tables matching inputs
 * use the appropriate COPY command to process the data
 * insert bootstrap Type record into the Entity table
 * anonymous plpgsql script to turn all loaded data into entities
* sql/view.sql
 * EntitySecure: view based on Entity that restricts access to data based on the user role set in var.role_name (a customized setting)
 * any other views of the data you need
* pgtap/*.sql: add your own tests
* zip up and send your local git repo by email with a detailed report on how much time it took

## Rules and evaluation criteria

* must use database roles (users and teams)
* The test pgtap/complete.sql must pass as-is, without changes to the test.
* The DDL must be normalized and enforce referential constraints and checks
* Use double-quoted names for database entities to allow case-sensitivity
* Table names must be CamelCase
* property/column names must use_underscore
* naming, indentation, documentation, consistency and comments are part of the evaluation
* BONUS: large dataset test / benchmarking / performance optimization

## pgtap

Running the test requires pgTAP.

Install pgTAP and pgprove:

```
sudo pgxn install pgtap
sudo cpan TAP::Parser::SourceHandler::pgTAP
```

...or on Ubuntu:

```
sudo apt-get install libtap-parser-sourcehandler-pgtap-perl pgtap
```

You can then run the test:

```
$ pg_prove pgtap/complete.sql
pgtap/complete.sql .. ok
All tests successful.
Files=1, Tests=4,  1 wallclock secs ( 0.04 usr  0.00 sys +  0.06 cusr  0.01 csys =  0.11 CPU)
Result: PASS
```

## Hints

For importing, use the:

```
COPY "destination" FROM filename DELIMITERS ',' CSV
```

For processing the entities, relationships, rights from imported data to normalized data use a:

```
FOR variable_of_imported_rowtype IN
	-- select from the imported data
LOOP
	-- see if the type already exist
	-- if it does not exist, create it
	-- insert the updated Entity, RelationshipInstance or Right
END LOOP;
```

when importing data, also make sure you use TRIM to clean up the inputs.

For roles and teams, use string concatenation to build the appropriate CREATE ROLE and GRANT ... TO.

For EntitySecure, suggest using LEFT OUTER JOIN to other tables.

The list of teams a role is linked to can be obtained with:

```
	SELECT rolname::text AS name
		FROM pg_auth_members,pg_roles
		WHERE roleid = oid
		AND member IN (
			SELECT oid
				FROM pg_roles
				WHERE rolname = current_setting('var.role_name')
			)
```

Customized options values can be fetched as follow:

```
current_setting('var.role_name')
```
