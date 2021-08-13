FROM elixir:1.12-alpine as builder

ENV MIX_ENV=prod

RUN mkdir -p /app/massa_proxy
WORKDIR /app/massa_proxy

RUN apk add --no-cache --update git build-base ca-certificates zstd

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.54.0 \
    RUSTFLAGS="-C target-feature=-crt-static"

RUN set -eux; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
    x86_64) rustArch='x86_64-unknown-linux-musl'; rustupSha256='bdf022eb7cba403d0285bb62cbc47211f610caec24589a72af70e1e900663be9' ;; \
    aarch64) rustArch='aarch64-unknown-linux-musl'; rustupSha256='89ce657fe41e83186f5a6cdca4e0fd40edab4fd41b0f9161ac6241d49fbdbbbe' ;; \
    *) echo >&2 "unsupported architecture: $apkArch"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.24.3/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version; 

RUN rustup toolchain install nightly && rustup update && rustup target add wasm32-unknown-unknown --toolchain nightly

COPY . /app/massa_proxy

RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get 

RUN echo "-sname proxy@${PROXY_POD_IP}" >> /app/massa_proxy/apps/massa_proxy/rel/vm.args.eex \
    && echo "-setcookie ${NODE_COOKIE}" >> /app/massa_proxy/apps/massa_proxy/rel/vm.args.eex \
    && echo "+sbwt none" >> /app/massa_proxy/apps/massa_proxy/rel/vm.args.eex \
    && echo "+sbwtdcpu none" >> /app/massa_proxy/apps/massa_proxy/rel/vm.args.eex \
    && echo "+sbwtdio none" >> /app/massa_proxy/apps/massa_proxy/rel/vm.args.eex 

RUN cd /app/massa_proxy/apps/massa_proxy \
    && mix deps.get \
    && mix release.init \
    && mix release

# ---- Application Stage ----
FROM alpine:3
RUN apk add --no-cache --update libgcc ncurses-libs libstdc++ openssl zstd

WORKDIR /home/app
COPY --from=builder /app/massa_proxy/_build/prod/rel/bakeware/ .
COPY apps/massa_proxy/priv /home/app/

RUN adduser app --disabled-password --home app

RUN mkdir -p /home/app/cache
RUN chown -R app: .

USER app

ENV MIX_ENV=prod
ENV REPLACE_OS_VARS=true
ENV BAKEWARE_CACHE=/home/app/cache
ENV PROXY_TEMPLATES_PATH=/home/app/templates

ENTRYPOINT ["./massa_proxy"]
