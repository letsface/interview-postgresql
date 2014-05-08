BEGIN;
SELECT no_plan();
	\ir ../sql/ddl.sql
	\ir ../sql/import.sql
	\ir ../sql/view.sql
	SET var.role_name TO 'minlin';
	SELECT results_eq(
		$$ SELECT name FROM "EntitySecure" ORDER BY name $$,
		$$ VALUES
			('Beer'),
			('Company'),
			('La Chouffe'),
			('Type')
		$$
	);

	SET var.role_name TO 'ricky';
	SELECT results_eq(
		$$ SELECT name FROM "EntitySecure" ORDER BY name  $$,
		$$ VALUES
			('Beer'),
			('Cheers In'),
			('Company'),
			('Dean''s Bottle Shop'),
			('La Chouffe'),
			('McChouffe'),
			('Type')
		$$
	);

	SET var.role_name TO 'guest';
	SELECT results_eq(
		$$ SELECT name FROM "EntitySecure" ORDER BY name  $$,
		$$ VALUES
			('Company'),
			('Type')
		$$
	);

	SET var.role_name TO 'restricted';
	SELECT is_empty(
		$$ SELECT name FROM "EntitySecure" ORDER BY name  $$
	);

SELECT * FROM finish();
ROLLBACK;
