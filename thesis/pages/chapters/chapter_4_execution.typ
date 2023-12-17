#import "@preview/glossarium:0.2.4": gls

= Execution and evaluation

== PostgreSQL <postgres-test-exec-sec>

To establish a baseline for comparison, we utilize PostgreSQL as the reference
database. We conduct several `pgbench` tests to assess the performance of
PostgreSQL. However, the results obtained are not entirely reliable. This is
because `pgbench` measures the end-to-end performance of the database, including
factors such as network latency and client-side operations. Additionally, the
results are not reliably reproducible due to the influence of machine load on
database performance. Therefore, the obtained results lack conclusiveness, as
they are neither reproducible nor stable. This will not be an issue for the 
evaluation of the virtual cluster, since we will run the same tests on the
same hardware. In this chapter we present results in the form of box plots,
with the small  addition of the mean line (dashed) next to the median line 
(solid).

#grid(
  columns: (1fr, 1fr),
  [

    #figure(
      caption: [Baseline @rw @tps],
      gap: 2mm,
    )[
      #image("../../figures/plots/postgres/unlimited/host_only_rw.svg", width: 125%)
    ] <initial-rw-baseline>],
  [
    #figure(
      caption: [Baseline @ro @tps],
    )[
      #image("../../figures/plots/postgres/unlimited/host_only_ro.svg", width: 125%)
    ] <initial-ro-baseline>
  ],
)

In @initial-rw-baseline, we present our initial measurements of the @tps values
of the database. It is important to note that these @tps values were obtained
with 10 clients and 1000 transactions per client, while running on a
memory-constrained pod. The @tps values hover around the higher 90s, which is
relatively low. This can be attributed to the fact that the database is running
on a single pod with limited memory resources. The data presented here is an
aggregation of 10 `pgbench` runs with the same parameters, excluding the lowest
and highest values.

In the same test run, we also measured the performance of read-only (@ro)
operations. For this particular test case, we utilize 20 clients and 1000
transactions per client. To distribute the requests among the @ro replicas of
the database, we employ a NodePort service for load balancing. Naturally, the
@tps values for the @ro tests are higher compared to the @rw tests, as the @ro
tests do not involve any disk transactions. We observe, that the @ro tests are
approximately an order of magnitude faster than the @rw tests. This discrepancy
is expected, given the nature of the workload and the increased number of
clients and servers.

In @initial-ro-baseline, we illustrate the distribution of @ro @tps values,
which exhibit a wider range compared to the @rw @tps values. However, it is
important to note that the measured @tps values, even after accounting for the
greatest outliers, exhibit significant variability.

We use this data to establish a baseline for comparison with the same PostgreSQL
setup, but running inside a virtual Kubernetes Cluster. We expect their
performance to be similar, as the database is running on the same host cluster,
but inside a `vcluster` instance. As discussed in @vcluster-arch-sec,
`vcluster` only maps the pods to a virtual cluster, and real Kubernetes
resources are backing every required virtual one. The overhead of the
virtualization comes from the virtual control plane, and the syncer, which is
responsible for synchronizing the virtual cluster state with the real (backing)
one.

#figure(
  caption: [Initial @rw @tps in a virtual Kubernetes cluster],
)[
  #image("../../figures/plots/postgres/unlimited/rw.svg", width: 100%)
] <initial-rw-vcluster>

In @initial-rw-vcluster, we present the @tps values of the @rw tests, which were
conducted inside a virtual Kubernetes cluster compared to the baseline. The left
box plot titled "bare-metal" is the performance of PostgreSQL running on a 
conventional Kubernetes cluster, while the right side "vcluster" shows the 
performance of PostgreSQL running on the virtual Kubernetes cluster. The @tps
values are $7.82%$ lower for the baseline, which is a significant
difference. The variability of the @tps values are also increased.

This behaviour is also observed in the @ro tests, which are
presented in @initial-ro-vcluster. The @tps values decrease by $9.11%$ when 
running on the virtual cluster. 

#figure(
  caption: [Initial @ro @tps measured by `pgbench` inside a virtual Kubernetes cluster],
)[
  #image("../../figures/plots/postgres/unlimited/ro.svg", width: 100%)
] <initial-ro-vcluster>

