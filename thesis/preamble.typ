#let student = text[*Domonkos Pálvölgyi*]
#let consultant = text[*Dr. Balázs Sonkoly*, assosiate professor]
#let second_consultant = text[*Balázs Fodor*, PhD student]
#let external_consultant = text[*Zsolt Krämer*, Ericsson Hungary]


#let today = datetime.today()
#let show_today = today.display("[day] [month repr:long] [year]")
#let months_hu = ("január", "február", "március", "április", "május", "június", "július", "augusztus", "szeptember", "október", "november", "december")
#let show_today_hu = [#today.year(). #months_hu.at(today.month() - 1) #today.day().]