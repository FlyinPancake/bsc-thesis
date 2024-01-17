// LTeX: enabled=true
#import "@preview/glossarium:0.2.4": make-glossary, print-glossary, gls, glspl
= Background and Related Work <background>

== What are containers?

Containers are a way to package software in a format that can run isolated on a
shared operating system. Unlike virtual machines, containers do not bundle a
full operating system -- only libraries and settings required to make the
software work are needed. This makes for efficient, lightweight, self-contained
systems and guarantees that software will always run the same, regardless of
where it is deployed. The use of containers to deploy applications is called
containerization.

We can utilize the power of containerization to create a portable, lightweight,
and secure environment for running our applications. Containers are useful in
many settings, including development, testing, and production environments.

=== Docker
Docker is a tool that introduced the concept of containers to the masses.
#footnote[
  BSD had a similar feature: jails for a while; however it never reached
  mass-market adoption, since Linux did not support it.",
]

It is a platform for developers and sysadmins to develop, deploy, and run
applications with containers. Docker is integrated with DockerHub, a registry of
Docker images, which are pre-built containers that include everything needed to
run an application. DockerHub is a public registry, but as Docker is a free and
open-source software, one can also host theiw own private registry.

While the runtime environment is given with a Docker image, the Docker command
line interface (CLI) provides many options that allow us to customize the
environment. The most important options are: ports, volumes, and environment
variables. With the Docker CLI we can open up a container to the host's
resources. For example, we can open up a port on the host machine and map it to
a port in the container. This allows us to access the containerized application
from the host machine.

==== Docker Compose
Docker comes bundled with a tool called Docker Compose#footnote[This tool is not exclusive for Docker, there is a runtime-agnostic
implementation called `oci-runtime-compose`, that is in fact forked from Docker
Compose], which allows us to easily define and run multi-container applications.
Without Docker Compose we would have to use the Docker CLI to run each container
individually, which can be cumbersome. It may lead to hacky shell scripts,
resulting in errors, and decreased portability.

With Compose, we use a YAML file to configure our application's services. Then,
with a single command, we create and start all the services from our
configuration. Compose works in all environments: production, staging,
development, testing, as well as CI (Continuous Integration) workflows.#footnote[Usually, the CI workflow has bespoke scripting that uses Compose to build and
  publish the application's images]

Using Compose is a three-step process:

- Define our app's environment with a Dockerfile, so it can be reproduced
  anywhere.
- Define the services that make up our app in `docker-compose.yaml` so they can be
  run together in an isolated environment.
- Use the Docker Compose CLI to run `docker compose up`#footnote[`docker-compose up` in previous versions] and
  start our app.

Docker Compose is great for single host deployments like development
environments, but it falls short when it comes to multi-host deployments. For
example, if we want to deploy our application to many machines, we would have to
use a different tool, such as Kubernetes.

== Kubernetes

Kubernetes, commonly abbreviated as K8s, is an open-source orchestration system
for automating software deployment, scaling, and management. Originally designed
by Google, it is now maintained by the Cloud Native Computing Foundation.
#cite(<kuberntes-wikipedia>)

Kubernetes is used industry-wide to manage containerized applications. It is a
powerful tool that allows us to deploy and manage our applications in a scalable
and reliable way. Scaling allows us to increase the number of containers running
our application, which in turn increases the capacity of our application. This
can be done manually, or automatically, based on certain metrics, such as CPU
usage or memory usage or even custom metrics.

To run an application on Kubernetes, we have to define a set of resources, such
as pods, services, and deployments. These resources together define our
application's environment. They define similar things as Docker Compose, but in
a more complex way.

=== Kubernetes Cluster

A Kubernetes cluster is a set of machines, called nodes, that run containerized
applications managed by Kubernetes. By design, unlike Docker, Kubernetes
operates on a cluster level, not on a single machine. Kubernetes uses a
controller-worker architecture, where the controller is responsible for managing
the cluster, and the worker is responsible for running the applications.

Sometimes it is beneficial to run a Kubernetes cluster on a single machine, or
use the controller node as a worker, but this is not usually recommended for
production environments, only in special cases; for example, when redundancy is
achieved by other means and not necessary in the cluster.

