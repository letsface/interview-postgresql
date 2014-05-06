Overview

* there are three parts: subject, object (entity) and operations
* operations are:
 * create: can create an instance of this type (only applicable to type)
 * query: can retrieve the document
 * update: can modify the document
 * remove: can mark document as removed
* operations can be either true (allow) or false (disallow)
* We want to be able to specify down to the entity / user level
* User-specified rights override teams rights
* Any team allow overrides other teams disallow
* if no rights are specified for the entity, we default to the type
* if no rights record are found, we deny access

Additionally, entities are linked to other entities by Relationships; any disallowance in one of the entity (or the relationship itself, which is also an entity) results into the whole chain being disallowed.

Example:

* ds_users is a team role
* ds_admins is a team role
* ds_admin is role, part of ds_admins
* ricky is a role, part of ds_users
* minlin is a role, part of ds_users and ds_admin
* Beer is a Type
 * "La Chouffe" is an instance of Beer
 * "McChouffe" is an instance of Beer
* Company is a Type
 * "Brasserie d’Achouffe" is an instance of Company
 * "Dean's Bottle Shop" is an instance of Company

relationships are:

"La Chouffe", "brewed by",  "Brasserie d’Achouffe"
"McChouffe", "brewed by", "Brasserie d’Achouffe"
"La Chouffe", "distributed by",  "Cheers In"

roles are expressed as:

guest
ricky
minlin
ds_users, ricky, guest
ds_admins, minlin

for the query operation, we have the following rights records:

* guest, Beer, false
* ds_users, Beer, true
* ds_users, "Brasserie d’Achouffe", true
* ds_admins, Beer, true
* ricky, "La Chouffe", true
* guest, "La Chouffe", true
* minlin, "McChouffe", false

As user minlin, query access looks like:

* Beer = true [type allowed by group ds_admins]
* "La Chouffe" = true [entity allowed by type Beer]
* "McChouffe" = false [entity disallowed to user minlin]

As user ricky, query access to:

* Beer = true [type allowed by group ds_users]
* "La Chouffe" = true [entity allowed by user]
* "McChouffe" = false [entity has no relevant record associated]

As user guest, query access to:

* Beer = false [type disallowed to user guest]
* "La Chouffe" = false [type disallowed to user guest]
* "McChouffe" = false [type disallowed to user guest]