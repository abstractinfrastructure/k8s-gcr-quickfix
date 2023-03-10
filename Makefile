build:
	go build -o bin/booty cmd/main.go

build-docker:
	docker build -t $$(whoami)/k8s-gcr-quickfix:main .

build-push:
	docker push $$(whoami)/k8s-gcr-quickfix:main

run:
	go run cmd/main.go

kind-create:
	kind create cluster --config kind.yaml

kind-apply:
	cp manifests/bundle.yaml .
	sed -i "s/ghcr\.io\/abstractinfrastructure/$$(whoami)/" bundle.yaml
	./install.sh

test: kind-create build-docker build-push kind-apply
	echo "Sleeping 60 because lazy programming"
	sleep 60
	kubectl apply -f tests/badpod.yaml
	kubectl -n default describe pod bad-pod

test-stop:
	kind delete cluster