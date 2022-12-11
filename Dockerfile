## Core image
FROM crystallang/crystal:latest-alpine AS core

ENV NODE_ENV production
ENV KEMAL_ENV production

RUN apk update && \
    apk add --no-cache \
    git nodejs npm \
    ca-certificates tzdata && \
    update-ca-certificates

# RUN crystal -v
# RUN npm -v

## Build image
FROM core as build

WORKDIR /tmp/app
COPY . .

WORKDIR /tmp/app/server
RUN scripts/setup
RUN scripts/build

WORKDIR /tmp/app/client
RUN scripts/setup
RUN scripts/build

## App image
FROM core as app

COPY --from=build /tmp/app/server/dist/server /app/dist/server
COPY --from=build /tmp/app/client/dist/client /app/dist/public

CMD ["/app/bin/server -b $HOST -p $PORT"]
