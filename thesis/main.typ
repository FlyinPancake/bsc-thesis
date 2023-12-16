#import "@preview/big-todo:0.2.0": *
#import "@preview/glossarium:0.2.4": make-glossary, print-glossary, gls, glspl
#import "@preview/chic-hdr:0.3.0": *

#show: make-glossary
#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
// #show par: set block(spacing: 0.55em)
#set text(font: "Libre Baskerville", size: 10pt)
#show raw: set text(font: "CaskaydiaCove NFP", size: 1.2em)
#show super: set text(size: 1.5em)
#set text(lang: "en", region: "GB")
#show heading.where(level: 1): set text(size: 2em)
#show heading: set block(above: 1.4em, below: 1em)
#set page(paper: "a4", margin: (y: 2.5cm, inside: 3.5cm, outside: 2.5cm))

#include "pages/project.typ"
#include "pages/titlepage.typ"
#set page(numbering: "I")
#counter(page).update(1)
#outline(depth: 2)
#set page(numbering: none)
#include "pages/declaration.typ"
#include "pages/abstract.typ"
#set page(numbering: "1")
#counter(page).update(1)
#include "pages/chapters.typ"



#set page(numbering: "I")

#page[
  #counter(page).update(1)
  #bibliography("/bibliography.yaml", style: "ieee")
]

= List of Figures
#outline(title: none, target: figure.where(kind: image))
#include "pages/glossary.typ"