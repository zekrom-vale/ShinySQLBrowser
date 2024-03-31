setClass(
  "UIContainer",
  slots = c(
    data = "list",
    tables = "list"
  ),
  prototype = list(
    data = list(),
    tables = list()
  )
);


UIContainer = function(data){
  new("UIContainer", data=data, tables=grabUITables(data))
};


grabUITables = function(data){
  purrr::map(data, function(table){
    input = purrr::map(table$rows, function(x){
      r = x$input
      if(is.list(r))if(!is.null(r$con))r$con = get(r$con)
      r
    })|>
      purrr::discard(is.null)
    UITable(
      get(table$con),
      table$name,
      id = table$id,
      types = retnn(table$types, list()),
      typemap = retnn(table$typemap, list()),
      opt = retnn(table$opt, list()),
      input = input,
      js = table$js,
      tbl = get(retnn(table$tbl, "tbl")),
      keys = table$keys
    )
  })
}

grabMainTables = function(data){
  mainTables(
    id = "tabset",
    .adv = T,
    .tabs= purrr::map(data, function(table){
      x=table$tab|>
        purrr::discard(is.null)
      x$id = table$id
      return(x)
    })|>
      unname()
  )
}

mainUITables = function(container){
  grabMainTables(container@data)
}

awaitObserveTabs <- function(session, input, tables) {
  observeTab(
    session, input, "tabset",
    .commitout=FALSE,
    .tabs=tables
  )
}

observeSwitch = function(session, input, container){
  awaitObserveTabs(session, input, container@tables)
}

includeUITable = function(container){
  shiny::div(
    includeCSS("format.css"),
    includeScript("tbl.js"),
    includeScript("connection.js"),
    includeCSS("https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.css"),
    includeScript("https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.js"),
    useShinyjs(),  # Include shinyjs
    mainUITables(container)
  )
}