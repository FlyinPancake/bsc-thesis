#import "@preview/big-todo:0.2.0": todo

= Conclusion
`vcluster` is a great tool for solving the problem of
multi-tenancy, @crd version conflicts in a cluster, and
it does this with very respectable performance. It is
also a great tool for testing and development of
Kubernetes applications.

As outlined in @postgres-test-exec-sec, the performance of vcluster is
very good, and it is able to support a large number of clients connected to it.
As we progressed through the testing, we found that the PostgreSQL operator
was really slow to remove databases from the cluster. This might be a problem
when developing applications for Kubernetes, as it might take a long time to
reset the state of the cluster between tests. This is easier to do with
vcluster as it is able to create and destroy clusters very quickly, and
it is also a remarkably competant tool for switching between contexts, when 
working with multiple clusters.

Later in @kafka-test-exec-sec we found that vcluster was able to run a Kafka
cluster with latencies that were comparable to a real cluster. In this case, 
we found that the operator responsible for managing the Kafka cluster was
built in a way that made it tedious to use with vcluster. This is not a problem
with vcluster, but it is something that should be considered when using vcluster
with some operators.

In a scenario with a small number of developers sharing a single development cluster, virtual clusters can be used to provide a dedicated cluster for each developer. This allows developers to work in isolation, without having to worry about other developers breaking their work.


== Future Work

#todo[Expand on future work]
There are a number of areas that were not covered by this work. These include, but are not limited to:
- Compatibility with the most popular Kubernetes operators
- Compatibility with other Kubernetes distributions - although this is unlikely to be a problem, as vcluster was built to be distribution agnostic
- Behaviour and performance of vcluster when used by multiple users
- Performance limits for entire virtual clusters
- Security of vcluster
  - How to prevent users from accessing other users' virtual clusters
  - How to prevent users from accessing the host cluster
  - How are performance limits enforced
