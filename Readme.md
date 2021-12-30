# Prisma + GraphQL

This is a boilerplate for a graphql server using using:

- [Prisma](https://www.prisma.io/docs)
- [TypeGraphQL](https://typegraphql.com/docs/introduction.html)
- [TypeGraphQL Prisma plugin](https://prisma.typegraphql.com/docs/intro)

## Local Development

1. Initialize db with `make init_dev`
2. Start dev server with `make dev`
3. Visit localhost:4000 to open playground
4. Update then check generated schema an migration files with `make prepare_commit`

## Build release

For building release docker img on mac with m1 processor wait for corresponding [prisma issue](https://github.com/prisma/prisma/issues/8478) to be resolved.

Otherwise just run a docker build

## Deployment

The release docker container uses the `POSTGRES_URL` env variable to connect to a db.
No security precautions are configured.
