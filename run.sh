# This trial is mainly based on
# https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant.html
# and http://rafabene.com/2015/11/11/how-expose-kubernetes-services/.

if [[ ! -f ./`basename $0` ]]; then
    echo "Please run this program in the directory where it resides."
    exit
fi

# Download kubectl into the current directory if no kubectl installed yet.
if [[ `which kubectl` == "" ]]; then
    if [[ ! -f ./kubectl ]]; then
	if [[ `uname` == "Darwin" ]]; then 
	    curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.3/bin/darwin/amd64/kubectl
	else
	    curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.3/bin/linux/amd64/kubectl
	fi
	chmod +x kubectl
    fi
fi

export PATH=`pwd`:$PATH

# Download Vagrant configurations.
if [[ ! -d coreos-kubernetes ]]; then
    git clone https://github.com/coreos/coreos-kubernetes.git
    (
	cd coreos-kubernetes/multi-node/vagrant
	cp config.rb.sample config.rb # Use default config.
	vagrant box update
    )
fi

cd coreos-kubernetes/multi-node/vagrant

# Configure kubectl.
export KUBECONFIG="$(pwd)/kubeconfig"
kubectl config use-context vagrant-multi

# Start the virtual cluster.  # You can run vagrant up multiple times
# safely.
vagrant up

echo "Waiting for the cluster to startup for 3 minutes ..."
sleep 360 # It is hacky here. Find someway to way until the Kubernetes cluster starts.

# Now, create an application.  The following YARML files come from
# http://rafabene.com/2015/11/11/how-expose-kubernetes-services/.
kubectl create -f example.yaml
kubectl create -f service.yaml

POD_IP=$(kubectl get nodes | grep Ready | grep -v SchedulingDisabled | awk '{print $1;}')
SVC_PORT=$(kubectl describe service wildfly-service | grep 'NodePort:' | awk '{print $3;}' | cut -f 1 -d '/')
curl http://$POD_IP:$SVC_PORT/employees/

