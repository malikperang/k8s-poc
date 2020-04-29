# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = [
    {
        :name => "k8s-master",
        :type => "master",
        :box => "bento/ubuntu-18.04",
        :eth1 => "192.168.30.30",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-worker1",
        :type => "node",
        :box => "bento/ubuntu-18.04",
        :eth1 => "192.168.30.31",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-worker2",
        :type => "node",
        :box => "bento/ubuntu-18.04",
        :eth1 => "192.168.30.32",
        :mem => "2048",
        :cpu => "2"
    }
]

# This script to install k8s using kubeadm will get executed after a box is provisioned
$configBox = <<-SCRIPT
    # Install Docker
    apt update -y
    echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    apt-cache policy docker-ce -y
    apt install docker-ce -y
    sudo systemctl status docker

     # run docker commands as vagrant user (sudo not required)
    usermod -aG docker vagrant

    # Install k8s & kubeadm
    apt-get install -y apt-transport-https curl
    yes | dpkg --configure -a
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    bash -c "cat <<EOF >/etc/apt/sources.list.d/kubernetes.list 
              deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF"
    apt update
    apt install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
    sudo swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    sudo systemctl restart kubelet
SCRIPT

$configMaster = <<-SCRIPT
    # Install k8s master
    kubeadm init --apiserver-advertise-address=192.168.30.30 --apiserver-cert-extra-sans=192.168.30.30 --node-name k8s-master --pod-network-cidr=192.168.30.0/16
    sudo --user=vagrant mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

    # Create connection objects
    kubeadm token create --print-join-command >> /etc/k8s_join.sh
    sudo chmod +x /etc/k8s_join.sh

    # Install Calico pod network addon
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    kubectl taint nodes --all node-role.kubernetes.io/master-

    sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
    sudo service sshd restart
SCRIPT

$configWorker = <<-SCRIPT
    apt install -y sshpass
    sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.30.30:/etc/k8s_join.sh .
    sh ./k8s_join.sh
SCRIPT

Vagrant.configure("2") do |config|

    servers.each do |opts|
        config.vm.define opts[:name] do |config|

            config.vm.box = opts[:box]
            config.vm.hostname = opts[:name]
            config.vm.network :private_network, ip: opts[:eth1]

            config.vm.provider "virtualbox" do |v|
                v.name = opts[:name]
            	v.customize ["modifyvm", :id, "--groups", "/k8s Development"]
                v.customize ["modifyvm", :id, "--memory", opts[:mem]]
                v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
            end

            config.vm.provision "shell", inline: $configBox

            if opts[:type] == "master"
                config.vm.provision "shell", inline: $configMaster
            else
                config.vm.provision "shell", inline: $configWorker
            end
        end
    end
end 