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
	cd coreos-kubernetes/multi-node/vagrant
	mv config.rb.sample config.rb # Use default config.p
	vagrant box update
    )
fi

# Start the virtual cluster.
cd coreos-kubernetes/multi-node/vagrant
vagrant up

# Configure kubectl.
export KUBECONFIG="$(pwd)/kubeconfig"
kubectl config use-context vagrant-multi

echo "Waiting for the cluster to startup"
sleep 10
kubectl get nodes
