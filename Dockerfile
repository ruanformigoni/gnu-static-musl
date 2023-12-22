FROM alpine:latest

RUN apk add --no-cache bash curl upx xz build-base git

# RUN git clone https://github.com/ruanformigoni/gnu-static-musl.git
COPY . /gnu-static

WORKDIR gnu-static

RUN ./build.sh
