= Measurement Planning


My work is focused on the performance of the virtual cluster. 
How can the performance of the virtual cluster be defined?
What are the metrics that should be measured?
The performance of the virtual cluster can be defined as the performance of the applications running on the virtual cluster,
as well as the performance of the virtual cluster's control plane.


=== Performance of the Applications

My testing will focus on applications that are often used in the cloud.
These applications are:
- PostgreSQL -- a relational database, most loved by professional developers according to StackOverflow's 2023 survey #cite(<stackoverflow-survey>).
- Kafka -- an industry-standard distributed streaming platform

These applications are often deployed in the cloud, and are used by many companies.
Both applications are open-source, and have a large community of users and contributors.
Both applications have respective tools for measuring their performance. For PostgreSQL, the tool is called `pgbench`, and for Kafka, the tool is called `kafka-producer-perf-test`.


=== Performance of the Control Plane 

Virtual clusters are realized by a virtual control plane and a syncer #cite(<vcluster>).
The virtual control plane is wholly responsible for the performance of "high-level" resources, such as Deployments, @crd[s], etc.
These resources' performance is can be compared to the performance of the same resources in a conventional Kubernetes cluster.

The syncer is responsible for the performance of "low-level" resources, such as Pods, Containers, etc.
These resources exist both in the virtual cluster and in the host cluster.
To measure the performance overhead of the syncer, we need to compare the performance of the same resources in the virtual cluster and in the host cluster.

=== Metrics

The metrics that should be measured vary between the applications.
For PostgreSQL, I went over the documentation of `pgbench` and used the metrics that `pgbench` provides.
I also measured the CPU and memory usage of the PostgreSQL pods inside the virtual cluster and in the host cluster.
I parsed the events of the PostgreSQL pods to measure the time it took for the pods to start.

== Testing environment

The testing environment consists of three virtual machines.
These virtual machines make up a Kubernetes cluster.
Two of the virtual machines are worker nodes, these nodes run the applications that are being tested. They have 32 cores and 64GB of RAM each.
The third system is the controller node, this node runs the virtual control plane. It has 16 cores and 32GB of RAM.
All the virtual machines run Ubuntu 22.04, run on OpenStack, and have AMD EPYC Rome CPUs.

This setup represents a small private cloud cluster.
The Kubernetes distribution that is used is `k3s` #cite(<k3s>),
the same which is the default for backing `vclutster` #cite(<vcluster>).
Each machine has a single boot disk.
The boot disk is a 160GB volume, which is more than enough for the operating system and the applications that are being tested.
The boot disk is an SSD volume, which is the recommended volume type for boot disks in OpenStack.

== PostgreSQL

Benchmarking PostgreSQL is done using `pgbench` #cite(<pgbench>).
It runs a predefined set of commands on a PostgreSQL database and returns the most important metrics to the user.

To use `pgbench` to benchmark PostgreSQL, we need to determine the size of the test data.
`pgbench` has an initialization mode, which creates the test data.
It accepts a parameter called `scale`, which determines the size of the test data. the default value is 1.
When the value of `scale` is 1, the test database's contents look like this:

#figure(caption: [The contents of the test database when `scale` is $1$])[
  #table(
    columns: (auto, auto),
    align: (x, y) => (left, right).at(x),
    inset: 0.5em,
    [*Table name*], [*Number of rows*],
    [`pgbench_branches`], [$1$],
    [`pgbench_tellers`], [$10$],
    [`pgbench_accounts`], [$100000$],
    [`pgbench_history`], [$0$]  
  )
]

I wanted to test PostgreSQL with a larger database, so I used `pgbench`'s initialization mode to create a database with $100$ times more data.

I have planned on testing a PostgreSQL cluster with $3$ nodes. 
These nodes are not simply PostgreSQL pods, but rather a main PostgreSQL pod and $2$ replica PostgreSQL pods.
The replica pods can be used as a read-only database, and the main pod can be used as a read-write database.
By default, `pgbench` runs read-write commands, but
`pgbench` has read-only as well as read-write modes.

The output of `pgbench` contains the following metrics:
- The number of transactions per second (TPS)
- The average latency of a transaction
- The initial latency of the connection

The output includes the relevant configuration arguments of `pgbench`, such as the number of clients, the number of threads, and the scaling factor of the test database.
I re-ran the tests for each scaling factor $10$ times, to eliminate the effect of random fluctuations.


#import "@preview/big-todo:0.2.0": todo
#todo[Add Kafka measurement planning]
