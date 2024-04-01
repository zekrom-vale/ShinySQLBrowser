methods::setClass(
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
  env = parent.frame()
  tables = purrr::map(data, function(table){
    input = purrr::map(table$rows, function(x){
      r = x$input
      if(is.list(r))if(!is.null(r$con))r$con = get(r$con, envir = env)
      r
    })|>
      purrr::discard(is.null)
    UITable(
      get(table$con, envir = env),
      table$name,
      id = table$id,
      types = retnn(table$types, list()),
      typemap = retnn(table$typemap, list()),
      opt = retnn(table$opt, list()),
      input = input,
      js = table$js,
      tbl = `if`(is.null(table$tbl), dplyr::tbl, get(table$tbl, envir = env)),
      keys = table$keys
    )
  })
  methods::new("UIContainer", data=data, tables=tables)
};

observeSwitch = function(session, input, container){
  observeTab(
    session, input, "tabset",
    .commitout=FALSE,
    .tabs=container@tables
  )
}

includeUITable = function(container){
  shiny::div(
  	htmltools::includeScript(system.file("tbl.js", package="ShinySQLBrowser")),
  	htmltools::includeScript(system.file("connection.js", package="ShinySQLBrowser")),
  	htmltools::includeCSS("https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.css"),
  	htmltools::includeScript("https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.js"),
  	shinyjs::useShinyjs(),  # Include shinyjs
    mainTables(
      id = "tabset",
      .adv = T,
      .tabs= purrr::map(container@data, function(table){
        x=table$tab|>
          purrr::discard(is.null)
        x$id = table$id
        return(x)
      })|>
        unname()
    )
  )
}
