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
  tables = purrr::map(data, function(table){
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
  	htmltools::includeCSS("format.css"),
  	htmltools::includeScript("tbl.js"),
  	htmltools::includeScript("connection.js"),
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
