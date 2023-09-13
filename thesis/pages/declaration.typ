#import "../preamble.typ": student, show_today_hu

#page[
    #set text(lang: "hu")
    #set par(justify: true)
    #align(center, text(size: 14pt, upper([
        *Hallgatói nyilatkozat*
    ])))

    Alulírott *#student*, szigorló hallgató kijelentem, hogy ezt a szakdolgozatot meg nem engedett segítség nélkül, saját magam készítettem, csak a megadott forrásokat (szakirodalom, eszközök stb.) használtam fel. Minden olyan részt, melyet szó szerint, vagy azonos értelemben, de átfogalmazva más forrásból átvettem, egyértelműen, a forrás megadásával megjelöltem.

    Hozzájárulok, hogy a jelen munkám alapadatait (szerző(k), cím, angol és magyar nyelvű tartalmi kivonat, készítés éve, konzulens(ek) neve) a BME VIK nyilvánosan hozzáférhető elektronikus formában, a munka teljes szövegét pedig az egyetem belsõ hálózatán keresztül (vagy autentikált felhasználók számára) közzétegye. Kijelentem, hogy a benyújtott munka és annak elektronikus verziója megegyezik. Dékáni engedéllyel titkosított diplomatervek esetén a dolgozat szövege csak 3 év eltelte után válik hozzáférhetõvé.

    #v(1cm)
    Budapest, #show_today_hu

    #v(2cm)
    
    #align(end)[
        #box(
            width: 7cm,
        )[
            #align(center)[
            #line(length: 6cm, stroke: black + 0.25pt)
            _#(student)_\
            hallgató
            ]
            
        ]   
    ]
]