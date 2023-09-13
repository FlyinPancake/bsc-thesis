#let student = text[Pálvölgyi Domonkos]
#let consultant = text[Dr. Konzulens Changeme]


#let today = datetime.today()
#let show_today = today.display("[year]-[month repr:long]-[day].")
#let months_hu = ("január", "február", "március", "április", "május", "június", "július", "augusztus", "szeptember", "október", "november", "december")
#let show_today_hu = [#today.year(). #months_hu.at(today.month() - 1) #today.day().]