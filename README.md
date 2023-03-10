# k8s.gcr.io Quick Fix(es)

This repo is a rather quickly thrown together set of resources to help out in case you have a cluster that still references `k8s.gcr.io` for many core images.

If you are unsure whether you are affected by this, please use the [community-images](https://github.com/kubernetes-sigs/community-images) put together by the [Kubernetes Community](https://kubernetes.io)

## Solution 1: Mutating Webhook

tl;dr: Run this command on your cluster, assuming you have `kubeadmin` permissions:

```
kubectl apply -f https://raw.githubusercontent.com/abstractinfrastructure/k8s-gcr-quickfix/main/manifests/bundle.yaml
```

This will create a MutatingWebhook in your cluster that watches for any **new** pod to be created, and will automatically replace `k8s.gcr.io` with `registry.k8s.io`.

The logic behind it is in [cmd/main.go](cmd/main.go). The one note: It has a self-signed certificate bundled with it. We can't assume every cluster is running [cert-manager](https://cert-manager.io), and this is the easiest way to move forward.

## Solution 2: Kyverno Policy

tl;dr: Run this command on your cluster, assuming you have [Kyverno](https://kyverno.io) installed on the cluster:

```
kubectl apply -f https://raw.githubusercontent.com/abstractinfrastructure/k8s-gcr-quickfix/main/kyverno-policy.yaml
```

This will create a Kyverno Policy that will behave exactly like Option 1. Kyverno will watch for any Pod that's Created or Updated and automatically replace `k8s.gcr.io` with `registry.k8s.io`.

## Relevant Links

[registry.k8s.io: faster, cheaper and Generally Available (GA)](https://kubernetes.io/blog/2022/11/28/registry-k8s-io-faster-cheaper-ga/)

[k8s.gcr.io Image Registry Will Be Frozen From the 3rd of April 2023](https://kubernetes.io/blog/2023/02/06/k8s-gcr-io-freeze-announcement/)

## Help Wanted

This is a community problem, and there are likely more/better ways to solve this. Please contribute, file issues, or reach out to either [@jeefy](https://www.twitter.com/jeefy) or [@mrbobbytables](https://www.twitter.com/mrbobbytables) with questions.