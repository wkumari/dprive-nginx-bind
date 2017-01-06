# Google Container Engine

## Description
These are Google Container Engine (GKE) config files for starting up the dprive-nginx-bind containers.

## Usage / configuration
You will need to edit (at a minimum!) the `image` attribute in `dprive-nginx-bind-deployment.yaml`, and the `loadBalancerIP` attribute in `dprive-nginx-bind-service.yaml` (if you have not reserved a static IP, you can simply remote this attribute and an ephemeral one will be assigned.

## Example usage:
Spinning up deploymment and service:

```
$ kubectl create -f dprive-nginx-bind-deployment.yaml
$ kubectl create -f dprive-nginx-bind-service.yaml
```

Checking:

```
$ kubectl get deployment dprive-nginx-bind
NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
dprive-nginx-bind   1         1         1            1           3d
$ kubectl get service dprive-nginx-bind
NAME                CLUSTER-IP     EXTERNAL-IP       PORT(S)           AGE
dprive-nginx-bind   10.3.242.209   104.196.153.172   853/TCP,443/TCP   8m
```
