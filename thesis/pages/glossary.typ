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
    desc: [A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.]
  )
))
]
