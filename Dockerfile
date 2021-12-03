FROM golang:1.16-alpine3.15

WORKDIR /src

COPY go.mod .
COPY go.sum .
COPY app.go .

RUN go build app.go && chmod +x app

CMD ["./app"]

