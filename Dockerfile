## Core image
FROM crystallang/crystal AS core

ENV NODE_ENV production
ENV KEMAL_ENV production

RUN apk update && \
    apk add --no-cache \
    git ca-certificates tzdata \
    nodejs npm && \
    update-ca-certificates
RUN crystal -v

## Build image
FROM core as build

WORKDIR /tmp/app
COPY . .

WORKDIR /tmp/app/server
RUN shards install
RUN scripts/build

WORKDIR /tmp/app/client
RUN npm install
RUN npm run build

## App image
FROM core as app

COPY --from=build /app/server/build/server /app/server
COPY --from=build /app/client/dist/client /app/public

CMD ["/app/server -b $HOST -p $PORT"]
