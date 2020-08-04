FROM elixir:1.10-alpine as builder

ENV MIX_ENV=prod

RUN mkdir /app
WORKDIR /app

RUN apk add --no-cache --update git

RUN mkdir ./config
COPY config/prod.exs ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mix deps.get \
    && mix release.init

RUN echo "-name mongoose_proxy@${PROXY_POD_IP}" >> ./rel/vm.args.eex \
      && echo "-setcookie ${NODE_COOKIE}" >> ./rel/vm.args.eex
    
RUN mix release

# ---- Application Stage ----
FROM alpine:3
RUN apk add --no-cache --update bash openssl

WORKDIR /home/app
COPY --from=builder /app/_build .

RUN adduser app --disabled-password --home app
RUN chown -R app: ./prod
USER app

ENV MIX_ENV=prod
ENV REPLACE_OS_VARS=true

ENTRYPOINT ["./prod/rel/mongoose_proxy/bin/mongoose_proxy", "start"]
