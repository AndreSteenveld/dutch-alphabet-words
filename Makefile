
.PHONY: clean
clean:
	docker rm --force postgres;
	docker volume rm --force db-data;

.PHONY: migrate-database
migrate-database:
	env 						\
		PGHOST="localhost"		\
		PGPORT="5432"			\
		PGDATABASE="postgres" 	\
		PGUSER="postgres"		\
		PGPASSWORD="postgres"	\
	psql --file ./schema.sql	;


.PHONY: import-words
import-words:
	echo 'Import words in to the database'
