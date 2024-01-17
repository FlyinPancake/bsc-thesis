= Measurement Planning

== What should be measured?

My work is focused on the performance of the virtual cluster. 
How can the performance of the virtual cluster be defined?
What are the metrics that should be measured?

=== Performance of the virtual cluster

The performance of the virtual cluster can be defined as the performance of the applications running on the virtual cluster,
as well as the performance of the virtual cluster's control plane.

==== Performance of the Applications

My testing will focus on applications that are often used in the cloud.
These applications are:
- PostgreSQL -- a relational database, most loved by professional developers according to StackOverflow's 2023 survey #cite(<stackoverflow-survey>).
- Kafka -- an industry-standard distributed streaming platform

These applications are often deployed in the cloud, and are used by many companies.
Both applications are open-source, and have a large community of users and contributors.
Both applications have respective tools for measuring their performance. For PostgreSQL, the tool is called `pgbench`, and for Kafka, the tool is called `kafka-producer-perf-test`.


==== Performance of the Control Plane 

Virtual clusters are realized by a virtual control plane and a syncer#cite(<vcluster>).
The virtual control plane is wholly reponsible for the performance of "high-level" resources, such as Deployments, @crd[s], etc.
These resources' performance is can be compared to the performance of the same resources in a conventional Kubernetes cluster.

The syncer is responsible for the performance of "low-level" resources, such as Pods, Containers, etc.
These resources exist both in the virtual cluster and in the host cluster.
To measure the performance overhead of the syncer, we need to compare the performance of the same resources in the virtual cluster and in the host cluster.

=== Metrics

The metrics that should be measured vary between the applications.
For PostgreSQL, I went over the documentation of `pgbench` and used the metrics that `pgbench` provides.
I also measured the CPU and memory usage of the PostgreSQL pods inside the virtual cluster and in the host cluster.
I parsed the events of the PostgreSQL pods to measure the time it took for the pods to start.

#import "@preview/big-todo:0.2.0": todo
#todo[Add Kafka measurement planning]
