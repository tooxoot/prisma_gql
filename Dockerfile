FROM node:16-alpine as dep
RUN apk add --update make openssl

WORKDIR /app
COPY package.json .
RUN npm install --production

WORKDIR /app_build
COPY package.json .
RUN npm install

FROM dep as build
COPY src src
COPY prisma prisma
COPY Makefile .
COPY tsconfig.json .
RUN make build

FROM build as release
WORKDIR /app
RUN mv /app_build/prisma .
RUN mv /app_build/dist .
RUN rm -rf /app_build
CMD [ "node", "dist/start.js"]
