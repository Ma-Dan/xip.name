FROM golang:1.12-alpine3.9 as golang

ADD . /go/src/github.com/xip.name
WORKDIR /go/src/github.com/xip.name

RUN apk add --update --no-cache ca-certificates git

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=linux

RUN mkdir -p /xip.name
RUN go build -v -a -installsuffix cgo -ldflags '-w' -o /xip.name/xip xip.go


FROM alpine:3.9
RUN apk add --no-cache bash ca-certificates curl
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# modify pod (container) timezone
RUN apk add -U tzdata && ls /usr/share/zoneinfo && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && apk del tzdata

COPY --from=golang /xip.name/xip /xip.name/xip

EXPOSE 53