Preferably, Kubernetes clusters are deployed with multiple controller nodes,
which is called a high-availability cluster. This allows for redundancy, and
makes the cluster more resilient to failures. Worker nodes are usually deployed
as multiple nodes too, to allow for horizontal scaling. In case of a worker node
failure, the master node will automatically reschedule the now also failed
workloads onto a healthy worker node.

=== Kubernetes Platforms

Kubernetes is a complex system based on solid protocols and standards. It makes
Kubernetes greatly expandable and customizable. There are many Kubernetes
platforms, which are Kubernetes implementations that are tailored to specific
use cases.

Kubernetes ditributions can become certified by the Cloud Native Computing
Foundation (CNCF). This means that the distribution is compliant with the CNCF's
standards, and is guaranteed to work with other CNCF certified tools.

Kubernetes platforms can be categorized by their approach to hosting Kubernetes.

==== Hosted Kubernetes
Most cloud providers offer their own Kubernetes hosting solutions, which usually
include deep integration with the cloud provider's other services. They are
usually a managed solution, which means that the user does not have to manage
the cluster, only the applications running on it. Some notable examples are:
- Google Kubernetes Engine (GKE)
- Amazon Elastic Kubernetes Service (EKS)
- Azure Kubernetes Service (AKS)
- DigitalOcean Kubernetes

==== Kubernetes Distributions

There are also many Kubernetes distributions, which are maintained by the
company that created the distribution. Some of them are open-source and allow
the user to audit the code, and even contribute to the project. Some notable
examples are:

- k3s -- Lightweight Kubernetes distribution by Rancher Labs
- Ericsson Cloud Container Distribution (ECCD)
- k0s -- Zero Friction Kubernetes
- OpenShift -- Kubernetes distribution by Red Hat
- VMware Tanzu Kubernetes Grid (TKG)
- Canonical Kubernetes (Charmed Kubernetes) -- Kubernetes distribution by
  Canonical
- MicroK8s -- Lightweight Kubernetes distribution by Canonical

==== Kubernetes Installers

Kubernetes installers are tools that allow the user to install Kubernetes on a
set of machines. They usually provide a custom Kubernetes distribution, and a
set of tools tailored to it, to manage the cluster. Some notable examples are:
- `kubeadm` -- Kubernetes installer by the Kubernetes project
- `kind` -- Kuberetes in Docker for development by the Kubernetes project
- `kwok` -- Kubernetes WithOut Kubelet, a simulator by the Kubernetes project
- `kubespray` -- Production ready Kubernetes installer by the Kubernetes project
- `rke` -- Rancher Kubernetes Engine by Rancher Labs

#figure(
  image("../../figures/kubernetes-arch.excalidraw.svg", width: 95%),
  caption: "Kubernetes Architecture",
) <k8s-arch>
=== Kubernetes Components

A Kubernetes cluster is built from building blocks with stable interfaces. An
example "default" Kubernetes cluster's logical components can be seen in
@k8s-arch. We can see, that Kubernets has separate control plane, and worker
processes.

