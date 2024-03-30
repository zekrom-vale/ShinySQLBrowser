#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(DBI)
library(odbc)
library(tidyverse)
library(dbplyr)
library(pool)
library(shiny)
library(shinyjs)

source("table.R", local = TRUE, keep.source = TRUE)

user= 'root'
password="<removed>"

CookLog <- dbPool(
  drv = RMariaDB::MariaDB(),
  password=password,
  user=user,
  dbname ='CookLog'
)

SaladLog <- dbPool(
  drv = RMariaDB::MariaDB(),
  password=password,
  user=user,
  dbname ='SaladLog'
)

Work <- dbPool(
  drv = RMariaDB::MariaDB(),
  password=password,
  user=user,
  dbname ='Work'
)

cook=UITable(
  CookLog,
  "cook",
  input=list(
    ID='<input type="number" disabled>',
    ItemID=list(table="items", key="ID", val="Item"),
    Person=list(con=Work, table="people", key="ID", val="Name")
  ),
  tbl=function(con, name){
    tbl(con, name)|>
      #filter(Date==lubridate::today()-3)|>
      as_tibble()
  },
  keys="ID"
)

cookitems=UITable(
  CookLog,
  "items",
  id="CookItems",
  input=list(
    ID='<input type="number" disabled>',
    Method=list(table="methods", key="ID", value="Method")
  ),
  keys="ID"
)

people=UITable(
  Work,
  "people",
  id="People",
  input=list(
    ID='<input type="number" disabled>'
  ),
  keys="ID"
)

saladitems=UITable(
  SaladLog,
  "items",
  input=list(
    ID='<input type="number" disabled>'
  ),
  tbl=function(con, name){
    tbl(con, name)
  },
  keys="ID"
)

salad=UITable(
  SaladLog,
  "salad",
  id="SaladItems",
  input=list(
    ID='<input type="number" disabled>',
    SaladID=list(table="items", key="ID", val="Salad"),
    Person=list(con=Work, table="people", key="ID", val="Name")
  ),
  tbl=function(con, name){
    tbl(con, name)
  },
  keys="ID"
)


read_file("format.scss")|>
  sass::sass()|>
  write_file("format.css")

# Define UI for application that creates a user interface for SQL tables
ui = bootstrapPage(
    theme = bslib::bs_theme(version = 4),
    includeCSS("format.css"),
    includeScript("tbl.js"),
    includeScript("connection.js"),
    includeCSS("https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.css"),
    includeScript("https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.js"),
    useShinyjs(),  # Include shinyjs
    
    mainTables(
      CookLog=cook,
      CookItems=cookitems,
      SaladLog=salad,
      SaladItems=saladitems,
      People=people,
      id="tabset"
    )
)

# Define server logic to render the tables and allow interactivity
server = function(input, output, session) {
  
  observeTab(
    session,input, "tabset",
    CookLog=cook,
    CookItems=cookitems,
    People=people,
    SaladLog=salad,
    SaladItems=saladitems,
    .commitout=FALSE
  )
  
  
  
  onSessionEnded(function(){
    message("Closing pools")
    poolClose(Work)
    poolClose(CookLog)
    poolClose(SaladLog)
    quit(save = "no")
  })
}

# Run the this integrated applicatopn
shinyApp(ui = ui, server = server)
