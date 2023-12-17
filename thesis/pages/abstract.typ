#import "@preview/big-todo:0.2.0": todo
#page[
    #set text(lang: "hu") 
    = Kivonat
    
    A szakdolgozat célja a virtuális Kubernetes klaszterekkel 
    kapcsolatos jelenlegi állapot felmérése. A virtuális klaszterek ebben az összefüggésben egyetlen Kubernetes klaszteren belül létrehozott elszigetelt Kubernetes klaszterekre utalnak. Ez a megközelítés előnyösnek bizonyul tesztelési célokra, különböző felhasználók számára elszigetelt környezetek létrehozására és verziókonfliktusok kezelésére. A vcluster egy virtuális Kubernetes klaszter implementáció, amelyet ez a szakdolgozat részletesen vizsgál.

    A szakdolgozat első része egy átfogó irodalomkutatást tartalmaz a Kubernetes ökoszisztémáról, különös figyelemmel a vcluster funkcióira és képességeire. Ezen ismeretek alapul szolgálnak a vcluster-el kapcsolatos elvárások meghatározásához, és biztosítja a szélesebb Kubernetes ökoszisztéma alapos megértését.

    Az irodalomkutatást követő szakasz részletesen ismerteti a virtuális klaszterek teljesítmény és funkcionalitás értékeléséhez végzett tesztek tervezését. Ez magában foglalja a teszteléshez használt eszközökkel való megismerkedést, a tesztesetek ismertetését és a kiválasztásuk mögötti indoklást, valamint a tesztelési környezet részletes leírását.

    A szakdolgozat ezután bemutatja a tesztelési fázis során szerzett tapasztalatokat, kiemelve az összes felmerülő problémát és a kialakított megoldásokat. Fontos megjegyezni, hogy a kezdeti módszertan módosítására is sor került, amelynek célja a releváns és megbízható eredmények elérése.

    Végül a szakdolgozat felvázol vcluster-hez kapcsolódoó jövőbeli kutatási lehetőségeket, és betekintést nyújt azokba a területekbe, amelyek további felfedezést igényelnek. A kutatás eredményeinek részletes megvitatása, valamint a kutatás következményeinek értékelése zárja a szakdolgozatot.

]

#page[
    = Abstract
    
    The primary objective of this thesis is to evaluate the current state of the art in the 
    realm of virtual Kubernetes clusters. Virtual clusters, in this context, refer to the 
    creation of isolated Kubernetes clusters within a single Kubernetes cluster. This 
    approach proves beneficial for testing purposes, establishing isolated environments for 
    various use-ceses, and mitigating version conflicts. In particular, this thesis examines 
    vcluster, a virtual Kubernetes cluster implementation.

    The initial section of the thesis comprises of a comprehensive literature review 
    covering the Kubernetes ecosystem and specifically delving into the features and 
    capabilities of vcluster. This review serves as a foundation for establishing 
    expectations related to vcluster and ensures a thorough understanding of the broader 
    Kubernetes landscape.

    Following the literature review, the subsequent section provides a detailed account of the tests conducted to assess the performance and functionality of virtual clusters. This involves familiarizing ourselves with the testing tools employed, outlining the chosen test cases, and explaining the rationale behind their selection, along with a thorough description of the testing environment.

    The thesis then proceeds to review the findings gathered in the testing phase, highlighting any encountered issues and detailing the corresponding solutions devised. Importantly, adjustments to the initial methodology are presented, uderscoring the necessity for modifications to attain meaningful and reliable results.

    Lastly, the thesis outlines potential avenues for future research on vcluster, offering insights into areas that merit further exploration. A comprehensive discussion of the findings, along with reflections on the implications of the research, concludes the thesis.
]