The control plane is responsible for the global, cluster-scoped decisions (i.e.:
scheduling) as well as detecting and acting on cluster events (i.e.: creating a
new pod when a deployment's `replicas` field requires it). Typically all control
plane services run on a dedicated host, but it is not required. Control plane
services include:
- API Server -- The API server is a component of the Kubernetes control plane that
  exposes the Kubernetes API. The API server is the front end for the Kubernetes
  control plane.
- `etcd` -- `etcd` is a distributed reliable key-value store for the most critical
  data of a distributed system. It is used as Kubernetes' backing store for all
  cluster data.
- `sched` -- The Kubernetes scheduler is a control plane process that assigns Pods
  to Nodes. The scheduler determines which Nodes are valid placements for each Pod
  in the scheduling queue according to constraints and available resources.
- `controller-manager` -- The Kubernetes controller manager is a control plane
  process that watches the shared state of the cluster through the API server and
  makes changes attempting to move the current state towards the desired state.
- `cloud-controller-manager` -- The cloud controller manager is a Kubernetes
  control plane component that embeds cloud-specific control logic. The cloud
  controller manager lets you link your cluster into your cloud provider's API,
  and separates out the components that interact with that cloud platform from
  components that just interact with your cluster.

The worker nodes run the Pods that are the components of the application
workload. To achieve this, the worker nodes run the following Kubernetes
processes:
- `kubelet` -- An agent that runs on each node in the cluster. It makes sure that
  containers are running in a Pod.
- `kube-proxy` -- `kube-proxy` is a network proxy that runs on each node in your
  cluster, implementing part of the Kubernetes Service concept.

=== Kubernetes Resources

Kubernetes resources are the building blocks of Kubernetes applications. They
are the basic unit of deployment, and they are used to define the application's
environment. They are defined in YAML files, and can be created, updated, and
deleted with the Kubernetes API.

==== Pods

A Pod is a Resource, that is the basic element of Kubernetes' workload. It is a
group of one or more containers, with shared storage and network resources, and
a specification for how to run the containers. A Pod's contents are always
co-located and co-scheduled, and run in a shared context. A Pod models an
application-specific "logical host": it contains one or more application
containers which are relatively tightly coupled.

Pods are usually created by a controller, such as a Deployment or a StatefulSet.
These controllers are responsible for creating and managing the Pods.

==== Deployments <deployment>

A Deployment is used to descirbe an application's lifecycle. It is a Resource,
that creates and manages ReplicaSets. ReplicaSets are used to ensure that a
specified number of pod replicas are running at any given time.

==== StatefulSets <sts>

StatefulSets are similar to Deployments, however they are used for stateful
applications. They are used to manage the deployment and scaling of a set of
Pods, and provide guarantees about the ordering and uniqueness of these Pods.
Like a Deployment, a StatefulSet manages Pods that are based on an identical
container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity
for each of their Pods.

==== Services

Services describe a method of accessing a set of Pods. They are usually used to
expose an application to the outside world. They can be used to expose an
application inside the cluster too. Services define a logical set of endpoints
-- usually Pods -- and a policy by which to access them.

There are multiple types of Services:
- `ClusterIP` -- Exposes the Service on a cluster-internal IP. Choosing this value
  makes the Service only reachable from within the cluster. This is the default
  `ServiceType`.
- `NodePort` -- Exposes the Service on each Node's IP at a static port (the
  `NodePort`). A `ClusterIP` Service, to which the `NodePort` Service routes, is
  automatically created. You'll be able to contact the `NodePort` Service, from
  outside the cluster, by requesting `<NodeIP>:<NodePort>`. This is similar to
  `--publish` in `docker run`. `NodeProt` Services can use ports in the range
  `30000-32767`.
- LoadBalancer -- Exposes the Service externally using a cloud provider's load
  balancer. `NodePort` and `ClusterIP` Services, to which the external load
  balancer routes, are automatically created.
- ExternalName -- Maps the Service to the contents of the `externalName` field
  (e.g. `foo.bar.example.com`), by returning a `CNAME` record with its value. No
  proxying of any kind is set up. This is useful for transitioning from a
  `externalName` Service to a `ClusterIP` Service.

=== Kubernetes Namespaces

In Kubernetes, namespaces provide a mechanism for isolating groups of resources
within a single cluster. Namespaces provide some level of isolation, however
their primary goal is to prevent scoping issues, since resources' names are
namespace-scoped i.e.: (one can have a pod named `unicorn` in the namespace
`default`, and in the namespace `wonderland` too).

The official Kubernetes documentation mentions, that namespaces should not be
the default method for isolation. For example deployments of slightly different
versions of the same service can be differentiated by using tags. #cite(<kube-docs>)
Namespaces are not a security feature, and provide only limited isolation.

Kubernetes comes with three (plus one) pre-defined namespaces#cite(<kube-docs>):
- `default` -- The default namespace for objects with no other namespace
- `kube-system` -- The namespace for objects created by the Kubernetes system
- `kube-node-lease` -- This namespace for the lease objects associated with each
  node which improves the performance of the node heartbeats as the cluster
  scales.
- `kube-public` -- This namespace is readable by all users (including those not
  authenticated). This namespace is mostly reserved for cluster usage, in case
  that some resources should be visible and readable publicly throughout the whole
  cluster. The public aspect of this namespace is only a convention, not a
  requirement.

