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
2. specifying a *context* in that configuration file via `kubectl
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

### GFW 
按照文档：https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant-single.html 进行时间的时候，vagrant up 正常，但执行 kubectl get nodes 返回错误:
`The connection to the server 172.17.4.99:443 was refused - did you specify the right host or port?`
vagrant ssh 进去之后执行 docker ps 会卡住，没有任何反馈信息，Ctrl +  C 可以终止退出。

> @typhoonzero 描述
> Found something here: https://github.com/coreos/coreos-kubernetes/blob/master/Documentation/kubernetes-on-vagrant.md
> NOTE: **When the cluster `is first launched` , it must download all container images for the cluster components** (Kubernetes, dns, heapster, etc). Depending on the speed of your connection, it can take a few minutes before the Kubernetes api-server is available. Before the api-server is running, the kubectl command above may show output similar to:
>
> The connection to the server 172.17.4.101:443 was refused - did you specify the right host or port?
> Maybe we need a different docker registry in China, or try to use proxies?
>

类似的问题：https://github.com/coreos/coreos-kubernetes/issues/393

初步判断：通过翻墙可以解决下载 Docker Images 失败的问题。

如果说，**第一次vagrant up**的时候并没有翻墙，那么下载**Flannel image**就会失败，导致后面一系列的操作都失败。这个时候，如果没有执行**vagrant destroy**，只是vagrant halt，然后在翻墙的网络下执行vagrant up，那么问题依旧得不到解决。原因是：**When the cluster `is first launched` , it must download all container images for the cluster components。** 

总结：

1. 在GFW环境下，首先要解决翻墙的问题
2. 在翻墙的网络环境下，需要vagrant destroy 所有的vm，重新执行vagrant up



