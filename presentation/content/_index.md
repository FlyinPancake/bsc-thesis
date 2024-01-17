+++
title = "Performance and usability analysis of virtual clusters in Kubernetes"
outputs = ["Reveal"]

+++

<link rel="stylesheet" href="//unpkg.com/@catppuccin/highlightjs/css/catppuccin-macchiato.css">

<section data-noprocess>
<h1 align="left">Performance and usability analysis of <span  style="color:#fab387">virtual clusters</span> in
<span style ="color: #89dceb">Kubernetes</span>
<!-- <img src="k8s.svg" alt="Kubernetes logo" width="75" height="75"> -->
</h1>
</section>

---
{{% section %}}

# <span style ="color: #89dceb">Kubernetes</span>

---

## What is <span style ="color: #89dceb">Kubernetes</span>

{{% fragment %}}Container orchestration{{% /fragment %}}
{{% fragment %}}Cloud-native{{% /fragment %}}
{{% fragment %}}Open-source{{% /fragment %}}
{{% fragment %}}Since 2014{{% /fragment %}}

---

## <span style ="color: #89dceb">Kubernetes</span> Cluster

{{% fragment %}}The greatest unit of Kubernetes{{% /fragment %}}
{{% fragment %}}A set of machines called nodes{{% /fragment %}}
{{% fragment %}}Nodes are VMs or physical machines{{% /fragment %}}
{{% fragment %}}The control plane manages the Nodes{{% /fragment %}}

---

## Modifying <span style ="color: #89dceb">Kubernetes</span>

{{% fragment %}}Modular design{{% /fragment %}}
{{% fragment %}}Stable interfaces{{% /fragment %}}
{{% fragment %}}Parts can be exchanged for others{{% /fragment %}}
{{% fragment %}}Tooling works with no regard to distribution{{% /fragment %}}
{{% fragment %}}_in theory_{{% /fragment %}}

---

## <span style ="color: #89dceb">Kubernetes</span> Distributions

{{% fragment %}}Kubernetes is a platform{{% /fragment %}}
{{% fragment %}}Distributions are implementations{{% /fragment %}}
{{% fragment %}}Distributions are opinionated{{% /fragment %}}
{{% fragment %}}Distributions are not interchangeable{{% /fragment %}}

---

### Notable Distributions

{{% fragment %}}**Vanilla Kubernetes (k8s)**{{% /fragment %}}
{{% fragment %}}**k3s**{{% /fragment %}}
{{% fragment %}}k0s{{% /fragment %}}
{{% fragment %}}MicroK8s{{% /fragment %}}
{{% fragment %}}_any many others_{{% /fragment %}}

{{% /section %}}

---
{{% section %}}

# <span  style="color:#fab387">Virtual Clusters</span>

---

## What is a <span  style="color:#fab387">Virtual Cluster</span>

