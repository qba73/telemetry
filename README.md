# telemetry

`telemetry` is a Go package that illustrates how to use Kubernetes fake objects in tests.

## Create Development and Test Environment

Create multi-node [Kind](https://kind.sigs.k8s.io) cluster:

```shell
make create-cluster
```

Destroy Kind cluster:

```shell
make delete-cluster
```
