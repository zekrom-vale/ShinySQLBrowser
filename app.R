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
password="RayLVM"

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

tables = yaml::read_yaml("config.yaml")$tables

cookFilter = function(con, name){
  dplyr::tbl(con, name)|>
    #filter(Date==lubridate::today()-3)|>
    as_tibble()
}

UITableList = purrr::map(tables, function(table){
  UITable(
    get(table$con),
    table$name,
    id = table$id,
    types = retnn(table$types, list()),
    typemap = retnn(table$typemap, list()),
    opt = retnn(table$opt, list()),
    input = purrr::map(table$rows, function(x){
      r = x$input
      if(is.list(r))if(!is.null(r$con))r$con = get(r$con)
      r
    })|>
      purrr::discard(is.null),
    js = table$js,
    tbl = get(retnn(table$tbl, "tbl")),
    keys = table$keys
  )
})

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
      id = "tabset",
      .adv = T,
      .tabs= purrr::map(tables, function(table){
        x=table$tab|>
          purrr::discard(is.null)
        x$id = table$id
        return(x)
      })|>
        unname()
    )
)


# Define server logic to render the tables and allow interactivity
server = function(input, output, session) {
  observeTab(
    session, input, "tabset",
    .commitout=FALSE,
    .tabs=UITableList
  )
  
  onSessionEnded(function(){
    message("Closing pools")
    poolClose(Work)
    poolClose(CookLog)
    poolClose(SaladLog)
    # quit(save = "no")
  })
}

# Run the this integrated applicatopn
shinyApp(ui = ui, server = server)
