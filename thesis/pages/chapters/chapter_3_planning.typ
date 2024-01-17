= Measurement Planning

My work is focused on the performance of the virtual cluster. How can the
performance of the virtual cluster be defined? What are the metrics that should
be measured? The performance of the virtual cluster can be defined as the
performance of the applications running on the virtual cluster, as well as the
performance of the virtual cluster's control plane.

=== Performance of the Applications

Our testing will focus on applications that are often used in the cloud. These
applications are PostgreSQL and Apache Kafka. These applications are often
deployed in the cloud, and are used by many companies. Both applications are
open-source, and have a large community of users and contributors. PostgreSQL
has a companion application called `pgbench`
#cite(<pgbench>), which is a benchmarking tool for PostgreSQL. For Kafka, there
is no such tool, so one had to be created.

=== Performance of the Control Plane

Virtual clusters are realized by a virtual control plane and a syncer #cite(<vcluster>).
The virtual control plane is wholly responsible for the performance of "high-level"
resources, such as Deployments, @crd[s], etc. These resources' performance can
be compared to the performance of the same resources in a conventional
Kubernetes cluster.

The syncer is responsible for the performance of "low-level" resources, such as
Pods, Containers, etc. These resources exist both in the virtual cluster and in
the host cluster. To measure the performance overhead of the syncer, we need to
compare the performance of the same resources in the virtual cluster and in the
host cluster.

=== Metrics

The metrics that should be measured vary between the applications. For
PostgreSQL, I went over the documentation of `pgbench` and used the metrics that
`pgbench` provides. I also measured the CPU and memory usage of the PostgreSQL
pods inside the virtual cluster and in the host cluster. I parsed the events of
the PostgreSQL pods to measure the time it took for the pods to start.

== Testing environment

The testing environment consists of three virtual machines. These virtual
machines make up a Kubernetes cluster. Two of the virtual machines are worker
nodes, these nodes run the applications that are being tested. They have 32
cores and 64GB of RAM each. The third system is the controller node, this node
runs the control plane. It has 16 cores and 32GB of RAM. All the virtual
machines run Ubuntu 22.04, run on OpenStack, and have AMD EPYC Rome CPUs.

This setup represents a small private cloud cluster. The Kubernetes distribution
that is used is `k3s` #cite(<k3s>), the same which is the default Kubernetes
controller backing `vcluster` #cite(<vcluster>). Each machine has a single boot
disk. The boot disk is a 160GB volume, which is more than enough for the
operating system and the applications that are being tested. The boot disk is an
SSD volume, which is the recommended volume type for boot disks in OpenStack.
For use with @persistentvolume[s], the storage goes trough longhorn
#cite(<longhorn>), which is a distributed block storage solution for Kubernetes.
Longhorn uses the boot disks as storage, so the boot disks are also used for the
@persistentvolume[s].

== Benchmarking PostgreSQL with `pgbench` <pgbench-sec>

Benchmarking PostgreSQL is done using `pgbench` #cite(<pgbench>). It runs a
predefined set of commands on a PostgreSQL database and returns the most
important metrics to the user.

To use `pgbench` to benchmark PostgreSQL, we need to determine the size of the
test database. `pgbench` has an initialization mode, which creates the test
data. It accepts a parameter called `scale`, which determines the size of the
test data. the default value is 1. When the value of `scale` is 1, the test
database's structure is as follows in #ref(<pgbench-scale-1>).

#figure(caption: [The contents of the test database when `scale` is $1$])[
#table(
  columns: (auto, auto),
  align: (x, y) => (left, right).at(x),
  inset: 0.5em,
  [*Table name*],
  [*Number of rows*],
  [`pgbench_branches`],
  [$1$],
  [`pgbench_tellers`],
  [$10$],
  [`pgbench_accounts`],
  [$100000$],
  [`pgbench_history`],
  [$0$],
)
] <pgbench-scale-1>

To simulate a larger PostgreSQL database, `pgbench`'s initialization mode can be
utlilized to create a database with $100$ times more data.

