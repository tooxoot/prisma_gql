FROM node:16-alpine as dep
RUN apk add --update make openssl
USER node
WORKDIR /app
COPY package.json .
RUN npm install --production

FROM dep as build
COPY src src
COPY prisma prisma
COPY Makefile .
RUN make build

FROM build as release
RUN rm -rf src
RUN rm -rf Makefile
CMD [ "node", "dist/start.js"]
