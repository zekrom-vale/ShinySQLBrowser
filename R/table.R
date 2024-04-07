

#' @name shinyTab
#'
#' @param session The Shiny session
#' @param input The shiny input
#' @param tab The name of the open tab
NULL

########################
# START
# CLASS : UITable
########################


#' UITable
#'
#' @slot con A \code{\link{pool}} connection
#' @slot conname The name of the connection, defaults to the name of the pool argument
#' @slot id The HTML table id
#' @slot name The tale name to connect to
#' @slot types A list of the types of the columns, must name the columns
#' @slot opt A list of styles
#'
#' ```R
#'    td    = list(class="", collapse=" "),
#'    tr    = list(class="", collapse=" "),
#'    th    = list(class="", collapse=" "),
#'    table = list(class="table"),
#'    tbody = list(class="table-striped"),
#'    thead = list(class=""),
#'    use_this_tbl = c("force", "off", "on")
#' ```
#' @slot typemap A list of the HTML input tags to generate per type
#' If a list is passed instead of character it is used as a reference
#' list(con=Work, table="people", key="ID", val="Name")
#' * con: Optional The connection to use, if not provided use the same connection as the table
#' * table: The table to access
#' * key: The primary key to use as an identifier of the table (value in option)
#' * value: The text to display or pick as the user
#' * Use key==value if they are the same
#'
#' @slot typemap A list of the HTML input tags to generate per type
#' @slot input A list of HTML input tags to override \code{typemap}
#' @slot js The JS value to access currently the value is \code{UITable.{name}}
#' @slot tbl The function to access the tbl, use this to modify the results or filter it
#' @slot keys The primary keys in a list separated by \code{|,;:}
#' @slot autoinc Does the first primary key use \code{AUTO_INCREMENT}?
#' @export
#'
methods::setClass(
  "UITable",
  slots = c(
    con = "Pool",
    conname = "character",
    id = "character",
    name = "character",
    types = "list",
    opt = "list",
    input = "list",
    js = "character",
    tbl = "function",
    keys = "character",
    autoinc = "logical",
    css = "ANY"
  ),
  prototype = list(
    con = NULL,
    conname = NA_character_,
    id = NA_character_,
    name = NA_character_,
    types = list(),
    opt = list(),
    input = list(),
    js = NA_character_,
    tbl = dplyr::tbl,
    keys = "",
    autoinc = TRUE,
    css = ""
  )
);

#' Pull class of columns
#'
#' @description
#' Used in \code{\link{mutate}} to obtain the class of the column.
#' Vectorised form of \code{class(pull(.data, var))}
#'
#' @param .data The table to pull from
#' @param var The column to pull
pullclass = Vectorize(
  function(.data, var)paste(class(dplyr::pull(.data, var)), collapse = " "),
  vectorize.args = "var",
  SIMPLIFY = F
)

#' Create a UITable object for Database display and modification
#'
#' @param con A \code{\link{pool}} connection
#' @param name The tale name to connect to
#' @param types A list of the types of the columns, must name the columns
#' @param opt A list of styles
#' @param input A list of HTML input tags to override \code{typemap}
#'
#' @returns A new \code{\link{UITable}} object
UITable = function(
    con,
    name,
    id = NULL,
    types = list(),
    opt = list(),
    input = list(),
    js = NULL,
    tbl = dplyr::tbl,
    keys = "",
    autoinc = TRUE,
    css = ""
  ){

  if(is.null(id))
    id = deparse(substitute(con))

  if(is.null(name) || is.na(name))
    stop("name is null or NA")
  if(methods::is(con)!= "Pool")
    warning("con is not a Pool, use `pool::dbPool()` not `DBI::dbConnect()` for stability")

  cfg = getConfig()
  opt = utils::modifyList(
    cfg$opt,
    opt
  )
  tib = tbl(con, name)

  types = utils::modifyList(
    pullclass(tib, colnames(tib)),
    types
  )

  input = utils::modifyList(
    as.list(vd(getConfig()$opt$typemap, types)),
    input
  )

  this = methods::new("UITable",
    con = con,
    conname = deparse(substitute(con)),
    name = name,
    id = id,
    types = types,
    opt = opt,
    input = input,
    js = `if`(is.null(js),glue::glue("UITable.{id}"),js),
    tbl = tbl,
    keys = keys,
    autoinc = autoinc,
    css = css
  )

  for(i in 1:2){
    this@opt = recursivefor(
      this@opt,
      function(x, i){
      	if(length(x)>1) return(x)
        if(typeof(x)!="character") return(x)
        return(glue::glue(x, .open = "{{", .close = "}}"))
      }
    )
  }
  this
};


