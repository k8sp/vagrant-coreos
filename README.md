This trial is fully coded in this [bash script](./run.sh).  When you
run this script, it creates a Vagrant cluster of CoreOS VMs following
steps in this
[tutorial](https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant.html).

## Pitfalls

### Need to Wait Minutes for Kubernetes to Start

After the Vagrant virtual cluster starts, it will take few minutes for
Kubernetes to start, as described
[here](https://github.com/k8sp/vagrant-coreos/blob/master/run.sh#L45).
Before that, `kubectl` command would complain something like

```
The connection to the server 172.17.4.99:443 was refused - did you specify the right host or port?
```

### Use the Right Client Configuration

We need to let `kubectl` know how to connect to the cluster by

1. specifying a configuration file via something like `export
   KUBECONFIG="$(pwd)/kubeconfig"`, and
1. specifying a *context* in that configuration file via `kubectl
   config use-context vagrant-multi`.

I once forgot to update environment variable `KUBECONFIG` and used a
configuration file that describes a cluster whose VMs are not running.
This causes `kubectl` complaining

```
The connection to the server 172.17.4.99:443 was refused - did you specify the right host or port?
```

### No Load Balancer for Vagrant Cluster

It is notable that we cannot create a service with type "LoadBalancer"
when we are using a Vagrant cluster, because load balancers are not
something provided by Kubernetes but by the cloud service like AWS,
and Vagrant doesn't provide a Kubernetes load balancer.  More details
are here: https://github.com/k8sp/vagrant-coreos/issues/2

Among the three ways for Kubernetes to expose services:

- ClusterIP: use a cluster-internal IP only - this is the default and
  is discussed above. Choosing this value means that you want this
  service to be reachable only from inside of the cluster.
- NodePort : on top of having a cluster-internal IP, expose the
  service on a port on each node of the cluster (the same port on each
  node). You’ll be able to contact the service on any :NodePort
  address.
- LoadBalancer: on top of having a cluster-internal IP and exposing
  service on a NodePort also, ask the cloud provider for a load
  balancer which forwards to the Service exposed as a :NodePort for
  each Node.

we can use NodePort.

The last few lines in the [bash script](./run.sh) creates a Wildfly
pod and expose it by creating a NodePort typed service.  The script
also shows how to find out the VM that runs the Wildfly pod so to
access the Wildfly service from outside of the VM cluster.

According to https://github.com/k8sp/issues/issues/13, we need to
figure out how to create a load balancer for a bare-metal cluster.

### Different Version of Kubernetes Client and Server

It happened that I installed an old version (1.0.1) of Kubernetes
client but used 1.2.3 server.  When I run `kubectl run`, it creates
only pods but no deployment.  This was solved after I upgraded the
client.  More details are here
https://github.com/k8sp/vagrant-coreos/issues/1

<!--  LocalWords:  CoreOS VMs kubectl KUBECONFIG pwd kubeconfig AWS
 -->
<!--  LocalWords:  config LoadBalancer ClusterIP NodePort Wildfly VM
 -->
