
#set heading(numbering: (..n) => {
  if n.pos().len() < 4 {
    numbering("1.1", ..n)
  } 
})
#show heading.where(level:1): it => [
    #pagebreak()
    #text(size: 14pt)[Chapter #counter(heading).display(it.numbering)]\
    #v(0.5em)\
    #it.body
]

#include "chapters/chapter_1_intro.typ" 
#include "chapters/chapter_2_background.typ"
#include "chapters/chapter_3_planning.typ"
#import "@preview/big-todo:0.2.0": todo
#todo[Measurement Execution]
#todo[Measurement Evaluation]
#todo[Conclusion]
// #import "@preview/tablex:0.0.5"