Recognizing that the outcomes derived from the preceding assessments did not
fully reflect the actual performance of `vcluster`, we opt to undertake
additional tests by elevating the resource constraints for the PostgreSQL
database's pods.

In these subsequent tests, we augment the RAM limit to $8G$ and set the CPU
limit to $4$ cores. As illustrated in the data depicted in @rw-limits, the means
of the throughput values (@tps) exhibit a notably reduced variance. Although the
throughput delta resembles that of @initial-rw-baseline, the values register an
increase of approximately $50$ to $100%$. This augmentation aligns with
expectations, considering the expanded access to RAM by the database.

#figure(caption: [@rw @tps with increased resource limits])[
  #image("/figures/plots/postgres/limited/rw.svg", width: 90%)
] <rw-limits>

Similarly, in @ro-limits, we present the @ro @tps values with the increased
resource limits. The @tps values are more than an order of magnitude higher than
the baseline, but the variability is also increased. This is expected, as the
database has access to more RAM and CPU resources.

We can observe that the virtual cluster and the host cluster caught up to each
other. This we attribute to the fact that the PostgreSQL cluster in the virtual
Kubernetes cluster and cluster in the host Kubernetes cluster now have access to the
same amount of resources. The syncer might have a higher performance overhead for
writing #gls("persistentvolume", suffix: "s", long: true) than reading them.

#figure(caption: [@ro @tps with increased resource limits])[
  #image("/figures/plots/postgres/limited/ro.svg", width: 100%)
] <ro-limits>

=== Measurement with different scales

In @pgbench-sec we introduced `pgbench` and its ability to scale the benchmark
database. We will now use this feature to measure the performance of PostgreSQL
with different scales. We will use the same scale factors for the virtual
cluster and the host cluster.

As discussed in the context of @pgbench-performance-analysis, a battery of tests
are conducted across @sf[s] ranging from $10$ to $200$.
The ensuing section aims to present the outcomes of these tests. Notably, at
the lower scale factors, there is an observable alternation in performance
between the virtual cluster and the host cluster. Although this fluctuation is
attributed to statistical noise, it is evident that no substantive distinctions
are discernible between the two deployment methodologies.

In the subsequent segment, identified as @sf10rw-fig, the ratios of @tps values 
align with the baseline measurements, albeit reflecting relatively diminished 
values. It is important to highlight that the bare-metal cluster consistently 
outperforms the virtual cluster. This performance contrast  could plausibly be 
ascribed to the necessity for traversing the syncer in the virtual cluster 
configuration.

#figure(caption: [@rw performance for @sf=10], image("/figures/plots/postgres/scales/rw_10.svg", width: 100%) ) <sf10rw-fig>

Likewise, in the context of @sf10ro-fig, a discernible trend emerges wherein 
the @tps values for @ro operations surpass those observed in @sf10rw-fig. This 
outcome aligns with expectations since @ro tests exclude write operations to the 
disk. Notably, despite the reduced scaling factor, noteworthy enhancements in 
@tps values are evident compared to the baseline (with a scale factor of $100$). 
This enhancement can be attributed to optimizations implemented in the scaled 
tests, where the number of clients is proportionally adjusted to complement the 
scale factor, as elucidated in @pgbench-performance-analysis.

Furthermore, with these optimizations, a convergence is observed between the 
means and medians, with minimal discernible differences within the margin of 
error. Variability patterns are also comparable, albeit with a slightly higher 
variability observed in the host cluster. This divergence may be attributed to 
both clusters being capable of delivering the required allocation of resources
to the database.

#figure(caption: [@ro performance for @sf=10], image("/figures/plots/postgres/scales/ro_10.svg", width: 100%) ) <sf10ro-fig>

Advancing through the scale factors, we turn attention to @sf = 50 as depicted 
in @sf50rw-fig. We observe our first greater gap in performance comparing 
"bare-metal" and "vcluster" results. This increment aligns with 
expectations, attributed to the heightened presence of parallel workers and a 
greater volume of database rows in comparison to the scenario illustrated in 
@sf=10, as discussed earlier.

Relative to the observations in @sf10rw-fig, it becomes apparent that the 
disparities in both means and medians experience a proportional augmentation. 
This indicative rise underscores that the variability in @tps values is 
concurrently expanding.


#figure(caption: [@rw performance for @sf=50], image("/figures/plots/postgres/scales/rw_50.svg", width: 100%), ) <sf50rw-fig>