=== Kubernetes Operator Pattern

People who run workloads on Kubernetes clusters often like to use automation to
take care of repeatable tasks. The operator pattern captures how you can write
code to automate a task beyond what Kubernetes itself provides.#cite(<kube-docs>)

The operator pattern is a method for extending Kubernetes' functionality. With
operators, we can extend Kubernetes' API with @crd[s], and controllers#cite(<kube-docs>).
This allows us to create custom resources, that can be managed by Kubernetes.
For example, we can create a @crd for a database, and a controller that will
create a database pod when a database resource is created.

A Kubernetes Operator is usually a combination of a controller and a custom
resource definition; however, the latter is not a requirement. Controllers are
responsible for managing the custom resources. They are watching the Kubernetes
API for changes in the custom resources, and act accordingly. Controllers are
usually written in Go, and are compiled into a binary, but that is not a
requirement. There are many libraries that can be used to write controllers in
other languages, such as `kube-rs`#cite(<kube-rs>) for Rust, `KubeOps`@kubeops
for `.NET` and `Kopf`@kopf for Python.

If the controller is made specifically for Kubernetes it usually ships with its
own Custom Resource. Custom Resources are defined by @crd[s]. They are usually
generated from the controller's source code. They can be scoped to a namespace,
or cluster-wide. This will depend on how the controller is implemented and what
the use case is.

The most common Kubernetes Operators can be found in the
OperatorHub@operatorhub, which is a registry of operators. It is maintained by
Red Hat, and is a part of the @olm [#ref(<olm-section>)]. OperatorHub is a great
place to find operators for common use cases, such as databases, message queues,
and monitoring solutions. It provides `helm` charts for easy installation.

#figure(
  image("../../figures/kubernetes-deployment-example.excalidraw.svg"),
  caption: "Simple Kubernetes Deployment",
) <k8s-deployment>
=== A Simple Kubernetes Deployment

In @k8s-deployment we can see a simple Kubernetes deployment, that hosts a web
application. This web application requires a database, which is managed by a
StatefulSet. The database is deployed as two replicas, to ensure high
availability. Its data is stored in @persistentvolume[s], which is mounted to
the database pod. Since our web application is stateless, it can be deployed as
a Deployment. The Deployment ensures that the web application is always running,
and it is scaled to three replicas. It is exposed to the outside world with an
ingress, which is a Kubernetes resource that allows us to expose a service to
the outside world.

=== Common Kubernetes Use Cases

Due to Kubernetes' architecture, it can be adapted to a wide variety of tasks.
The most obvious of them is cloud infrastructure. Many commercial "container
running" solutions use Kubernetes under the hood. Larger organizations can use
Kubernetes to optimize their costs and response times.

The widespread adoption of Kubernetes gave way to a newfound trend to the
microservice architecture, that is well known and loved. Kubernetes allows for
never-before seen flexibility, and it is a great tool for running microservices.

== vCluster

vCluster is an open-source solution, that enables a single Kubernetes cluster to
host multiple virtual Kubernetes clusters. It utilizes Kubernetes' namespaces
feature, and improves on it. Compared to fully separate Kubernetes cluster,
virtual clusters do not have their own node pool nor networking. Instead, they
inherit these from the parent cluster. They are scheduling workloads on the host
cluster, however they have their own virtual control plane.

#figure(
  image("../../figures/vcluster-arch.excalidraw.svg"),
  caption: "vCluster Architecture",
) <vcluster-arch-fig>
=== vCluster Architecture <vcluster-arch-sec>

vCluster is used in conjunction with `kubectl`, the Kubernetes CLI. It creates
an alternative Kubernetes API server, that can be used with `kubectl`. When
connected to the virtual cluster, `kubectl` will behave as if it was connected
to a regular Kubernetes cluster. This is achieved by connecting to the API
server of the virtual cluster control plane #cite(<vcluster>).

