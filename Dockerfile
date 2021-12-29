FROM node:16-alpine as dep

WORKDIR /app
COPY package.json .
RUN npm install --production

RUN apk add --update make openssl
WORKDIR /app_build
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
RUN mv /app/node_modules .
RUN npx prisma generate
WORKDIR /app

RUN mv /app_build/node_modules .
RUN mv /app_build/prisma .
RUN mv /app_build/dist .
RUN rm -rf /app_build

CMD [ "node", "dist/start.js"]
