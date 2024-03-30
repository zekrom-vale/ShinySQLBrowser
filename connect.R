library(DBI)
library(odbc)
library(tidyverse)
library(dbplyr)
library(pool)
library(DT)
library(shiny)

CookLog <- dbConnect(
  RMariaDB::MariaDB(),
  password="RayLVM",
  user='root',
  dbname ='CookLog',
  timeout = 10
)

dbWriteTable(con, "waste", all, overwrite=TRUE)

tbl(con, "waste")

dataTableAjax(
  tbl(CookLog, "items")%>%
    as_tibble()
)
