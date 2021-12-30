# cleans and starts postgres container; prepares db for usage
init_dev:
	if [ ! -d "node_modules" ]; then npm install; fi
	docker rm -f postgres
	docker run --name=postgres -p 5432:5432 -e POSTGRES_PASSWORD=admin --rm -d postgres:latest
	sleep 5
	npx prisma db push
	rm -fr node_modules/@generated/type-graphql

# starts watch process for development
dev: 
	if [ ! -d "node_modules/@generated/type-graphql" ]; then npx prisma generate; fi
	npm run dev

# updates generated files
prepare_commit:
	npx prisma generate
	npm run generate_schema
	npx prisma migrate dev --name init_dev
