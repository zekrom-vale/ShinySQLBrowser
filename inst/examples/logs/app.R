# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#
# MariaDB is required to run this example download at
# https://mariadb.org/download/

# RMariaDB: The RMariaDB package provides a database interface for MariaDB and
# MySQL. It is required to be installed for this code to work, but it is not
# listed in the import list.

# DBI: The DBI package provides a generic interface to database management
# systems (DBMS). It allows you to write code that can be ported across
# different types of databases.
library(DBI)

# odbc: The odbc package is used to connect to various databases (DBMS) using
# the Open Database Connectivity (ODBC) standard. It allows you to interact
# with these databases directly from R.
library(odbc)

# tidyverse: The tidyverse is a collection of R packages designed for data
# science. It includes packages for data manipulation (dplyr), data
# visualization (ggplot2), and data import (readr), among others.
library(tidyverse)

# dplyr: Part of the tidyverse, dplyr is a grammar of data manipulation,
# providing a consistent set of verbs that help you solve the most common
# data manipulation challenges.
library(dplyr)

# dbplyr: Also part of the tidyverse, dbplyr is a database backed for dplyr.
# It allows you to use dplyr to manipulate data in a database as if it were
# in a local data frame.
library(dbplyr)

# pool: The pool package makes it easier to manage database connections. It
# provides a mechanism to keep a number of active connections open and
# automatically opens or closes connections as needed.
library(pool)

# shiny: Shiny is an R package that makes it easy to build interactive web
# apps straight from R, allowing you to share your analyses as interactive
# dashboards or applications.
library(shiny)

# shinyjs: The shinyjs package lets you customize your Shiny applications
# with JavaScript. It provides functions to interact with the JavaScript
# within your Shiny application.
library(shinyjs)

# ShinySQLBrowser: The ShinySQLBrowser package provides a Shiny-based
# interface to browse SQL databases. It allows you to interactively explore
# your SQL databases from a Shiny application.
library(ShinySQLBrowser)


user = 'root'
password = "RayLVM"


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
	# pool::dbExecute("UPDATE `salad` SET `Ack` = 1 WHERE `Ack` = 0 AND `SaladID` = (NEW.`SaladID`) AND `ID` <> (NEW.`ID`);")
	today = lubridate::today(Sys.timezone())
	dplyr::tbl(con, name)|>
		#dplyr::tbl(SaladLog, "salad")|>
		as_tibble()|>
		group_by(SaladID)|>
		arrange(desc(Expires), desc(Date), desc(Time))|>
		slice(1)|>
		ungroup()|>
		dplyr::filter(Expires<=today, Ack==0)
}

# data = yaml::read_yaml(system.file("examples", "logs", "config.yaml", package = "ShinySQLBrowser"))
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
