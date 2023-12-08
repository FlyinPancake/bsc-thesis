#import "@preview/glossarium:0.2.4": gls

= Execution and evaluation

== PostgreSQL

To establish a baseline for comparison, we utilized PostgreSQL as the reference
database. We conducted several `pgbench` tests to assess the performance of
PostgreSQL. However, the results obtained were not entirely reliable. This is
because `pgbench` measures the end-to-end performance of the database, including
factors such as network latency and client-side operations. Additionally, the
results were not reproducible due to the influence of machine load on database
performance. Therefore, the obtained results lack conclusiveness, as they are
neither reproducible nor stable. This will not be an issue for the evaluation of
the virtual cluster, since we will run the same tests on the same hardware.

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

The left side of the graph displays the individual @tps values, while the right
side showcases the boxplot representation of the data. With 10 measurements, we
can estimate the @tps values with a certain level of confidence.

In the same test run, we also measured the performance of read-only (@ro)
operations. For this particular test case, we utilized 20 clients and 1000
transactions per client. To distribute the requests among the @ro replicas of
the database, we employed a NodePort service for load balancing. Naturally, the
@tps values for the @ro tests were higher compared to the @rw tests, as the @ro
tests do not involve any disk transactions. We observed that the @ro tests were
approximately an order of magnitude faster than the @rw tests. This discrepancy
is expected, given the nature of the workload and the increased number of
clients and servers.

In @initial-ro-baseline, we illustrate the distribution of @ro @tps values,
which exhibit a wider range compared to the @rw @tps values. However, it is
important to note that the measured @tps values, even after accounting for the
greatest outliers, exhibit significant variability.

We use this data to establish a baseline for comparison with the same PostgreSQL
setup, but running inside a virtual Kubernetes Cluster. We expect ther
performance to be similar, as the database is running on the same host cluster,
but inside a `vcluster` instance. As before discussed in @vcluster-arch-sec,
`vcluster` only maps the pods to a virtual cluster, and real Kubernetes
resources are backing every required virtual one. The overhead of the
virtualization comes from the virtual control plane, and the syncer, which is
responsible for synchronizing the virtual cluster state with the real (backing)
one.

#figure(
  caption: [Initial @rw @tps measured by `pgbench` inside a virtual Kubernetes cluster],
)[
  #image("../../figures/plots/postgres/unlimited/rw.svg", width: 100%)
] <initial-rw-vcluster>

In @initial-rw-vcluster, we present the @tps values of the @rw tests, which were
conducted inside a virtual Kubernetes cluster compared to the baseline. The @tps
values are around $10$-$15%$ lower than the baseline, which is a significant
difference. However, the variability of the @tps values are increased.

This behaviour is also observed to a lesser effect in the @ro tests, which are
presented in @initial-ro-vcluster. In the observed virtual cluster, it is
evident that the throughput values (@tps) exhibit an increment similar to the
improvements seen from @initial-rw-baseline to @initial-ro-baseline.

#figure(
  caption: [Initial @ro @tps measured by `pgbench` inside a virtual Kubernetes cluster],
)[
  #image("../../figures/plots/postgres/unlimited/ro.svg", width: 100%)
] <initial-ro-vcluster>

Recognizing that the outcomes derived from the preceding assessments did not
wholly reflect the actual performance of `vcluster`, we opted to undertake
additional tests by elevating the resource constraints for the PostgreSQL
database's pods.

In these subsequent tests, we augmented the RAM limit to $8G$ and set the CPU
limit to $4$ cores. As illustrated in the data depicted in @rw-limits, the means
of the throughput values (@tps) exhibit a notably reduced variance. Although the
throughput delta resembles that of @initial-rw-baseline, the values register an
increase of approximately $50$-$100%$. This augmentation aligns with
expectations, considering the expanded access to RAM by the database.

#figure(caption: [Increased resource limits for PostgreSQL])[
  #image("/figures/plots/postgres/limited/rw.svg", width: 90%)
] <rw-limits>

Similarly, in @ro-limits, we present the @ro @tps values with the increased
resource limits. The @tps values are more than an order of magnitude higher than
the baseline, but the variability is also increased. This is expected, as the
database has access to more RAM and CPU resources.

We can observe that the virtual cluster and the host cluster caught up to each
other. This we attribute to the fact that the PostgreSQL cluster in the virtual
Kubernetes cluster and cluster in the host Kubernetes cluster now access to the
same resource limits. The syncer might have a higher performance overhead for
writing @persistentvolume[s] than reading them.

#figure(caption: [Increased resource limits for PostgreSQL])[
  #image("/figures/plots/postgres/limited/ro.svg", width: 100%)
] <ro-limits>

=== Measuring with different scales

In @pgbench-sec we introduced `pgbench` and its ability to scale the benchmark
database. We will now use this feature to measure the performance of PostgreSQL
with different scales. We will use the same scale factors for the virtual
cluster and the host cluster.

== Functionality Testing -- CRD conflict

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
versions from a single cluster. However this can be a viable solution for 
some applications where the two versions are not used together.