As we can see in @vcluster-arch-fig, this control plane has high-level and
low-level components. The high-level components only interact with the
Kubernetes API, and do not have any knowledge of the host cluster. This
includes, but is not limited to: Deployments, StatefulSets, and
CustomResourceDefinitions. Low-level components on the other hand, have to
interact with the host cluster. To do this, they use the vCluster syncer, which
copies the pods created in the virtual cluster to the host cluster. This will
allow the host cluster to schedule the pods.

==== vCluster Control Plane

The vCluster control plane is a set of Kubernetes resources, that are used to
manage the virtual cluster. These resources are:
- *Kubernetes API server* -- this handles the API requests from `kubectl`
- *Data store* -- the API stores its data in a data store, on real clusters this
  is usually etcd
- *Controller Manager* -- the controller manager works similarly to the Kubernetes
  controller manager, however it only manages the virtual cluster's resources
- (Optional) *Scheduler* -- schedules workloads inside the virtual cluster

==== Scheduling

By default, vCluster uses the host cluster's scheduler to schedule pods. This is
done to avoid the overhead of running a scheduler for each virtual cluster,
however it introduces some limitations.
1. Labelling nodes inside the virtual cluster has no effect on scheduling.
2. Draining or tainting the nodes inside the virtual cluster has no effect on
  scheduling.
3. Custom schedulers cannot be used.

To overcome these limitations, vCluster can be configured to use a dedicated
scheduler for each virtual cluster.// #figure(caption: "vCluster Scheduler Configuration")[
//   ```yaml
//     sync:
//       nodes:
//         enabled: true
//         enableScheduler: true
//         # Either syncAllNodes or nodeSelector is required
//         syncAllNodes: true
//     ```
// ]
If the `PersistentVolumeClaim`-s are synced too, the virtual cluster's scheduler
will be able to make storage-aware scheduling decisions.

==== Note on Multi-Namespace Sync
This feature is in alpha state, and is not enabled by default, therefore it was
not used for testing in this thesis.

The multi namespace sync feature allows vCluster to create and manage namespaces
in the host cluster specific to one virtual cluster.

==== Node Syncing
By default, vCluster will create fake nodes in the virtual cluster, that
correspond to the nodes in the host cluster. If there are multiple nodes in the
host cluster, vCluster will only create fake nodes for the nodes, that have pods
from the virtual cluster scheduled on them.

There are other options for node syncing:
- *Real Nodes* -- vCluster will copy the nodes' metadata from the host cluster to
  the virtual cluster. Not all of the nodes will be visible in the virtual
  cluster, only the ones that have pods from the virtual cluster scheduled on
  them, similarly to the default behavior.
- *Real Nodes All* -- vCluster will copy all nodes from the host cluster to the
  virtual cluster. This is useful when DaemonSets are used in the virtual cluster.
- *Real Nodes Label Selector* -- vCluster will only sync nodes that match a
  `key=value` label set on the host cluster nodes. This can be used to create a
  dedicated node pool for the virtual cluster. To enforce this behavior the
  `--enforce-node-selector` flag has to be set.
- *Real Nodes + Label Selector* -- vCluster will sync nodes that match the label
  selector and the information in `spec.nodeName` from vCluster's `values.yaml`
  file.

== Kubernetes Operator Version Conflict <version-conflict-sec>

Especially in case of purpose-built software, it is common to depend on a very
specific version of a Kubernetes operator. This provides a stable environment,
where the operator will be bug-for-bug compatible. However, this can lead to
version conflicts when we introduce some other software that depends on a
different version of the same operator. This is a common problem, and in
Kubernetes namespaces can be used as a workaround, to isolate the different
versions of the operator.

Some of these operators have to be installed cluster-wide, and cannot be
installed in a namespace. This creates a problem, since we cannot use namespaces
to isolate them.

=== #gls("olm", long: true) <olm-section>

@olm is a tool that helps users install, update, and manage the lifecycle of all
Operators and their associated services running across their Kubernetes
clusters. The Operator Lifecycle includes its installation, updates, and removal
in a Kubernetes cluster. Operators can be installed from Catalogs, which are
collections of Operators that have been built, tested, and are maintained for
Kubernetes and OpenShift users by independent software vendors (ISVs), community
members, and Red Hat (the makers of @olm). @olm extends Kubernetes' native API
and CLI to provide a declarative way to manage Operators and their dependencies
in a cluster.

