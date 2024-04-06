
# people - Work
people=read_csv("data/CookLog.people.csv")%>%
  filter(Person!="Shawn")%>%
  arrange(Person)%>%
  mutate(
    ID=row_number()+1,
    Name=Person,
    Person=NULL,
    Active = 1,
    Comment = "Imported"
  )

Work <- dbPool(
  drv = RMariaDB::MariaDB(),
  password="RayLVM",
  user='root',
  dbname ='Work'
)

dbAppendTable(Work, "people", work)



# items - CookLog

clitems = read_csv("data/CookLog.items.csv")%>%
  filter(Item!="8 Pice Fried Chicken")%>%
  mutate(
    Method = case_match(Method,
      "Baked" ~ 1,
      "Fried" ~ 2
    ),
    MinTemp = as.integer(MinTemp),
    Minutes = as.integer(Minutes)
  )%>%arrange(Item)

CookLog <- dbPool(
  drv = RMariaDB::MariaDB(),
  password="RayLVM",
  user='root',
  dbname ='CookLog'
)

dbAppendTable(CookLog, "items", clitems)

# cook - CookLog


people=tbl(Work, "people")%>%
  select(ID, Name)%>%
  as_tibble()%>%
  mutate(
    Person = ID,
    ID = NULL
  )

items=tbl(CookLog, "items")%>%
  select(ID, Item)%>%
  as_tibble()%>%
  mutate(
    ItemID=ID,
    ID=NULL
  )


cook=read_csv("data/CookLog.cook.csv")%>%
  inner_join(., items, by = c(Item="Item"))%>%
  inner_join(., people, by = c(User="Name"))%>%
  mutate(
    User=NULL,
    Item=NULL,
    Date=lubridate::mdy(Date)
  )

dbAppendTable(CookLog, "cook", cook)

poolClose(CookLog)


items=read_csv("data/SaladLog.items.csv")%>%
  arrange(Salad)%>%
  mutate(
    Life=as.integer(Life)
  )

SaladLog <- dbPool(
  drv = RMariaDB::MariaDB(),
  password="RayLVM",
  user='root',
  dbname ='SaladLog'
)

dbAppendTable(SaladLog, "items", items)

sitems=tbl(SaladLog, "items")%>%
  select(ID, Salad)%>%
  as_tibble()
  

salad=read_csv("data/SaladLog.salad.csv")%>%
  mutate(
    Date=lubridate::mdy(Date),
    Expires=lubridate::mdy(Expires),
    Ack=as.integer(Ack)
  )%>%
  inner_join(., sitems, by=c(Salad="Salad"))%>%
  mutate(
    Salad=ID.y,
    ID.y=NULL,
    ID=as.integer(ID.x),
    ID.x=NULL,
    MeatAge=as.integer(MeatAge)
  )

dbAppendTable(SaladLog, "salad", salad)

poolClose(SaladLog)
poolClose(Work)
