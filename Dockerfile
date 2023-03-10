FROM golang:1.19-alpine

WORKDIR /app

COPY . .

RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -o bin/k8s-gcr-quickfix cmd/main.go

FROM gcr.io/distroless/base-debian10

COPY --from=0 /app/bin/k8s-gcr-quickfix /

ENTRYPOINT [ "/k8s-gcr-quickfix" ]%