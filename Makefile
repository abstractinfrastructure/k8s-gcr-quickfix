build:
	go build -o bin/booty cmd/main.go

build-docker:
	docker build -t $$(whoami)/k8s-gcr-quickfix:main .

build-push:
	docker push $$(whoami)/k8s-gcr-quickfix:main

ssl-cert:
	./generate-keys.sh
	openssl base64 -A <"ssl/ca.crt"

run:
	go run cmd/main.go

kind-create:
	kind create cluster --config kind.yaml

kind-apply:
	kubectl apply -f manifests

test: kind-create build-docker build-push kind-apply

test-stop:
	kind delete cluster