To solve the version conflict dependency resolution can be used. Dependency
resolution solves version mismatch problems by installing the adequate version
of the operator that satisfies all of the version reuqirements in the cluster.
This relies on the the operator follows the semantic versioning scheme, and
declares its dependencies correctly.

For example: if we have two operators: `foo` and `bar` that both depend on
`baz`, @olm will look at the version requirements of `foo` and `bar`. If `foo`
requires `baz` version `1.2` to `1.8`, and `bar` requires `baz` version `1.7`
exactly, @olm will install `baz` version `1.7`, since it satisfies both
requirements.

In an other exampel if `foo` requires `baz` version `1.2` to `1.8`, and `bar`
requires `baz` version `1.9` exactly, @olm will not be able to install `baz`,
since there is no version that satisfies both requirements. In this case, the
user has to manually resolve the conflict somehow. This is why @olm is not a
silver bullet, and it cannot solve all version conflicts.

=== OpenStack Projects

Kubernetes is rarely installed on bare metal, and is usually installed on top of
some cloud infrastructure. OpenStack is a popular open-source cloud
infrastructure software, that is used by many organizations. When using
OpenStack the maintainer has the option to split the installation into multiple
projects, that can be managed separately. This allows for the creation of a
dedicated project for each cluster, which then can be used to isolate the
different versions of the operator.

This solution is not sufficient, since it removes the ability to dynamically
scale the cluster, and the maintenance overhead is increased.

=== How can vCluster help? <vcluster-version-conflict-sec>

Since the @crd[s] can be scoped to cluster-wide or namespace-scoped, we cannot
always use namespaces to isolate the different versions of the operator.
However, vCluster considers the @crd[s] high-level components, as we have seen
in @vcluster-arch-fig and does not sync them to the host cluster. Since the
@crd[s] are not synced to the host cluster, they do not appear in the host
cluster, only in the virtual control plane. This leads to the conclusion, that
we may have conflicting @crd[s], that are isolated to their virtual cluster.

== PostgreSQL

PostgreSQL, an open-source relational database management system (RDBMS), stands
as a robust and versatile solution within the realm of data management.
Developed with a strong emphasis on extensibility, standards compliance, and
ACID (Atomicity, Consistency, Isolation, Durability) properties, PostgreSQL has
emerged as a preferred choice for diverse applications ranging from small-scale
projects to large-scale enterprise systems. Its extensible nature allows users
to define custom data types, operators, and functions, fostering adaptability to
specific project requirements. The support for various programming languages,
including but not limited to, SQL, Python, and Java, further enhances its
flexibility. With a mature and active community contributing to its development,
PostgreSQL continually evolves, incorporating advanced features such as advanced
indexing mechanisms, full-text search capabilities, and support for complex data
types, positioning itself as a pivotal element in the landscape of relational
databases#cite(<postgres-wikipedia>). In this thesis we will utilize PostgreSQL
as an example application, to showcase the performance and capabilities of
vCluster.

// === pgbench

// Pgbench, a benchmarking tool for PostgreSQL is an extra component of PostgreSQL,
// it  enables the assessment of the database system's performance, scalability, and
// concurrency handling. This open-source tool offers a streamlined approach to
// simulate various workloads, aiding researchers and developers in evaluating
// PostgreSQL's capabilities under different conditions. With its simplicity and
// efficiency, pgbench serves as a valuable instrument for gauging the
// responsiveness and stability of PostgreSQL databases.

== Apache Kafka
Apache Kafka, a distributed event streaming platform, plays a pivotal role in
modern data architectures, standing out as a key element in various data
processing scenarios. Built for high-throughput, fault tolerance, and real-time
data streaming, Kafka facilitates the seamless exchange of information between
different components in a distributed system. Its publish-subscribe model and
durable storage capabilities make it ideal for building scalable and resilient
data pipelines. Kafka's ability to handle massive volumes of data with low
latency has made it a go-to solution for applications ranging from real-time
analytics to log aggregation#cite(<kafka-wikipedia>). In this thesis we will
utilize Apache Kafka as an example application, for our latency benchmarks.