#' Convert a tibble or tbl to a HTML table
#'
#' @param this A \code{\link{UITable}} object
#' @return An HTML table
#'
#' Columns have the class of {name}-{col}
#'
#' <table class="table" id="{name}">
#'  <thead>
#'    <tr>
#'      <th class="{name}-{col}" data-type="{type}" id="{name}-{col}" data-col="{col}">
#'      </th>``
#'      ...
#'    </tr>
#'  </thead>
#'  <tbody>
#'    <tr>
#'      <td class="{name}-{col}" data-col="{name}-{col}" data-val="{value}">
#'      </td>
#'      ...
#'    </tr>
#'  </tbody>
#' </table>

toTable = function(this){

  tib = this@tbl(this@con, this@name)|>
    dplyr::as_tibble()
  if(getConfig()$opt$message){
    shinyjs::logjs(glue::glue("{this@conname}.{this@name}"))
    shinyjs::logjs(tib)
  }
  col_index = function(col){
    purrr::detect_index(colnames(tib), ~.==col)
  }

  # Find the reference type
  # ItemID = list(table = "items", key = "ID", val = "Item", con = Pool, tbl = function(c,n)tbl(c,n)|>select(1:2))
  input = purrr::map(
    this@input,
    function(input){
      if(!is.list(input))return(c(input))
      if(!(
        is.null(input$con)||"Pool" %in% class(input$con)
      ))stop("Connection is not a Pool")
      con = retnn(input$con,this@con)
      test = this@opt$use_this_tbl
      if(test==TRUE)test = "on"
      else if(test==FALSE)test = "off"
      test = tolower(test)
      tb = switch(test,
        "force" = this@tbl,
        "on" = `if`(con == this@con, retnn(input@tbl, this@tbl, retnn(input$tbl, dplyr::tbl))),
        "off" = retnn(input$tbl, dplyr::tbl)
      )(con, input$table)|>
        dplyr::select(retnn(input$key, 1), retnn(input$val, 2))|>
        dplyr::as_tibble()|>
        dplyr::rename(key = 1, val = 2)

      sel = tb|>
        dplyr::mutate(
          x = glue::glue('<option value="{key}">{val}</option>') # TODO: Fix if <>'" are in data
        )|>
        dplyr::summarise(paste0(x, collapse = ""))|>
        dplyr::pull()
        # Need to generate a function to select the correct item from the key

      li = tb|>
        dplyr::mutate(
          x = glue::glue("'{key}':'{val}'") # TODO: Fix if <>'" are in data
        )|>
        dplyr::summarise(paste0(x, collapse = ","))|>
        dplyr::pull()

      c(glue::glue('<select>{sel}</select>'), li)
    }
  )

  # Body
  body = tib|>
    dplyr::mutate(dplyr::across(
      dplyr::everything(),
      function(x){
        if(is.null(x))return()
        col = dplyr::cur_column()
        glue::glue(this@opt$td$glue, .na = "")
      }
    ))|>
    tidyr::unite(
      row,
      dplyr::everything(),
      sep = this@opt$td$collapse
    )|>
  	dplyr::mutate(
      row = glue::glue(this@opt$tr$glue)
    )|>
  	dplyr::summarise(
      paste(row, collapse = this@opt$tr$collapse)
    )|>
  	dplyr::pull()

  # Header
  head = dplyr::tibble(
    x = colnames(tib)
  )|>
  	dplyr::mutate(
      x = glue::glue(
        this@opt$th$glue
      )
    )|>
  	dplyr::summarise(
      paste(x, collapse = this@opt$th$collapse)
    )|>
  	dplyr::pull()

  template = dplyr::tibble(
      col = colnames(tib)
    )|>
  	dplyr::mutate(
      col = glue::glue(this@opt$td$templateglue)
    )|>
  	dplyr::summarise(paste(col, collapse = this@opt$td$collapse))|>
  	dplyr::pull()
  template = glue::glue(this@opt$tr$templateglue)


  # Glue together
  glue::glue(
  	'<style>{this@css}</style>',
    this@opt$table$glue,
      '<template>',
        template,
      '</template>',
      this@opt$thead$glue,
        '<tr>{head}</tr>',
      '</thead>',
      this@opt$tbody$glue,
        '{body}',
      '</tbody>',
    '</table>'
  )
}


