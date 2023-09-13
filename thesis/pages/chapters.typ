#set heading(numbering: "1.1.1.1")
#show heading.where(level:1): it => [
    #pagebreak()
    #text(size: 14pt)[Chapter #counter(heading).display(it.numbering)]\
    #v(0.5em)\
    #it.body
]

#include "chapters/chapter_1.typ" 
#include "chapters/chapter_2.typ"
// #import "@preview/tablex:0.0.5"