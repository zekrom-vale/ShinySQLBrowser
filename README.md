# ShinySQLBrowser
A Shiny application that allows easy SQL data entry for anyone once set up with the `configuration.yaml` file or any other object from R.

## Instalation

```r
devtools::install_github("https://github.com/zekrom-vale/ShinySQLBrowser")
```

## Setup

There are 3 steps in setting up the application with Shiny. `UIContainer`, `includeUITable`, and `observeSwitch` provide ease of access wrapers.
If needed you can sill call `UITable` directly, but for that you will need to read the R/man files.

---
### 1.) `UIContainer(tables, opt = NULL)`
This function takes a list of tables and optionaly a configuration object for `format_default`s and advanced configuration such as HTML building.
It returns a container object containing the generated `UITables`.

### `tables`
```yaml
<TableName>:
  tab:
    title: <TableName>
    [value: <Identifiyer, advnaced config>]
    [icon: <Icon of the tab>]
  con: <SQL connection>
  name: <SQL table name>
  id: <HTML ID of table>
  [types:
    <HTML input/select types>[...]]
  opt: <option object>
  [rows:
    <row name>:
      [width: <css width not implemented>]
      input: <html input/select override>
    <row name>:
      [width: <css width>]
      input:
        [con: <SQL connection>]
        table: <SQL Table>
        key: <SQL column to use as a key>
        val: <SQL column to use as a value>
      [...]]
    [js: <JS lookup, abvanced config>]
    [tbl: <function to modify the table>]
    keys: <Primary keys of the table>
  [...]
```

```yaml
CookLog:
    tab:
        title: NotCookLog # The title for the tabPanel
        value: null # The identifier for the tabPanel, advanced connfig
        icon: null # The icon for the tabPanel
    con: CookLog # Passed through get()
    name: cook
    id: Cook
    types: null
    opt: null
    rows:
        ID:
            width: 80px
            input: <input type="number" disabled>
        Date:
            width: 120px
        Time:
            width: 120px
        ItemID:
            width: 240px
            input: 
                table: items
                key: ID
                val: Item
            format: x=>($("#Cook-ItemID").data("vals").match(new RegExp(`'${x}':'(.+?)'`))||[0,"NULL"])[1]
        Temp:
            width: 100px
        Person:
            width: 140px
            input:
                con: Work # Passed through get()
                table: People
                key: ID
                val: Name
            format: x=>($("#Cook-Person").data("vals").match(new RegExp(`'${x}':'(.+?)'`))||[0,"NULL"])[1]
        Comment:
            width: 300px
    js: null
    tbl: cookFilter # Passed through get() local function
    keys: ID
```

### `opt`
```yaml
[format_default:
    <type>: <JS function>
    [...]]
```

```yaml
format_default:
    Date: x=>new Date(`${x}T18:00:00`).toLocaleDateString()
    hms difftime: x=>new Date(`0000-01-01T${x}`).toLocaleTimeString()
```



---
### 2.) includeUITable(container)

Generates table containers HTML and dependencies.
Note that the table HTML will be generated and desposed on the fly.
Include this in the `ui` list of Shiny.

```r
container = UIContainer(tables, opt)
ui = bootstrapPage(
    theme = bslib::bs_theme(version = 4),
    includeUITable(container)
)
shinyApp(ui = ui)
```

---
### 3.) observeSwitch(session, input, container)


```r
container = UIContainer(tables, opt)
server = function(input, output, session) {
  observeSwitch(session, input, container)
  onSessionEnded(function(){
    # Recomeended to close your pools on close
    poolClose(pool)
  })
}
shinyApp(server = server)
```

## Example
```r
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

Work <- dbPool(
  drv = RMariaDB::MariaDB(),
  password=password,
  user=user,
  dbname ='Work'
)

data = yaml::read_yaml("config.yaml")
container = UIContainer(data$tables, data$opt)


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

# Run the integrated application
shinyApp(ui = ui, server = server)
```
