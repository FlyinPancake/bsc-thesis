#import "@preview/big-todo:0.2.0": *
#import "@preview/glossarium:0.2.4": make-glossary, print-glossary, gls, glspl 
#show: make-glossary
#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
// #show par: set block(spacing: 0.55em)
#set text(font: "Merriweather", size: 12pt)
#show raw: set text(font: "CaskaydiaCove NF", size: 9pt)
#set text(lang: "en", region: "GB")
#show heading.where(level:1): set text(size: 24pt) 
#show heading: set block(above: 1.4em, below: 1em)
#set page(
    paper: "a4",
    margin: (
      y: 2.5cm,
      inside: 3.5cm,
      outside: 2.5cm,
    ),
    
)

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
#include "pages/chapters.typ"
#set page(numbering: "I")
#pagebreak()
#counter(page).update(1)
#include "pages/bibliography.typ"
#pagebreak()
#outline(
  title: [List of Figures],
  target: figure.where(kind: image),
)
#include "pages/glossary.typ"