Turning our attention to @sf50ro-fig, we observe a higher peak @tps score for
the virtual cluster compared to the host cluster. This is a surprising
result, as the virtual cluster is expected to be slower than the host
cluster. We can attribute this to the fact that the end-to-end nature of
`pgbench` will naturally lead to higher variability in the results. This
is especially true for the virtual cluster as we add an additional layer
of indirection. The medians and means return to comparable values to each other.

`vcluster` seems to be able to keep up with the host cluster, providing similar
performance to bare-metal. This is an expected result, as the virtual cluster
and the host cluster have the same resource limits. 

#figure(caption: [@ro performance for @sf=50], image("/figures/plots/postgres/scales/ro_50.svg", width: 100%) ) <sf50ro-fig>

For the @sf=100 tests we observe the same trends as seen in @sf50rw-fig. and 
@sf50ro-fig. The @tps values for the virtual cluster are lower than the bare-metal cluster for the @rw tests and similar for the @ro tests.

#figure(caption: [@rw performance for @sf=100], image("/figures/plots/postgres/scales/rw_100.svg", width: 100%) ) <sf100rw-fig>

#figure(caption: [@ro performance for @sf=100], image("/figures/plots/postgres/scales/ro_100.svg", width: 100%) ) <sf100ro-fig>

The trends continue in @sf200rw-fig. and @sf200ro-fig, although in the @ro tests
the virtual cluster is slightly more behind the host cluster than in the 
benchmarks before. Here we can see, that the virtual cluster is only able to 
keep up with the host cluster to a certain point. After that, the virtual 
cluster starts to slightly fall behind the host cluster.

#figure(caption: [@rw performance for @sf=200], image("/figures/plots/postgres/scales/rw_200.svg", width: 100%) ) <sf200rw-fig>

#figure(caption: [@ro performance for @sf=200], image("/figures/plots/postgres/scales/ro_200.svg", width: 100%) ) <sf200ro-fig>

In @rw-scales, we present the means of the @rw tests for the different scale
factors. We can observe that the virtual cluster and the host cluster have
similar performance for the smaller scale factors, but the virtual cluster
starts to fall behind the host cluster for the larger scale factors. Both
setups reached their peak performance at @sf=100, and performance start to
fall after that. This is expected as the database has to handle more clients
and more data within the same resource constraints, which will lead to lower performance.

#figure(caption: [@rw @tps with different database scales])[
  #image("/figures/plots/postgres/scales/rw_means.svg", width: 100%)
] <rw-scales>

In @ro-scales, we present the means of the @ro tests for the different scale
factors. We can observe that the virtual cluster and the host cluster have
similar performance for the smaller scale factors, but the virtual cluster
starts to fall behind the host cluster for the largest scale factor. Both
setups reached their peak performance at @sf=50, and performance start to
fall after that. This can be attributed to the same reasons as in @rw-scales.

#figure(caption: [@ro @tps with different database scales])[
  #image("/figures/plots/postgres/scales/ro_means.svg", width: 100%)
] <ro-scales>

=== `vcluster`'s unexpected benefits

During the evaluation of PostgreSQL within a virtual Kubernetes cluster, we
observed an unexpected benefit of `vcluster`. We observed that the Kubernetes
operator managing the PostgreSQL cluster was sluggish when trying to remove
the cluster. Cleaning up the database cluster took a considerable amount of
time, which is not ideal, as we want to be able to quickly remove the cluster
when we are done with it. We can't blame the operator for this, as it is
as we have not delved into tuning to to suit our needs. We can't expect however,
that every operator is highly efficient, and we might encounter similar
problems in the future.

We observed that `vcluster` can help us with this problem. We can create a
virtual cluster, and deploy the database cluster inside the virtual cluster.
When we are done with the database cluster, we can simply delete the virtual
cluster, and the database cluster will be deleted with it. This is a great
benefit, as we can quickly remove the database cluster, and we don't have to
wait for the operator to clean up the cluster.

== Kafka <kafka-test-exec-sec>

In this section, we will evaluate the performance of Kafka running inside a
virtual Kubernetes cluster. We will use the setup described in @kafka-sec, 
within a vcluster and running on a real Kubernetes cluster. We will used the same
setup for the virtual cluster and the host cluster, with the addtition of some
additional configuration for the virtual cluster, as deployment is not as easy 
as on physical clusters. Our testing will focus on latency and not throughput, as 
increasing the througput can be done by scaling the Kafka cluster horizontally.

