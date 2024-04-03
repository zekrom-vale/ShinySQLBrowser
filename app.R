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
library(ShinySQLBrowser)

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

cookFilter = function(con, name){
  dplyr::tbl(con, name)|>
    #filter(Date==lubridate::today()-3)|>
    as_tibble()
}
data = yaml::read_yaml("config.yaml")$tables
container = UIContainer(data)


# Define UI for application that creates a user interface for SQL tables
ui = bootstrapPage(
    theme = bslib::bs_theme(version = 4),
    htmltools::includeCSS("format.css"),
    includeUITable(container)
)


# Define server logic to render the tables and allow interactivity
server = function(input, output, session) {
  observeSwitch(session, input, container)

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
