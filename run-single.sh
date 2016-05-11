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
    export PATH=`pwd`:$PATH
fi

# Download Vagrant configurations.
if [[ ! -d coreos-kubernetes ]]; then
    git clone https://github.com/coreos/coreos-kubernetes.git
    (
	cd coreos-kubernetes/single-node
	vagrant box update
    )
fi

cd coreos-kubernetes/single-node

# Configure kubectl.
export KUBECONFIG="$(pwd)/kubeconfig"
kubectl config use-context vagrant-single

# Start the virtual cluster.  # You can run vagrant up multiple times
# safely.
vagrant up

echo "Waiting for the cluster to startup"
# TODO(y): It is hacky here.  We don't want to wait if the cluster has been up.
sleep 10
kubectl get nodes


# Now, run a deployment nginx
kubectl run nginx --image=nginx --port=80
if [[ `kubectl get pods -l run=nginx | wc -l | awk '{print $1;}'` == "2" ]]; then
    echo "Pods started"
    if [[ `kubectl get deployments -l run=nginx | wc -l | awk '{print $1;}'` == "0" ]]; then
	echo "But no deployments!?"
    fi
fi

