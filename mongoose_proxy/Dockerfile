FROM erlang:21 AS builder

# Set environment variables for building the application
ENV MIX_ENV=prod \
    TEST=1 \
    LANG=C.UTF-8

# Fetch the latest version of Elixir (once the 1.9 docker image is available you won't have to do this)
RUN set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/v1.9.0-rc.0.tar.gz" \
  && ELIXIR_DOWNLOAD_SHA256="fa019ba18556f53bfb77840b0970afd116517764251704b55e419becb0b384cf" \
  && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
  && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
  && mkdir -p /usr/local/src/elixir \
  && tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
  && rm elixir-src.tar.gz \
  && cd /usr/local/src/elixir \
  && make install clean

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create the application build directory
RUN mkdir /app
WORKDIR /app

# Copy over all the necessary application files and directories
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

# Fetch the application dependencies and build the application
RUN mix deps.get
RUN mix deps.compile
RUN mix release

# ---- Application Stage ----
FROM debian:stretch AS app

ENV LANG=C.UTF-8

# Install openssl
RUN apt-get update && apt-get install -y openssl

# Copy over the build artifact from the previous step and create a non root user
RUN useradd --create-home app
WORKDIR /home/app
COPY --from=builder /app/_build .
RUN chown -R app: ./prod
USER app

# Run the Phoenix app
CMD ["./prod/rel/mongoose_proxy/bin/mongoose_proxy", "start"]