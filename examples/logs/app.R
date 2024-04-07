# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#
# MariaDB is required to run this example download at
# https://mariadb.org/download/



library(DBI)
library(odbc)
library(tidyverse)
library(dplyr)
library(dbplyr)
library(pool)
library(shiny)
library(shinyjs)
library(ShinySQLBrowser)

user = 'root'
password = "RayLVM"


# If table don't exist
if(FALSE){
	# Create a detached connection
	detached <- dbPool(
		drv = RMariaDB::MariaDB(),
		password = password,
		user = user
	)
	# Execute the file
	dbExecute(detached, read_file("tableData.sql"))
	# Close the connection
	poolClose(detached)
}


CookLog <- dbPool(
  drv = RMariaDB::MariaDB(),
  password = password,
  user = user,
  dbname = 'CookLog'
)

SaladLog <- dbPool(
  drv = RMariaDB::MariaDB(),
  password = password,
  user = user,
  dbname = 'SaladLog'
)

Work <- dbPool(
  drv = RMariaDB::MariaDB(),
  password = password,
  user = user,
  dbname = 'Work'
)

# Note nothing will show here
cookFilter = function(con, name){
  today = lubridate::today(Sys.timezone())
  dplyr::tbl(con, name)|>
    filter(Date==today)|>
    as_tibble()
}

expiredFilter = function(con, name){
	today = lubridate::today(Sys.timezone())
	dplyr::tbl(con, name)|>
		filter(Expires<=today, Ack==0)|>
		as_tibble()
}

data = yaml::read_yaml("config.yaml")
container = UIContainer(data$tables, data)


# Define UI for application that creates a user interface for SQL tables
ui = bootstrapPage(
    theme = bslib::bs_theme(version = 4),
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
    if(commandArgs()[1]!="RStudio")quit(save = "no")
  })
}

# Run the this integrated applicatopn
shinyApp(ui = ui, server = server)
