FROM node:16-alpine as dep

RUN apk add --update openssl

WORKDIR /dep_prod
COPY package.json .
RUN npm install --production

WORKDIR /dep_build
COPY package.json .
RUN npm install


FROM dep as build

COPY src src
COPY prisma prisma
COPY tsconfig.json .
RUN	npx prisma generate
RUN npm run build


FROM build as release

RUN rm -rf node_modules
RUN mv /dep_prod/node_modules .
RUN npx prisma generate

WORKDIR /app
RUN mv /dep_build/node_modules .
RUN mv /dep_build/prisma .
RUN mv /dep_build/dist .
RUN rm -rf /dep_build
RUN rm -rf /dep_prod

CMD [ "node", "dist/start.js"]
