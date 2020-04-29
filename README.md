# Kubernetes Proof of Concept with Vagrant.

This is part of my series of learning and orchestrating k8s.

## VM Specifications

- Ubuntu 18.04
- 2 Core CPU's
- 4GB RAM on Master node
- 2GB RAM on Worker's node

## Tools Required

- Vagrant
- Docker

## Kubernetes cluster specification & tools

- Kubeadm
- Calico

This POC consists of three nodes setup.

# Usage

### Initialize Nodes

```
$ vagrant up
```

### Add more Nodes

Append the servers object and customize server specification by your own needs

```
    {
        :name => "k8s-node3",
        :type => "node",
        :box => "bento/ubuntu-18.04",
        :eth1 => "192.168.30.32",
        :mem => "2048",
        :cpu => "2"
    }
```

### Disable a Node

```
$ vagrant halt k8s-node*
```

## Destroy Node

```
$ vagrant destroy k8s-node*
```

## Authors

- **Fariz Izwan** - [Github](https://github.com/malikperang)
