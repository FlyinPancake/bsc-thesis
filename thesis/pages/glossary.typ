#import "@preview/glossarium:0.2.4": print-glossary
#page[
= Glossary
#print-glossary((
 (
    key: "crd", 
    short: "CRD", 
    long: "Custom Resource Definition", 
    desc: [A CRD is a Kubernetes resource that allows you to define your own custom resources.
    Kubernetes operators use CRDs to extend the functionality of the Kubernetes API.]
  ),
  (
    key: "persistentvolume",
    short: "PV",
    long: "Persistent Volume",
    desc: [A `PersistentVolume` is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.]
  ),
  (
    key: "olm",
    short: "OLM",
    long: "Operator Lifecycle Manager",
    desc: [The Operator Lifecycle Manager facilitates the management of operators in the Kubernetes Cluster.]
  ),
  (
    key: "tps",
    short: "TPS",
    long: "Transactions Per Second",
    desc: [Transactions per second (TPS) is an indication of how many database transactions a system can process per second.]
  ),
  (
    key: "ro", 
    short: "RO",
    long: "Read Only",
    desc: [A test is Read-only (RO) if it does not modify the state of the system under test.]
  ),
  (
    key: "rw",
    short: "R/W",
    long: "Read/Write",
    desc: [A test is Read/Write (R/W) if it modifies the state of the system under test.]
  ),
  (
    key: "sf", 
    short: "SF",
    long: "Scale Factor",
    desc: [The scale factor (SF) is the ratio of the size of a data set to the size of its original source data set.]
  )
))
]
