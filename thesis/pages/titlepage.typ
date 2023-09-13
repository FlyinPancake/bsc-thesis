#import "../preamble.typ": student, consultant, show_today
#page[
    #align(center)[
        #v(3mm)
        #image(
            "../figures/BMElogo.png",
            width: 60mm
        )
        *Budapesti Mûszaki és Gazdaságtudományi Egyetem*\
        Villamosmérnöki és Informatikai Kar\
        Távközlési és Médiainformatikai Tanszék
        #v(54mm)
        #text(weight: "bold", size: 20pt)[
            vcluster: virtual clusters for Kubernetes
        ]
        #v(5mm)
        #text(size: 14pt)[
            #smallcaps[Szakdolgozat]
        ]
        #v(40mm)
        #grid(
            columns: (7cm, 7cm),
            box[
                _Készítette_

                *#student*
            ],
            box[
                _Konzulens_
                
                *#consultant*
            ]
        )
        #align(bottom)[
            Budapest, #show_today
        ]
    ]
]