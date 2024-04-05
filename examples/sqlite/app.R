# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(DBI)
library(pool)
library(tidyverse)
library(ShinySQLBrowser)

mydb = dbPool(drv = RSQLite::SQLite(), dbname =":memory:")
mtcars|>
	as_tibble()|>
	mutate(car = rownames(mtcars), id = row_number(car))|>
	dbWriteTable(mydb, "mtcars", value = _)

data = yaml::read_yaml("config.yaml")
container = UIContainer(data$tables, data)

# Define UI for application that creates a user interface for SQL tables
ui = bootstrapPage(
	theme = bslib::bs_theme(version = 4),
	includeUITable(container)
)


# Define server logic to render the tables and allow interactivity
server = function(input, output, session) {
	observeSwitch(session, input, container) # , .onClickOff = "discard"

	onSessionEnded(function(){
		message("Closing pools")
		poolClose(mydb)
	})
}

# Run the this integrated applicatopn
shinyApp(ui = ui, server = server)
