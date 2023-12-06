= Execution and evaluation

== PostgreSQL

To establish a baseline for comparison, we utilized PostgreSQL as the reference database. We conducted several `pgbench` tests to assess the performance of PostgreSQL. However, the results obtained were not entirely reliable. This is because `pgbench` measures the end-to-end performance of the database, including factors such as network latency and client-side operations. Additionally, the results were not reproducible due to the influence of machine load on database performance. Therefore, the obtained results lack conclusiveness, as they are neither reproducible nor stable.

#figure(caption: [Initial @rw @tps measured by `pgbench`])[
  #image("../../figures/plots/postgres/unlimited/host_only_rw.svg", width: 80%)
] <initial-rw-baseline>

In @initial-rw-baseline, we present our initial measurements of the @tps values of the database. It is important to note that these @tps values were obtained with 10 clients and 1000 transactions per client, while running on a memory-constrained pod. The @tps values hover around the higher 90s, which is relatively low. This can be attributed to the fact that the database is running on a single pod with limited memory resources. The data presented here is an aggregation of 10 `pgbench` runs with the same parameters, excluding the lowest and highest values.

The left side of the graph displays the individual @tps values, while the right side showcases the boxplot representation of the data.
With 10 measurements, we can estimate the @tps values with a certain level of confidence.

In the same test run, we also measured the performance of read-only (@ro) operations. For this particular test case, we utilized 20 clients and 1000 transactions per client. To distribute the requests among the @ro replicas of the database, we employed a NodePort service for load balancing. Naturally, the @tps values for the @ro tests were higher compared to the @rw tests, as the @ro tests do not involve any disk transactions. We observed that the @ro tests were approximately an order of magnitude faster than the @rw tests. This discrepancy is expected, given the nature of the workload and the increased number of clients and servers.

#figure(caption: [Initial @ro @tps measured by `pgbench`])[
  #image("../../figures/plots/postgres/unlimited/host_only_ro.svg", width: 80%)
] <initial-ro-baseline>

In @initial-ro-baseline, we illustrate the distribution of @ro @tps values, which exhibit a wider range compared to the @rw @tps values.
However, it is important to note that the measured @tps values, even after accounting for the greatest outliers, exhibit significant variability.

We use this data to establish a baseline for comparison with the same PostgreSQL setup, but running inside a virtual Kubernetes Cluster.
We expect ther performance to be similar, as the database is running on the same host cluster, but inside a `vcluster` instance.
As before discussed in @vcluster-arch-sec, `vcluster` only maps the pods to a virtual cluster, and real Kubernetes resources are backing every required virtual one.
The overhead of the virtualization comes from the virtual control plane, and the syncer, which is responsible for synchronizing the virtual cluster state with the real (backing) one.

#figure(caption: [Initial @rw @tps measured by `pgbench` inside a virtual Kubernetes cluster])[
  #image("../../figures/plots/postgres/unlimited/rw.svg", width: 80%)
] <initial-rw-vcluster>

In @initial-rw-vcluster, we present the @tps values of the @rw tests, which were conducted inside a virtual Kubernetes cluster compared to the baseline.
The @tps values are around $10$-$15%$ lower than the baseline, which is a significant difference.
However, the variability of the @tps values are increased.
We attribute this to the fact that the PostgreSQL database has unlimited access to the host's CPU.
This may lead to the database having access to more CPU resources in the host cluster than in the virtual cluster, since the virtual cluster requires the continued operation of the virtual control plane and the syncer.

This behaviour is also observed to a lesser effect in the @ro tests, which are presented in @initial-ro-vcluster.

#figure(caption: [Initial @ro @tps measured by `pgbench` inside a virtual Kubernetes cluster])[
  #image("../../figures/plots/postgres/unlimited/ro.svg", width: 80%)
] <initial-ro-vcluster>

We decided to conduct further tests with the RAM limit increased to $8G$ amd a CPU limit set to $4$ cores.
As can be seen in @rw-limits, the @tps values are significantly closer.
The difference between the @tps values is similar to @initial-rw-baseline,
but the @tps values are around $50$-$100%$ higher.
This is expected, as the database has access to more RAM. 


#figure(caption: [Increased resource limits for PostgreSQL])[
  #image("../../figures/plots/postgres/limited/rw.svg", width: 80%)
] <rw-limits>

Under all circumstances, the `pgbench` clients ran on a different virtual machine than the database's host. 