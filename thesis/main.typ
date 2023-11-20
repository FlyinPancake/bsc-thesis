#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
// #show par: set block(spacing: 0.55em)
#set text(font: "Times New Roman", size: 12pt)
#show raw: set text(font: "CaskaydiaCove NF", size: 9pt)
#set text(lang: "en", region: "GB")
#show heading.where(level:1): set text(size: 24pt) 
#show heading: set block(above: 1.4em, below: 1em)
#set page(
    paper: "a4",
    margin: 3cm
)

#include "pages/project.typ"
#include "pages/titlepage.typ"
#set page(numbering: "1")
#counter(page).update(1)
#outline(depth: 3)
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