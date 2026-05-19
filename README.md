# core
The "core" application provides the following items:
* assert procedure - useful for robust design-by-contract type programming
* pkg_syslog       - generic logging utility in the vein of *NIX syslog
* pkg_app_dict     - a generic application dictionary
* pkg_application  - for tracking an managing deployed components
* pkg_trace        - a trace facility to help isolate problems
* num_tab type     - a number table useful for passing around arrays of numbers

## Uninstalling core

This repository includes `Deployment_Manifests/uninstall.core.sql`, a self-contained uninstall script for the `core` deployment.

- It drops the objects created by `deploy.core.full.sql`.
- It does not rely on `APP_OBJECTS` or `pkg_application` metadata being populated.
- It prompts for confirmation before proceeding.
- It is intended for use in a safe, non-production environment and should be run only when you want to completely remove the `core` deployment artifacts.

## Cross-Application Metadata Ownership

A key feature of `pkg_application` is the ability to register metadata that belongs to one application but lives in a table owned by another. This ensures automatic cleanup when `delete_application_p` is called, with no orphaned rows left behind.

### The problem it solves

Applications frequently seed rows into shared tables owned by other applications — for example, seeding entries into `app_dictionary` (owned by `core`) during deployment. Without tracking, those rows are orphaned when the application is later removed.

### How it works

`add_object_metadata_p` records the target table name, a discriminator column, and a discriminator value that together identify the rows owned by the registering application. When `delete_application_p` is called, `core` loops through all registered metadata and executes:

```sql
DELETE FROM <table> WHERE <discriminator_col> = <discriminator_val>
```

### Usage example

```sql
-- MYAPP deployment: seed reference data into another app's PRODUCT_CATEGORY table
INSERT INTO product_category (owning_app, category_code, description)
VALUES ('MYAPP', 'WIDGET', 'Widget category');

-- Register those rows so they are cleaned up when MYAPP is deleted
EXEC pkg_application.add_object_metadata_p(
       ip_application_name  => 'MYAPP',
       ip_object_name       => 'PRODUCT_CATEGORY',
       ip_object_type       => pkg_application.c_object_type_table,
       ip_discriminator_col => 'OWNING_APP',
       ip_discriminator_val => 'MYAPP');

-- Later: removing MYAPP automatically deletes its product_category rows
EXEC pkg_application.delete_application_p(ip_application_name => 'MYAPP');
```

### Custom cleanup with dml_override_proc

When a plain `DELETE` is not sufficient — for example, when an application creates dynamic database objects (queues, sequences, subsidiary tables) keyed by a discriminator value — the `ip_dml_override_proc` parameter names a procedure to call instead of the default `DELETE`. The procedure is invoked as `BEGIN <proc_name>; END;` and is responsible for all cleanup.

```sql
-- MYAPP creates a private queue at deploy time and needs a proc to drop it
EXEC pkg_application.add_object_metadata_p(
       ip_application_name  => 'MYAPP',
       ip_object_name       => 'APP_OBJECTS',
       ip_object_type       => pkg_application.c_object_type_table,
       ip_discriminator_col => 'APPLICATION_NAME',
       ip_discriminator_val => 'MYAPP',
       ip_dml_override_proc => 'myapp_cleanup.drop_private_queue_p');
```

