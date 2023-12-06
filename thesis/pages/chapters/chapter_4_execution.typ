= Execution and evaluation

== PostgreSQL

To create the baseline to compare `vcluster` against, we use PostgreSQL.
Some `pgbench` tests were ran to get a baseline for the performance of
PostgreSQL. These results were not stable, as `pgbench` measured the end-to-end performance of the database, including the network and the client. The results were also not reproducible, as the performance of the database was affected by the load on the machine. The results are not conclusive as they are not reproducible and not stable.

#figure(caption: [Initial @rw @tps measured by `pgbench`])[
  #image("../../figures/plots/postgres/unlimited/host_only_rw.svg", width: 80%)
] <initial-rw-baseline>

In @initial-rw-baseline, we can see the initial @tps of the database.
Note, that this @tps is for $10$ clients and $1000$ transactions per client, with a highly memory-contrained pod. The @tps is in the higher 90s, which is not a lot. This is because the database is running on a single pod, which is memory-constrained. 
This data is from 10 runs of `pgbench` with the same parameters, with the lowest and highest values removed.

On the left side, we can see the individual values, and on the right side, we can see the boxplot of the data. The boxplot shows the median, the first and third quartile, and the minimum and maximum values.

With 10 measurements, we can estimate the @tps with some confidence.

In the same test run we measured @ro performance as well. 
For that test case, we used $20$ clients and $1000$ transactions per client.
We used a NodePort service to load-balance the requests to the @ro replicas of the database.
The @tps of the @ro tests is naturally higher than the @rw tests, as the @ro tests never have to commit any transactions to disk.
We perceive the @ro tests are an order of magnitude faster than the @rw tests.
This is perfectly normal, due to the nature of the workload and the doubling of the clients and servers.

#figure(caption: [Initial @ro @tps measured by `pgbench`])[
  #image("../../figures/plots/postgres/unlimited/host_only_ro.svg", width: 80%)
] <initial-ro-baseline>

In @initial-ro-baseline, we can see the distribution of the @ro @tps is much broader than the @rw @tps.

Under all circumstances, the `pgbench` clients ran on a different virtual machine than the database's host. 