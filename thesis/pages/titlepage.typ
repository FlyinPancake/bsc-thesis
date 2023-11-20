#import "../preamble.typ": student_name_en as student, consultant, show_today, second_consultant, external_consultant
#page[
    #align(center)[
        #v(3mm)
        #image(
            "../figures/BMElogo.png",
            width: 60mm
        )
        *Budapest University of Technology and Economics*\
        Faculty of Electrical Engineering and Informatics\
        Dept. of Telecommunications and Media Informatics
        #v(54mm)
        #text(weight: "bold", size: 20pt)[
            Performance and useability analysis of virtual clusters in Kubernetes
        ]
        #v(5mm)
        #text(size: 14pt)[
            #smallcaps[BSc Thesis]
        ]
        #v(40mm)
        #grid(
            columns: (7cm, 7cm),
            box[
                _Author_

                *#student*
            ],
            box[
                _Supervisors_
                
                #consultant\
                #second_consultant\
                #external_consultant
            ]
        )
        #align(bottom)[Budapest, #show_today]
    ]
]