PostgreSQL can be hosted from a single node, but in production, it is always
advised to use a cluster of PostgreSQL nodes. The most basic production-ready
cluster is a cluster of $3$ nodes. We can see this in @postgres-cluster. These
nodes are not simply PostgreSQL pods, but rather a main pod and $2$ replica
pods. The data replication is not done by Kubernetes, but rather by PostgreSQL
itself, using the streaming replication feature #cite(<postgres-replication>).
We cannot commit changes to the replica pods, but we can read from them, so they
can be useful as read-only databases too beside redundancy. If the main pod
fails for any reason, one of the replica pods can be promoted to become the main
pod.

#figure(caption: [PostgreSQL cluster with a main pod and two replica pods])[
  #image("../../figures/postgres-cluster.excalidraw.svg", width: 80%)
] <postgres-cluster>

By default, `pgbench` runs @rw commands, but `pgbench` has @ro mode as well.
This means that we can run the read-only commands on the replica pods, and the
read-write commands on the main pod. The output of `pgbench` contains the
following metrics:
- @tps
- The average latency of a transaction
- The initial latency of the connection

The output includes the relevant configuration arguments of `pgbench`, such as
the number of clients, the number of threads, and the scaling factor of the test
database.

=== Performance Analysis <pgbench-performance-analysis>

Through the application of scaling, we can effectively emulate a larger
database. Leveraging this scaling factor, we intend to assess the performance of
PostgreSQL under varying conditions, including different scaling factors and
numbers of clients.

The selected scale values for our evaluations are $10$, $20$, $50$, $100$, and $200$.
This choice is grounded in the practical consideration that larger scales would
surpass the resource constraints of our system, resulting in impractical
completion times. It is essential to note that the number of transactions will
consistently be set to 1000. Furthermore, the number of clients will be
established as $"scaling_factor / 10"$. This parameter holds significance, as
setting it excessively high could overwhelm the system. Conventionally, the
number of clients scales in tandem with the size of the database.

In our testing environment, we are running separate worker and controller nodes,
so we will be able to measure the performance unobstructed by `pgbench`'s own
resource usage, as we will are running the database cluster on the worker nodes,
and `pgbench` on the controller node.

== Apache Kafka Performance <kafka-sec>

At a high level, Kafka necessitates similar resources to PostgreSQL. However,
its distinct emphasis on low latency sets it apart from PostgreSQL in terms of
operational priorities.

=== Benchmarking Kafka
Given Kafka's predominant use in diverse production environments, each use case
entails unique configurations, rendering the creation of a generic benchmarking
tool challenging. Unlike PostgreSQL, which has a general benchmarking tool,
`pgbench`, Kafka lacks a comparable standardized benchmarking tool.
Consequently, a custom tool, named `kafka-benchmark`, was developed for this
purpose. Initially, the plan was to implement a Python script for producing and
consuming Kafka messages. However, the performance of this script would have
proven unsatisfactory, prompting a shift to the development of the benchmarking
tool in Rust#cite(<rust>).

The kafka-benchmark tool leverages the `librdkafka`#cite(<librdkafka>) C/C++
library through the `rdkafka`#cite(<rust-rdkafka>) crate#footnote[In the context of Rust programs, libraries and packages are referred to as
  crates] to interface with Kafka. By doing so, it capitalizes on the
performance and features provided by librdkafka, while the Rust language ensures
correctness and reliability for the benchmarking tool. Rust is a systems
programming language, which is designed for performance and reliability. It
differs from popular languages such as C and C++ in that it is memory safe by
default, and from languages such as Java and Go in that it does not have a
garbage collector. Having no garbage collector means that Rust does not iterfere
with the application's execution to free up memory. Combining these two aspects,
Rust makes for an outstanding choice for our benchmarking tool to be written in.
These characteristics are crucially important for benchmarking, as any
bechmarking tool should not interfere with the application's execution,
otherwise the results would be not be accurate.