#' Creates a \code{\link{tabPanel}} with a title and the body of \code{\link{tableOutput}} with an id of id
#' @param title The title of the tab to use
#' @param id The id of the \code{\link{tableOutput}}
#' @param value The Shiny event value for tabset
#' @param icon An icon to use
#' @param ... UI elements to include within the tab
tabTable = function(title, id, ..., value = title, icon = NULL){
  shiny::tabPanel(title, shiny::fluidRow(shiny::tableOutput(id)), ..., value , icon)
}


#' Creates a list of \code{\link{tabPanels}}
#' @param ...,.tabs The list of tabs to add
#' @param id The id of the \code{\link{tabsetPanel}}
#' @param .adv Use the long form (\code{FALSE}) or the short form (\code{TRUE}) for tabs
#'
#' Short format:
#' A list of key value pairs
#' * key:     The title and identifier for the tabPanel
#' * value:   A UITable
#'
#' Long form, more options
#' A list of title, id, and arguments to pass to tabPanel
#' * title:  The title and identifier for the tabPanel
#' * id:     The id to use for the tableOutput
#' * value:  Optional The value that should be sent when tabsetPanel reports that this tab is selected.
#' * icon:   Optional icon to appear on the tab.  This attribute is only valid when using a tabPanel within a navbarPage().
#'
#' ```r
#' library(ShinySQLBrowser)
#' mainTables(
#'   list(CookLog = cook, CookItems = cookitems)
#' , id = "tabset"
#' )
#'
#' mainTables(list(
#'   list(title = "CookLog", id = "CookLog"),
#'   list(title = "CookItems", id = "CookItems")
#' ), id = "tabset", .adv = T)
#' ```
mainTables = function(..., id, .adv = FALSE, .tabs = NULL){

  tabTables = function(tabs, id, .adv = FALSE){
    if(!.adv)tabs = purrr::imap(tabs, function(tab, i){list(title = i, id = tab@id)})|>
        unname()
    tabs = tabs|>
      purrr::map(function(x){
      	shiny::tabPanel(x$title, shiny::fluidRow(shiny::tableOutput(x$id)), value = retnn(x$value, x$title), icon = x$icon)
      })
    tabs$id = id
    tabs
  }
  if(is.null(.tabs))tabs = list(...)
  else tabs = .tabs
  shiny::mainPanel(
    do.call(
      shiny::tabsetPanel,
      tabTables(tabs, id = id, .adv = .adv)
    )
  )
}

#' Run the JS start the HTML
#'
#' @description
#' Run the scripts of the tables
#' Client side, and Set HTML table
#'
#' @inheritParams shinyTab
#' @param set A list of \code{\link{tabPanels}} values and \code{\link{UITable}} objects as key value pairs

tabJs = function(input, tab, set, .onClickOff = "commit"){
  # Get the current open tabPanels
  if(getConfig()$opt$message){
  	message(as.character(input[[tab]]))
  }
  obj = set[[as.character(input[[tab]])]]
  if(is.null(obj))return()
  shinyjs::html(obj@id, toTable(obj)) # TODO
  shinyjs::runjs(glue::glue('main($("#{obj@id}"), "{obj@id}", "{stringr::str_to_lower(.onClickOff)}")'))
}
#' Run the scripts of the when it is visable
#' Server side, Client side, and Set HTML table
#' @inheritParams shinyTab
#' @param ... A list of tabPanels values and UITable objects as key value pairs


#' Observe the changes of the tabs
#'
#' @inheritParams shinyTab
#' @param ...,.tabs A list of tab values as keys and \code{\link{UITable}} objects as values
observeTab = function(session, input, tab, ..., .onClickOff = "commit", .tabs = NULL){
  if(is.null(.tabs))set = list(...)
  else set = .tabs

  # Start message handler
  purrr::map(set, function(obj){
    tableObserver(session, input, obj@id, obj)
  })

  # Start the tab listener
  shiny::observeEvent(
    input[[tab]], {
      tabJs(input, tab, set, .onClickOff)
    }
  )
}

########################
# END
# CLASS : UITable
########################