We used Strimzi's Kafka operator @strimzi to deploy Kafka and Zookeeper on both 
the virtual cluster and the host cluster. We tried to reuse the same configuration 
for both clusters, but we had issues with the virtual cluster, as the virtual 
cluster does not expose the real nodes' IP addresses. This is a problem for the 
Strimzi operator, as it needs to know the IP addresses of the nodes to configure
Kafka's boostrap. We solved this issue by using a custom configuration for the 
virtual cluster, where we manually set the IP addresses of the nodes. This is not 
a problem for the host cluster, as the Strimzi operator can access the real nodes' IP addresses.

#figure(image("/figures/plots/kafka/latency.svg", width: 90%), caption: [Latencies of Kafka]) <kafka-latency>
In @kafka-latency, we present means of different latency measurements for the
virtual cluster and the host cluster. When addressing latency, lower values are 
desireable.We used the different test cases described in @kafka-sec to create a combined plot of the different measurements. We can
observe that the two performance values are similar, within the margin of error.
This is expected, as the virtual cluster and the host cluster have the same
resource limits. The syncer might have some performance overhead, but it is limited.

#figure(image("/figures/plots/kafka/p90.svg", width: 90%), caption: [90#super[th] percentile of Kafka's latencies]) <kafka-p90>

For the 99#super[th] percentile in @kafka-p99, we can observe that the virtual cluster 
once again, exhibits similar performance to the host cluster (within the margin of 
error). 
These results are expected and align with the outcomes of the 90#super[th]
percentile measurements in @kafka-p90.

#figure(image("/figures/plots/kafka/p99.svg", width: 90%), caption: [99#super[th] percentile of Kafka's latencies]) <kafka-p99>

== Functionality Testing -- CRD conflict <crd-conflict-sec>

In this section, we aim to assess the efficacy of `vcluster` in resolving the 
@crd version conflict issue. For this evaluation, we will utilize the @crd 
outlined in @crd-conflict-planning—a straightforward @crd designed to 
accommodate a single version. Our objective is to attempt the application 
of both versions of the @crd to a common host cluster.

The initial application of the first @crd version proves successful. 
However, encountering an error, as indicated in @crd-version-error,
prevents the successful application of the second version.
This scenario prompts further investigation into the capabilities of 
`vcluster` to effectively manage and reconcile conflicting @crd versions
within the host cluster.
#figure(caption: [Applying two versions of the same @crd to the same host cluster])[
  ```
  The CustomResourceDefinition "pdfdocument.k8s.palvolgyid.tmit.bme.hu" is invalid: status.storedVersions[0]: Invalid value: "v1": must appear in spec.versions
  ```
] <crd-version-error>
The anticipated outcome is aligned with the host cluster's inability to
support the application of multiple versions of the same @crd.
To further explore this, we will create a virtual cluster and examine
the feasibility of applying both versions of the @crd within the virtual cluster.

Two distinct `vcluster` instances, denoted as `pdf-v1` and `pdf-v2`,
will be established, each corresponding to a different @crd version.
Both virtual cluster instances will share the same host cluster.
Following this, connections to the virtual clusters will be established,
and the respective @crd versions will be applied. In this instance, 
both versions are successfully applied. Subsequently, we will verify
the @crd versions within their respective virtual clusters, as depicted
in @crd-version-check.
#figure(caption: [Checking the @crd versions in the virtual clusters])[
  ```sh
  $ kubectl get crd pdfdocument.k8s.palvolgyid.tmit.bme.hu -o custom-columns=NAME:.metadata.name,VERSION:.spec.versions[*].name
  # pdf-v1
  NAME                                      VERSION
  pdfdocument.k8s.palvolgyid.tmit.bme.hu    v1 
  # pdf-v2
  NAME                                      VERSION
  pdfdocument.k8s.palvolgyid.tmit.bme.hu    v2
  ```
] <crd-version-check>

We can see that both versions of the @crd are present in their respective
virtual clusters. This solution is not perfect, as we still can not use both
versions from a single cluster. However, this can be a viable solution for 
some applications where the two versions are not used together.

