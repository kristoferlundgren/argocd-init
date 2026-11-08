# Argo CD deployment

This repository bootstraps Argo CD into the `argocd` namespace and creates an
Argo CD `Application` that manages the Argo CD Helm chart itself. After
bootstrap, the Application can sync chart changes, including upgrades, from the
version configured in `templates/Application.yaml`.

## Requirements

- A Kubernetes cluster and a `kubectl` context with permission to install Argo
  CD, including its cluster-scoped resources.
- `helm`, `kubectl`, `kubens`, and `argocd` on your `PATH`.

The versions in `mise.toml` can be installed with `mise install`.

## Bootstrap

Check that `kubectl` points to the intended cluster, then run:

```sh
./bootstrap.sh
```

The script adds and updates the Argo Helm repository, renders and applies the
chart version specified by `templates/Application.yaml`, applies the initial
Application and AppProjects, then switches to the `argocd` namespace and logs
in with `argocd login --core` to list Applications.

The bootstrap script creates the namespace with `kubectl create namespace`;
it is intended for initial setup and will fail if that namespace already
exists. Argo CD then reconciles its own Helm release using the configured
automated sync policy.

## Security context

The chart sets `openshift.enabled: false` for this OrbStack cluster, retaining
the chart's standard security contexts. For OpenShift SCCs, set it to `true`
and set `redis.securityContext.runAsUser: null`; the OpenShift flag does not
change Redis's pod security context.
