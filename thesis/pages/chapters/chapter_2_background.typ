// LTeX: enabled=true
= Background and Related Work <background>

== What are containers?

Containers are a way to package software in a format that can run isolated on a shared operating system. Unlike virtual machines, containers do not bundle a full operating system - only libraries and settings required to make the software work are needed. This makes for efficient, lightweight, self-contained systems and guarantees that software will always run the same, regardless of where it is deployed.
The use of containers to deploy applications is called containerization.

We can utilize the power of containerization to create a portable, lightweight, and secure environment for running our applications. 
Containers are useful in many settings, including development, testing, and production environments.

== Docker
Docker is a tool that introduced the concept of containers to the masses.
#footnote("BSD had a similar jails feature for a while, however they were not used by the masses, since Linux did not support it.")
It is a platform for developers and sysadmins to develop, deploy, and run applications with containers.
Docker is integrated with DockerHub, a registry of Docker images, which are pre-built containers that include everything needed to run an application. DockerHub is a public registry, but we can also host our own private registry.

While the runtime environment is given with a Docker image, the Docker command line interface (CLI) provides many options that allow us to customize the environment.
The most important options are: ports, volumes, and environment variables.
With the Docker CLI we can open up a container to the host's resources. For example, we can open up a port on the host machine and map it to a port in the container. This allows us to access the containerized application from the host machine.


=== Docker Compose
Docker comes bundled with a tool called Docker Compose, which allows us to easily define and run multi-container applications.
Docker Compose is a tool for defining and running multi-container Docker applications.
Without Docker Compose we would have to use the Docker CLI to run each container individually, which can be cumbersome. It may lead to errors, and it is not very portable.

With Compose, we use a YAML file to configure our application's services. Then, with a single command, we create and start all the services from our configuration. Compose works in all environments: production, staging, development, testing, as well as CI workflows. Using Compose is basically a three-step process:

- Define our app's environment with a Dockerfile, so it can be reproduced anywhere.
- Define the services that make up our app in `docker-compose.yaml` so they can be run together in an isolated environment.
- Use the Docker Compose CLI to run `docker compose up`#footnote("`docker-compose up in previous versions`") and start our app.

Docker Compose is great for single host deployments, but it falls short when it comes to multi-host deployments. For example, if we want to deploy our application to a cluster of machines, we would have to use a different tool, such as Kubernetes.

== Kubernetes

Kubernetes, commonly abbreviated as K8s, is an open-source orchestration system for automating software deployment, scaling, and management.
Originally designed by Google, it is now maintained by the Cloud Native Computing Foundation.
#cite(<kuberntes-wikipedia>)

Kubernetes is used 