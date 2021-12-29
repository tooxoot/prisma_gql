init_dev:
	docker rm -f postgres
	docker run --name=postgres -p 5432:5432 -e POSTGRES_PASSWORD=admin --rm -d postgres:latest
	sleep 5
	npx prisma db push
	rm -fr node_modules/@generated/type-graphql
	npx prisma generate

prepare_commit:
	npm run generate_schema
	npx prisma migrate dev --name init_dev

build:
	npx prisma generate
	npm run build

dev: 
	if [ ! -d "node_modules" ]; then npm install; fi
	if [ ! -d "node_modules/@generated/type-graphql" ]; then npx prisma generate; fi
	npm run dev

run_local_release:
	docker run --name=postgres -p 5432:5432 -e POSTGRES_PASSWORD=admin --rm -d postgres:latest
	docker run --name=prism_gql -p 4000:4000 -e POSTGRES_URL=postgresql://postgres:admin@172.17.0.1:5432/postgres?schema=public --rm -d prism_gql:latest