import 'reflect-metadata'
import {
  resolvers,
  User,
  Post,
  applyResolversEnhanceMap,
  applyModelsEnhanceMap,
  applyRelationResolversEnhanceMap,
} from '@generated/type-graphql'
import { buildSchema, FieldResolver, Resolver, Root, Ctx, Int, AuthChecker, Authorized } from 'type-graphql'
import { ApolloServer } from 'apollo-server'
import { PrismaClient } from '@prisma/client'

type Context = {
  prisma: PrismaClient
  token: string
}
const prisma = new PrismaClient()
const authChecker: AuthChecker<Context> = ({ context }, roles) => {
  return roles.includes(context.token)
}

applyModelsEnhanceMap({
  User: {
    fields: {
      bio: [Authorized('admin')],
    },
  },
  Post: {
    fields: {
      _all: [Authorized('admin')],
    },
  },
})
applyResolversEnhanceMap({
  Post: { updatePost: [Authorized('admin')] },
})
applyRelationResolversEnhanceMap({
  User: {
    // Posts: [Authorized('admin')],
  },
})

@Resolver(of => Post)
export class CustomPostResolver {
  @FieldResolver(type => Int)
  async likes(@Root() post: Post, @Ctx() { prisma }: Context): Promise<number> {
    const likes = await prisma.reaction.count({ where: { postId: post.id, type: 'LIKE' } })

    return likes
  }
  @FieldResolver(type => Int)
  async dislikes(@Root() post: Post, @Ctx() { prisma }: Context): Promise<number> {
    const likes = await prisma.reaction.count({ where: { postId: post.id, type: 'DISLIKE' } })

    return likes
  }
}

export const buildPublicSchema = () =>
  buildSchema({
    resolvers: [...resolvers, CustomPostResolver],
    validate: false,
    authChecker,
    emitSchemaFile: true,
  })

export const startServer = async () => {
  const schema = await buildPublicSchema()

  const server = new ApolloServer({
    schema,
    context: ({ req }): Context => ({ prisma, token: req.headers.authorization || '' }),
  })

  server.listen()
}
