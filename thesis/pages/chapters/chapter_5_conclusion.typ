#import "@preview/big-todo:0.2.0": todo

= Conclusion

We conducted tests to assess the performance and usability of `vcluster` in
various scenarios. The results of these tests indicate that `vcluster` is a
promising tool for Kubernetes developers and operators. It is a lightweight
solution that can be used to create and manage virtual clusters with minimal
overhead.

As detailed in @postgres-test-exec-sec, the performance of `vcluster` demonstrates 
its prowess, accommodating a substantial number of connected clients effectively. 
Throughout the testing phase, however, an observation was made regarding the 
PostgreSQL operator's sluggishness in removing databases from the cluster. This 
potential bottleneck could pose challenges during application development for 
Kubernetes, where swift cluster state resets between tests are crucial. In this 
context, `vcluster` stands out as a more efficient tool, enabling rapid creation 
and destruction of clusters. Additionally, its proficiency in seamlessly switching 
between contexts proves advantageous when managing multiple clusters concurrently.

Subsequent exploration, as documented in @kafka-test-exec-sec, revealed that 
`vcluster` performed admirably in running a Kafka cluster with latencies 
comparable to a physical cluster. It is worth noting that challenges were 
encountered with the Kafka cluster manager operator, which was intricately 
designed and posed certain inconveniences when utilized in conjunction with 
`vcluster`. It is important to recognize that such challenges are not inherent to 
`vcluster` itself but may arise with specific operators.

In @crd-conflict-sec we explored the potential for vcluster to solve the @crd 
version conflict problem. This solution may be useful for some other use cases as 
well, but it is not a general solution, as it requires the operator to be aware of 
the virtual cluster. It is also not a complete solution, as it does not solve the 
problem of multiple versions of the same CRD being used in the same cluster.

Several intriguing avenues lie adjacent to the current investigation. For 
instance, exploring the performance of `vcluster` under conditions involving a 
substantial number of users or a high volume of virtual clusters would provide 
valuable insights. Given the versatility mentioned in the documentation, assessing 
how `vcluster` performs across different certified Kubernetes distributions, 
particularly focusing on officially supported ones like `eks` and `k0s`, holds 
notable interest.

The compatibility of `vcluster` with various Kubernetes operators is another 
intriguing dimension to explore. As observed with the Strimzi operator for Apache 
Kafka, investigating the compatibility of popular Kubernetes operators with 
`vcluster` would shed light on the platform's adaptability to diverse use cases.

Delving into the performance limits and guarantees of `vcluster` stands as a 
worthwhile pursuit. Understanding how resource limits are enforced and their 
impact on virtual cluster performance would contribute to a comprehensive 
assessment of `vcluster` capabilities.

Lastly, an exploration into the security aspects of `vcluster` for facilitating 
multi-tenancy is a compelling avenue. As conventional multi-tenancy based solely 
on namespaces may pose security concerns, investigating how `vcluster` can offer a 
secure multi-tenancy solution, ensuring users cannot access each other's virtual 
clusters or the host cluster, would be valuable. 

