#!/bin/bash

openssl genrsa -out ca.key 2048

openssl req -new -x509 -days 365 -key ca.key \
  -subj "/C=AU/CN=gcr-to-registry-webhook.kube-system.svc"\
  -out ca.crt

openssl req -newkey rsa:2048 -nodes -keyout server.key \
  -subj "/C=AU/CN=gcr-to-registry-webhook.kube-system.svc" \
  -out server.csr

openssl x509 -req \
  -extfile <(printf "subjectAltName=DNS:gcr-to-registry-webhook.kube-system.svc") \
  -days 365 \
  -in server.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt

echo
echo ">> Generating kube secrets..."
kubectl -n kube-system create secret tls k8s-gcr-quickfix-tls \
  --cert=server.crt \
  --key=server.key \

CA=$(base64 ca.crt | tr '\n' ' ' | sed 's/ //g')

echo
echo ">> MutatingWebhookConfiguration caBundle: $CA"

if [ ! -f "bundle.yaml" ]; then
    curl https://raw.githubusercontent.com/abstractinfrastructure/k8s-gcr-quickfix/main/manifests/bundle.yaml --output bundle.yaml
fi
sed -i "s/REPLACEME/$CA/" bundle.yaml

kubectl apply -f bundle.yaml

rm ca.crt ca.key ca.srl server.crt server.csr server.key bundle.yaml

echo
echo "K8s-GCR-Quickfix is now installed."