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
RUN mv /app_build/node_modules .
RUN mv /app_build/prisma .
RUN mv /app_build/dist .
RUN rm -rf /app_build

CMD [ "node", "dist/start.js"]
