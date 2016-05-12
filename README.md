This trial is fully coded in this [bash script](./run.sh).  When you
run this script, it creates a Vagrant cluster of CoreOS VMs following
steps in this
[tutorial](https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant.html).

It is notable that we cannot create a service with type "LoadBalancer"
when we are using a Vagrant cluster, because load balancers are not
something provided by Kubernetes but by the cloud service like AWS,
and Vagrant doesn't provide a Kubernetes load balancer.

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
