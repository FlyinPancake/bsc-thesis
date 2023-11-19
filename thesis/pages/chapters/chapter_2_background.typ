// LTeX: enabled=true
= Background and Related Work <background>

== What are containers?

Containers are a way to package software in a format that can run isolated on a shared operating system. Unlike virtual machines, containers do not bundle a full operating system - only libraries and settings required to make the software work are needed. This makes for efficient, lightweight, self-contained systems and guarantees that software will always run the same, regardless of where it is deployed.
The use of containers to deploy applications is called containerization.

We can utilize the power of containerization to create a portable, lightweight, and secure environment for running our applications. 
Containers are useful in many settings, including development, testing, and production environments.

=== Docker
Docker is a tool that introduced the concept of containers to the masses.
#footnote("BSD had a similar jails feature for a while, however they were not used by the masses, since Linux did not support it.")
It is a platform for developers and sysadmins to develop, deploy, and run applications with containers.
Docker is integrated with DockerHub, a registry of Docker images, which are pre-built containers that include everything needed to run an application. DockerHub is a public registry, but we can also host our own private registry.

While the runtime environment is given with a Docker image, the Docker command line interface (CLI) provides many options that allow us to customize the environment.
The most important options are: ports, volumes, and environment variables.
With the Docker CLI we can open up a container to the host's resources. For example, we can open up a port on the host machine and map it to a port in the container. This allows us to access the containerized application from the host machine.


==== Docker Compose
Docker comes bundled with a tool called Docker Compose, which allows us to easily define and run multi-container applications.
Docker Compose is a tool for defining and running multi-container Docker applications.
Without Docker Compose we would have to use the Docker CLI to run each container individually, which can be cumbersome. It may lead to errors, and it is not very portable.

With Compose, we use a YAML file to configure our application's services. Then, with a single command, we create and start all the services from our configuration. Compose works in all environments: production, staging, development, testing, as well as CI workflows. Using Compose is basically a three-step process:

- Define our app's environment with a Dockerfile, so it can be reproduced anywhere.
- Define the services that make up our app in `docker-compose.yaml` so they can be run together in an isolated environment.
- Use the Docker Compose CLI to run `docker compose up`#footnote("`docker-compose up in previous versions`") and start our app.

Docker Compose is great for single host deployments, but it falls short when it comes to multi-host deployments. For example, if we want to deploy our application to a cluster of machines, we would have to use a different tool, such as Kubernetes.

=== Kubernetes

Kubernetes, commonly abbreviated as K8s, is an open-source orchestration system for automating software deployment, scaling, and management.
Originally designed by Google, it is now maintained by the Cloud Native Computing Foundation.
#cite(<kuberntes-wikipedia>)


Kubernetes is used industry-wide to manage containerized applications.
It is a powerful tool that allows us to deploy and manage our applications in a scalable and reliable way.
Scaling allows us to increase the number of containers running our application, which in turn increases the capacity of our application.
This can be done manually, or automatically, based on certain metrics, such as CPU usage or memory usage or even custom metrics.

To run an application on Kubernetes, we have to define a set of resources, such as pods, services, and deployments.
These resources together define our application's environment.
They define similar things as Docker Compose, but in a more complex way.

==== Kubernetes Cluster

A Kubernetes cluster is a set of machines, called nodes, that run containerized applications managed by Kubernetes.
By design, unlike Docker, Kubernetes operates on a cluster level, not on a single machine.
Kubernetes uses a master-slave architecture, where the master is a controller is responsible for managing the cluster, and the slave is a worker is responsible for running the applications.

In some cases one can run a Kubernetes cluster on a single machine, or use the controller node as a worker, but this is not recommended for production environments.

On the other end of the spectrum, Kubernetes can be deployed utilizing multiple controller nodes, which is called a high-availability cluster.

In case of a worker node failure, the master node will automatically reschedule the failed pods on a healthy node.

==== Kubernetes Distributions

Kubernetes is a complex system based on solid protocols and standards.
It makes Kubernetes greatly expandable and customizable.
There are many Kubernetes distributions, which are Kubernetes implementations that are tailored to specific use cases.
Kubernetes distributions are usually bundled with other tools that make it easier to deploy and manage Kubernetes clusters.

