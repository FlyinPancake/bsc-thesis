#import "@preview/big-todo:0.2.0": *
#import "@preview/glossarium:0.2.4": make-glossary, print-glossary, gls, glspl
#import "@preview/chic-hdr:0.3.0": *

#show: make-glossary
#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
// #show par: set block(spacing: 0.55em)
#set text(font: "Libre Baskerville", size: 10pt)
#show raw: set text(font: "CaskaydiaCove NF", size: 1.3em)
#set text(lang: "en", region: "GB")
#show heading.where(level: 1): set text(size: 2em)
#show heading: set block(above: 1.4em, below: 1em)
#set page(paper: "a4", margin: (y: 2.5cm, inside: 3.5cm, outside: 2.5cm))

#page[
  #todo_outline
]
#include "pages/project.typ"
#include "pages/titlepage.typ"
#set page(numbering: "1")
#counter(page).update(1)
#outline(depth: 2)
#set page(numbering: none)
#include "pages/declaration.typ"
#set page(numbering: "1")
#include "pages/abstract.typ"
// #show: chic.with(
//   chic-header(
//     side-width: (1fr, 0fr, 2fr),
//     left-side: text(chic-heading-name(), size: 0.9em),
//     right-side: text("Performance and usability analysis of virtual clusters in Kubernetes", size: 0.8em),
//   ),
//   chic-separator(1pt),
//   chic-height(1.5cm)
// )
#include "pages/chapters.typ"
#set page(numbering: "I")
#pagebreak()
#counter(page).update(1)
#include "pages/bibliography.typ"
#pagebreak()
= List of Figures
#outline(title: none, target: figure.where(kind: image))
#include "pages/glossary.typ"