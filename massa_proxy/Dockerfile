FROM elixir:1.10-alpine as builder

ENV MIX_ENV=prod

RUN mkdir -p /app/massa_proxy
WORKDIR /app/massa_proxy

RUN apk add --no-cache --update git

COPY . /app/massa_proxy

RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get 

RUN echo "-sname proxy@${PROXY_POD_IP}" >> /app/massa_proxy/apps/massa_proxy/rel/vm.args.eex \
      && echo "-setcookie ${NODE_COOKIE}" >> /app/massa_proxy/apps/massa_proxy/rel/vm.args.eex

RUN cd /app/massa_proxy/apps/massa_proxy \
    && mix deps.get \
    && mix release.init \
    && mix release

# ---- Application Stage ----
FROM alpine:3
RUN apk add --no-cache --update bash openssl

WORKDIR /home/app
COPY --from=builder /app/massa_proxy/_build .
COPY apps/massa_proxy/priv /app/massa_proxy/_build/prod/lib/massa_proxy/priv

RUN adduser app --disabled-password --home app
RUN chown -R app: ./prod
USER app

ENV MIX_ENV=prod
ENV REPLACE_OS_VARS=true

ENTRYPOINT ["./prod/rel/massa_proxy/bin/massa_proxy", "start"]