Most cloud providers offer their own Kubernetes distributions, which are usually managed by the cloud provider.
Some notable examples are:
- Google Kubernetes Engine (GKE)
- Amazon Elastic Kubernetes Service (EKS)
- Azure Kubernetes Service (AKS)

There are also many open-source Kubernetes distributions, which are usually maintained by the community, and expect the user to manage the cluster.
Some notable examples are:
- kubeadm -- Kubetnetes' official reference implementation
- k3s -- Lightweight Kubernetes distribution by Rancher Labs
- k0s -- Zero Friction Kubernetes
- MicroK8s -- Lightweight Kubernetes distribution by Canonical
- miniKube -- Lightweight Kubernetes distribution by Kubernetes for local development


#figure(image("../../figures/kubernetes-arch.excalidraw.svg"), caption: "Kubernetes Architecture")
==== Kubernetes Components

A Kubernetes cluster is built from open-source building blocks. 
Kubernetes has separate control plane, and worker processes. 

The control plane is responsible for the global, cluster-scoped decisions (i.e.: scheduling)
as well as detecting and acting on cluster events (i.e.: creating a new pod when a deployment's `repllicas` field requires it). 
Typically all control plane services run on a dedicated host, but it is not required.
Control plane services include: 
- API Server -- The API server is a component of the Kubernetes control plane that exposes the Kubernetes API. The API server is the front end for the Kubernetes control plane.
- etcd -- etcd is a distributed reliable key-value store for the most critical data of a distributed system. It is used as Kubernetes' backing store for all cluster data.
- sched -- The Kubernetes scheduler is a control plane process that assigns Pods to Nodes. The scheduler determines which Nodes are valid placements for each Pod in the scheduling queue according to constraints and available resources.
- controller-manager -- The Kubernetes controller manager is a control plane process that watches the shared state of the cluster through the API server and makes changes attempting to move the current state towards the desired state.
- cloud-controller-manager -- The cloud controller manager is a Kubernetes control plane component that embeds cloud-specific control logic. The cloud controller manager lets you link your cluster into your cloud provider's API, and separates out the components that interact with that cloud platform from components that just interact with your cluster.

The worker nodes host the Pods that are the components of the application workload.
The worker nodes run the following Kubernetes processes:
- kubelet -- An agent that runs on each node in the cluster. It makes sure that containers are running in a Pod.
- kube-proxy -- kube-proxy is a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept.

==== Kubernetes Namespaces

In Kubernetes, namespaces provide a mechanism for isolating groups of resources within a single cluster.
Namespaces provide some level of isolation, however their primary goal is to prevent scoping issues, since resources' names are namespace-scoped i.e.: (one can have a pod named `unicorn` in the namespace `default`, and in the namespace `wonderland` too).

The official Kubernetes documentation mentions, that namespaces should not be the default method for isolation.
For example deployments of slightly different versions of the same service can be differentiated by using tags. #cite(<kube-docs>)



==== Kubernetes use-cases

Due to Kubernetes' architecture, it can be adapted to a wide variety of tasks.
The most obvious of them is cloud infrastructure.
Many commercial "container running" solutions use Kubernetes under the hood.
Larger organizations can use Kubernetes to optimize their costs and response times.

The widespread adoption of Kubernetes gave way to a newfound hype 
to the microservice architecture, that is well known and loved.
Kubernetes allows for never-before seen 

== Vcluster

Vcluster is an open-source solution, that enables a single Kubernetes
cluster to host multiple virtual Kubernetes clusters.
It utilizes Kubernetes' namespaces feature, and improves on it.
Compared to fully separate Kubernetes cluster, virtual clusters do not have their own node pool nor networking. Instead, they inherit these from the parent cluster.
They are sheduleing workloads on the host cluster, however they have their own virtual control plane.

#figure(image("../../figures/vcluster-arch.excalidraw.svg"), caption: "Vcluster Architecture")
=== Vcluster Architecture