// #figure(caption: [Architecture of the Kafka cluster])[
//   #image("/figures/kafka-cluster.excalidraw.svg")
// ] <kafka-cluster>

=== Kafka Custer

Our Kafka cluster consists of three nodes for both Kafka and ZooKeeper.
ZooKeeper is a centralized service for maintaining configuration information,
naming, providing distributed synchronization, and providing group services#cite(<zookeeper>).
This differs from the PostgreSQL cluster depicted in @postgres-cluster, where we
had a main pod and replicas, as neither Kafka nor ZooKeeper have a main pod.
They were initially designed to be a distributed system, so they are inherently
behave as such. Kafka and ZooKeeper are both stateful applications, so they
require @persistentvolume[s]. The Kafka cluster is deployed using the Strimzi#cite(<strimzi>) operator.

=== Performance Analysis

Our analysis is concerned with the latency of Kafka. We measure the end-to-end
latency in the conventional Kubernetes cluster, as well as the latency in the
virtual cluster. During the testing, we use different numbers of clients, and
different message sizes. The test parameters are presented in
@kafka-test-parameters. We take all of the possible triplets of the test values,
and we run tests for each of them.

#figure(caption: [The test parameters for Kafka])[
  #table(
    columns: (auto, auto),
    align: (x, y) => (left, right).at(x),
    inset: 0.5em,
    [*Producers*],
    [1,3,5],
    [*Consumers*],
    [1,3,5],
    [*Message Size*],
    [100 B, 1kB],
  )
] <kafka-test-parameters>

Each test will run for $300$ seconds and will be repeaterd $3$ times. We measure
the latency of every message (after a warm-up period), and then we use
HdrHistrogram@hdrhistogram to aggregate the latencies. We record the mean, the
50th percentile, the 90th percentile and the 99th percentile. We will then
compare the latencies across the different tests. We expect the latency to be
higher or equal in the virtual cluster. Due to the nature of this test, we might
see some outliers in the latency measurements.

== Functionality Testing -- CRD coflict <crd-conflict-planning>

As indicated in the context of @version-conflict-sec, version conflicts may
arise when attempting to apply two distinct versions of the same @crd to a
shared cluster. Such situations can materialize when two different applications
rely on the same @crd, albeit with incompatible versions. While this is
typically not problematic, as the majority of @crd[s] are scoped to a specific
namespace, challenges may arise when the relevant @crd is designated as
cluster-scoped.

As outlined in @vcluster-version-conflict-sec, it appears that vcluster
possesses the capability to address such conflicts by segregating conflicting
applications into distinct virtual clusters. This functionality however, has not
been formally documented nor verified. Our objective is to confirm the presence
and effectiveness of this functionality through producing a proof of concept.

Our proof of concept consist of two distinct @crd[s], each with conflicting
versions. We attempt to apply both @crd[s] to a shared cluster, and observe the
resulting behavior. Then we repeat this process with the same @crd[s] applied to
separate virtual clusters, and observe the resulting behavior. The results are
then compared, and we determine whether the virtual cluster approach is
effective in addressing version conflicts. In @test-crd we can observe the
important metadata and spec fields of the @crd which will be used for testing.

#figure([
```yaml
  metadata:
    name: pdfdocument.k8s.palvolgyid.tmit.bme.hu
  spec:
    scope: Cluster
    versions:
      - name: v1 # or v2
```
], caption: [The contents of the test @crd]) <test-crd>

With a conventional Kubernetes cluster, we expect the cluster to apply the first
@crd, and then reject the second @crd, due to it not supporting `v1`. With
multiple vclusters, we expect both clusters to apply their @crd[s]. We will then
verify the presence of both @crd[s] in the cluster, and confirm that they are
indeed separate versions.

This test will not be concerned with the functionality of the @crd[s]
themselves, as there is no backing controller for them, but rather with the
behavior of the cluster when presented with conflicting @crd[s]. As such, we
will not be testing the functionality of the @crd[s] themselves, but rather the
behavior of the cluster when presented with conflicting @crd[s].