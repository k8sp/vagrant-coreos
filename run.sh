
# Download kubectl.
if [[ `uname` == "Darwin" ]]; then 
    curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.3/bin/darwin/amd64/kubectl
else
    curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.3/bin/linux/amd64/kubectl
fi
chmod +x kubectl

# Download Vagrant configurations.
git clone https://github.com/coreos/coreos-kubernetes.git
cd coreos-kubernetes/multi-node/vagrant

# Use default config.p
mv config.rb.sample config.rb

# Make sure that we use the most recent CoreOS Vagrant boxes.
vagrant box update

# Start the virtual cluster.
vagrant up

# Configure kubectl
export KUBECONFIG="$(pwd)/kubeconfig"
kubectl config use-context vagrant-multi

echo "Waiting for the cluster to startup"
sleep 10
./kubectl get nodes
