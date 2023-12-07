= Measurement Planning

My work is focused on the performance of the virtual cluster. How can the
performance of the virtual cluster be defined? What are the metrics that should
be measured? The performance of the virtual cluster can be defined as the
performance of the applications running on the virtual cluster, as well as the
performance of the virtual cluster's control plane.

=== Performance of the Applications

My testing will focus on applications that are often used in the cloud. These
applications are:
- PostgreSQL -- a relational database, most loved by professional developers
  according to StackOverflow's 2023 survey #cite(<stackoverflow-survey>).
- Kafka -- an industry-standard distributed streaming platform

These applications are often deployed in the cloud, and are used by many
companies. Both applications are open-source, and have a large community of
users and contributors. Both applications have respective tools for measuring
their performance. For PostgreSQL, the tool is called `pgbench`, and for Kafka,
the tool is called `kafka-producer-perf-test`.

=== Performance of the Control Plane

Virtual clusters are realized by a virtual control plane and a syncer #cite(<vcluster>).
The virtual control plane is wholly responsible for the performance of "high-level"
resources, such as Deployments, @crd[s], etc. These resources' performance is
can be compared to the performance of the same resources in a conventional
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
runs the virtual control plane. It has 16 cores and 32GB of RAM. All the virtual
machines run Ubuntu 22.04, run on OpenStack, and have AMD EPYC Rome CPUs.

This setup represents a small private cloud cluster. The Kubernetes distribution
that is used is `k3s` #cite(<k3s>), the same which is the default for backing
`vclutster` #cite(<vcluster>). Each machine has a single boot disk. The boot
disk is a 160GB volume, which is more than enough for the operating system and
the applications that are being tested. The boot disk is an SSD volume, which is
the recommended volume type for boot disks in OpenStack.

== Benchmarking PostgreSQL with `pgbench` <pgbench-sec>

Benchmarking PostgreSQL is done using `pgbench` #cite(<pgbench>). It runs a
predefined set of commands on a PostgreSQL database and returns the most
important metrics to the user.

To use `pgbench` to benchmark PostgreSQL, we need to determine the size of the
test data. `pgbench` has an initialization mode, which creates the test data. It
accepts a parameter called `scale`, which determines the size of the test data.
the default value is 1. When the value of `scale` is 1, the test database's
structure is as follows in #ref(<pgbench-scale-1>).

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
utlilized to create a database with $100$ times more data. This is the `scale`
parameter.

PostgreSQL can be hosted from a single node, but in production, it is always
advised to use a cluster of PostgreSQL nodes. The most basic production-ready
cluster is a cluster of $3$ nodes. We can see this in @postgres-cluster. These
nodes are not simply PostgreSQL pods, but rather a main pod and $2$ replica
pods. The data replication is not done by Kubernetes, but rather by PostgreSQL
itself, using the streaming replication feature #cite(<postgres-replication>).
We cannot commit changes to the replica pods, but we can read from them, so they
can be useful as read-caches too beside redundancy. If for whatever reason the
main pod fails, one of the replica pods can be promoted to be the main pod.

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

=== Performance Analysis

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

In our testing environment, we will be running separate worker and controller
nodes, so we will be able to measure the performance unobstructed by `pgbench`'s
own resource usage. We will be running the database cluster on the worker nodes,
and `pgbench` on the controller node.

#import "@preview/big-todo:0.2.0": todo
#todo[Add Kafka measurement planning]
