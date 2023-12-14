ARG BASE_IMAGE=ekidd/rust-musl-builder:latest

FROM ${BASE_IMAGE} AS builder

RUN cargo new --bin esp-tools 
WORKDIR ./esp-tools
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
RUN rm src/*.rs

COPY src ./src
COPY static ./static
COPY templates ./templates

RUN cargo build --release

FROM alpine:latest

ARG APP=/usr/src/app
EXPOSE 8080

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN addgroup -S $APP_USER \
    && adduser -S -g $APP_USER $APP_USER

RUN apk update \
    && apk add --no-cache gcompat libgcc ca-certificates tzdata \
    && rm -rf /var/cache/apk/*

COPY --from=builder /home/rust/src/esp-tools/target/x86_64-unknown-linux-musl/release/esp-tools ${APP}/esp-tools

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["/usr/src/app/esp-tools"]


