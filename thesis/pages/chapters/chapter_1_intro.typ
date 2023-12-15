= Introduction <intro>

Kubernetes stands as the pinnacle in the realm of orchestrating reliable, 
scalable, and portable applications, emerging as the de facto standard for 
hosting cloud-native applications. With widespread support across major cloud 
providers and adaptability for on-premise deployments, Kubernetes excels 
particularly at scale, leveraging substantial resources. However, for smaller 
applications not harnessing Kubernetes' full potential, such as scaling and 
redundant pods, the overhead in cost and complexity may outweigh the benefits.

Effectively operating a Kubernetes cluster entails the use of multiple nodes, 
with a dedicated server for the control plane, the central intelligence of the 
cluster. This resource-intensive configuration translates to a non-trivial 
cost, generally exceeding three times that of a single node — one for the 
control plane and two for worker nodes.

While consolidating multiple applications within a single cluster offers cost 
efficiency, challenges arise. Merging applications within a shared Kubernetes 
cluster raises security concerns, primarily because Kubernetes' separation 
mechanism is not inherently tailored for multi-tenancy but primarily addresses 
naming conflicts. This amalgamation also elevates cluster complexity and 
demands a higher level of technical expertise, potentially resulting in version 
conflicts and other issues. An illustrative example that will be examined 
involves working with multiple versions of Kubernetes operators, each providing 
Custom Resource Definitions @crd[s], which may potentially lead to conflicts.

The concept of virtual clusters presents a novel solution to address these 
challenges. Currently implemented by Loft as part of their managed Kubernetes 
service, the open-source incarnation, known as `vcluster`, is accessible on 
GitHub @vcluster-github licensed under Apache-2.0@apache-2.
Virtual clusters introduce additional separation between applications by 
executing each application within its own virtual cluster atop the shared
Kubernetes infrastructure. It is crucial to note that virtual clusters are 
not merely dockerized single-node Kubernetes clusters; rather, they represent
an innovative and evolving paradigm.

This thesis aims to delve into the intricacies of virtual clusters, examining 
their potential use-cases, limitations, and advantages. The study will 
elucidate the performance characteristics of virtual clusters, drawing 
comparisons with conventional Kubernetes clusters. Additionally, it will 
explore the functional benefits of virtual clusters, shedding light on how they 
can enhance the developer experience and reduce the operational costs 
associated with Kubernetes clusters. Notably, the security implications of 
virtual clusters will not be explored in this thesis, as this topic warrants 
dedicated attention in a separate research endeavour.

#import "@preview/big-todo:0.2.0": todo
#todo[Thesis structure]