{{% fragment %}}It is [`vcluster`](https://www.vcluster.com/)!{{% /fragment %}}
{{% fragment %}}A Kubernetes cluster inside a cluster{{% /fragment %}}
{{% fragment %}}But not really{{% /fragment %}}
{{% fragment %}}Subdivision of a real Kubernetes cluster{{% /fragment %}}

---
{{< slide background="#000" >}}

## How <span  style="color:#fab387">`vcluster`</span> works?

![vcluster architecture](vcluster-arch.svg)

---

## Advantages of <span  style="color:#fab387">`vcluster`</span>

{{% fragment %}}Easy **creation** and **deletion**{{% /fragment %}}
{{% fragment %}}**Small overhead**, compared to separate clusters{{% /fragment %}}
{{% fragment %}}All resources **mapped** to the host cluster{{% /fragment %}}
<!-- {{% fragment %}}Solves Operator version conflicts {{% /fragment %}} -->

{{% /section %}}

---
{{% section %}}

<h1 align="center"><span style ="color: #89dceb">Kubernetes</span> Operator <br> Version Conflicts</h1>

---

## <span style ="color: #89dceb">Kubernetes</span> Operators

{{% fragment %}}Operators are Kubernetes applications{{% /fragment %}}  
{{% fragment %}}They manage other applications{{% /fragment %}}
{{% fragment %}}They are installed as Kubernetes resources{{% /fragment %}}
{{% fragment %}}`CustomResourceDefinition` + controller (in a pod){{% /fragment %}}
---

{{< slide background="#000" >}}
![Operator Version Conflict](operator-version-conflict.svg)

---

## How can <span  style="color:#fab387">`vcluster`</span> help?

---
{{< slide background="#000" >}}

![vcluster Operator Version Conflict](operator-version-conflict-resolution.svg)

---

## Is this a good solution?

<!-- Table of pros and cons -->

<table>
<th class="fragment" data-fragment-index="10">Pros</th>
<th class="fragment" data-fragment-index="20">Cons</th>
<hor>
<tr>
<td class="fragment" data-fragment-index="11">Easy to use</td>
<td class="fragment" data-fragment-index="21">Performance overhead</td>
</tr>

<tr>
<td class="fragment" data-fragment-index="12">Both apps just work</td>
<td class="fragment" data-fragment-index="22">Added dependency</td>
</tr>

<tr>
<td class="fragment" data-fragment-index="13">Apps in different clusters</td>
<td class="fragment" data-fragment-index="23">Apps in different clusters</td>
</tr>
<!-- <tr>
<td class="fragment" data-fragment-index="14">No need to modify the operator</td>
<td class="fragment" data-fragment-index="24">Not a complete solution</td>
</tr> -->
</table>

---

## Testing

{{% fragment %}}Conducted testing with 2 CRDs{{% /fragment %}}
{{% fragment %}}These CRDs were incompatible{{% /fragment %}}
{{% fragment %}}Used `vcluster` to solve the conflict{{% /fragment %}}
{{% fragment %}}`vcluster` allowed both of the CRDs to be applied{{% /fragment %}}

{{% /section %}}

---
{{% section %}}

# <span  style="color:#fab387">`vcluster`</span> Performance

<!-- <span style="font-size: 0.5em">⚠️ Bright slides ahead ⚠️</span> -->

---

## Test scenarios

<div style="flex flex-dir: row; justify-content: space-evenly;">
<img src="Postgresql.svg" alt="PostgreSQL logo" width="150" height="150">

<img src="Apache_kafka.svg" alt="Apache Kafka logo" width="150" height="150" style="filter: invert(1)">
</div>
{{% /section %}}

---
{{% section %}}

# PostgreSQL

> <p style="font-size: 0.8em">throughput testing</p>

---

## Methodology

{{% fragment %}}Used `pgbench` with different scales{{% /fragment %}}
{{% fragment %}}Used `S = 10, 20, 50, 100, 200`{{% /fragment %}}
{{% fragment %}}Used `pgbench` inside `vcluster`{{% /fragment %}}
{{% fragment %}}Used `pgbench` outside `vcluster`{{% /fragment %}}

---

# Results

---
{{< slide background="#FFF" >}}

### <span style="color: #000">`S = 10` RO</span>

![pgbench S=10](figures/plots/postgres/scales/ro_10.svg)

---
{{< slide background="#FFF" >}}

### <span style="color: #000">`S = 10` R/W</span>

![pgbench S=10](figures/plots/postgres/scales/rw_10.svg)

---
{{< slide background="#FFF" >}}

### <span style="color: #000">`S = 100` RO</span>

![pgbench S=10](figures/plots/postgres/scales/ro_100.svg)

---
{{< slide background="#FFF" >}}

### <span style="color: #000">`S = 100` R/W</span>

![pgbench S=10](figures/plots/postgres/scales/rw_100.svg)

---
{{< slide background="#FFF">}}

### <span style="color: #000">Comparison of different S values (RO)</span> 

![pgbench S=all](figures/plots/postgres/scales/ro_means.svg)


---
{{< slide background="#FFF">}}

### <span style="color: #000">Comparison of different S values (R/W)</span> 

![pgbench S=all](figures/plots/postgres/scales/rw_means.svg)

{{% /section %}}

---
{{% section %}}
# Kafka 
> <p style="font-size: 0.8em">latency testing</p>


---

## Methodology

{{% fragment %}}Created a **custom** benchmarking tool{{% /fragment %}}
{{% fragment %}}Measured **end-to-end latencies**{{% /fragment %}}
{{% fragment %}}Measured with different numbers of{{% /fragment %}}
<div style="display: flex; flex-direction: row; justify-content: space-evenly;">
<div class="fragment">Producers</div>

<div class="fragment">Consumers</div>
</div>
{{% fragment %}}Run the same tests in:{{% /fragment %}}
<div style="display: flex; flex-direction: row; justify-content: space-evenly;">
<div class="fragment"><code style="color: #fab387">vcluster</code></div>

<div class="fragment" style="color: #89dceb">conventional Kubernetes cluster</div>
</div>

---

## Results

---
{{< slide background="#FFF">}}

### <span style="color: #000">Means of latencies</span>
![Kafka latency](figures/plots/kafka/latency.svg)



---
{{< slide background="#FFF">}}

### <span style="color: #000">Means of 90th percentile of latencies</span>
![Kafka latency](figures/plots/kafka/p9.svg)


---
{{< slide background="#FFF">}}

### <span style="color: #000">Means of 99th percentile of latencies</span>
![Kafka latency](figures/plots/kafka/p99.svg)



{{% /section %}}

--- 
{{% section %}}
# Future work



{{% fragment %}}Test with more applications{{% /fragment %}}
{{% fragment %}}Tests with a massive multi-`vcluster` environment{{% /fragment %}}
{{% fragment %}}Security implications{{% /fragment %}}
{{% fragment %}}Test with more complex scenarios{{% /fragment %}}
{{% fragment %}}Test with more complex scenarios{{% /fragment %}}


{{% /section %}}

---
# Thank you!
