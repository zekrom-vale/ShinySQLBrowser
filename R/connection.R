#' Process Where
#'
#' @description
#' Processes the where list of operations and returns an SQL \code{where} statement
#' as a string.
#'
#'
#' @param where A list of operations to do returned by JS
#' @param con The \code{link{pool}} connection
#' @param .comp Default comparator \code{equal ==}
#' @param .op Default operator \code{and &&} excluded in last statement
#' @param .NAisNULL Treats \code{NA} as \code{NULL}
#'
#' @return A partial SQL string of \code{id comp val op} like \code{ID == 1 and}
#' @export
procWhere = function(where, con, .comp="==", .op="and", .NAisNULL=TRUE){
  l=list()
  for(i in seq(1, length(where))){
    val = where[[i]]
    id=names(where)[[i]]


    comp=retna(val[2], .comp)
    op=retna(val[3], .op)
    val=val[1]
    # UNTRUSTED id
    id=DBI::dbQuoteIdentifier(con, id)
    # UNTRUSTED comp

    if(i == length(where)) comp = ""
    else comp=switch(comp,
       "and" = "and",
       "&&" = "and",
       "&" = "and",

       "or" = "or",
       "||" = "or",
       "|" = "or",

       "xor" = "xor",
       ""
    )

    # UNTRUSTED op
    op=switch(op,
      "lt" = "<",
      "<" = "<",

      "gt" = ">",
      ">" = ">",

      "ge" = ">=",
      ">=" = ">=",
      "=>" = ">=",

      "le" = "<=",
      "<=" = "<=",
      "=<" = "<=",

      "ne" = "<>",
      "!=" = "<>",
      "<>" = "<>",

      "eq" = "=",
      "==" = "=",
      "=" = "=",
      "="
    )
    # UNTRUSTED val
    if(is.null(val))val=""
    if(is.na(val))val=""
    val=DBI::dbQuoteLiteral(con, val)
    if(val=="''"&&.NAisNULL)val="NULL"

    l[[i]]=glue::glue('{id} {op} {val} {comp}')|>
      as.character()
  }
  paste(l, collapse=" ")
}

#' Process Data
#'
#' @description
#' Processes the data list \code{set} statement as a string.
#'
#' @param data A list of columns returned by JS
#' @param con The \code{link{pool}} connection
#' @param .NAisNULL Treats \code{NA} as \code{NULL}
#'
#' @return A partial SQL string of \code{id comp val op} like \code{ID == 1 and}
#' @export
procData = function(data, con, .NAisNULL=TRUE){
  purrr::imap(data, function(val, id){
    if(is.null(val))val=""
    if(is.na(val))val=""
    val=DBI::dbQuoteLiteral(con, val)
    if(val=="''"&&.NAisNULL)val="NULL"
    glue::glue(DBI::dbQuoteIdentifier(con, id), " = ", val)
  })|>
    paste(collapse=", ")
}


#' Send an SQL Update
#'
#' @inheritParams procData
#' @inheritParams procWhere
#' @param table The table to operate on
#'
#' @export
sendUpdate = function(where, data, table, con, .comp="==", .op="and"){
  where = procWhere(where, con, .comp=.comp, .op=.op)
  data = procData(data, con)

  data=purrr::discard(data, function(x)is.null(x)||x=="")

  exe=glue::glue("UPDATE {table} SET {data} WHERE {where}")|>
    as.character()

  tryCatch(
    list(status= "resolve", effect=DBI::dbExecute(con, exe)),
    error = function(e)
      list(status= "reject", effect=list(error=e$message, call=e$call, sql=exe))
  )
}

#' Send an SQL Remove
#'
#' @inheritParams procWhere
#' @param table The table to operate on
#'
#' @export
sendRemove = function(where, table, con, .comp="==", .op="&"){
  where = procWhere(where, con, .comp=.comp, .op=.op)

  exe=glue::glue("DELETE FROM {table} WHERE {where}")

  tryCatch(
    list(status= "resolve", effect=DBI::dbExecute(con, exe)),
    error = function(e)
      list(status= "reject", effect=list(error=e$message, call=e$call, sql=exe))
  )
}

#' Send an SQL Remove
#'
#' @inheritParams procWhere
#' @param table The table to operate on
#'
#' @export
sendRead = function(where, table, con, .comp="==", .op="&"){
  where = procWhere(where, con, .comp=.comp, .op=.op)

  exe=glue::glue("SELECT * FROM {table} WHERE {where}")|>
    as.character()

  tryCatch(
    list(status= "resolve", data=DBI::dbGetQuery(con, exe)|>as.list()),
    error = function(e)
      list(status= "reject", effect=list(error=e$message, call=e$call, sql=exe))
  )
}

#' Send an SQL Create
#'
#' @inheritParams procData
#' @param table The table to operate on
#' @param keys The primary keys of the table
#'
#' @export
sendCreate = function(data, keys, table, con, .autoinc=TRUE){
  data=purrr::discard(data, function(x)is.null(x)||x=="")
  run=tryCatch(
    dplyr::as_tibble(data)|>
      DBI::dbAppendTable(con, table, value=_)|>
      list(status= "resolve", effect=_),
    error=function(e)
      list(status= "reject", effect=list(error=e$message, call=e$call, data=data))
  )

  if(run$status=="resolve"&&.autoinc){

    exe=glue::glue('SELECT * FROM {table} WHERE {str_split(keys, "[|,;:]")[[1]][1]} = LAST_INSERT_ID()')

    run$sql=exe

    run$data=tryCatch(
      DBI::dbGetQuery(con, exe)|>
        as.list(),
      error=function(e)NULL
    )
  }
  run
}


#' Observer
#'
#' @inheritParams shinyTab
#' @param id The shiny value to listen to
#' @param func What to do
#'
#' @export
#'
observer = function(session, input, id, func){
  message(glue::glue("Adding observer {id}"))
  shiny::observeEvent(input[[id]], {
    message(glue::glue("{id} recived {input[[id]]}"))
    data = func(input[[id]])
    message(glue::glue("seding message {data}"))
    session$sendCustomMessage(id, jsonlite::toJSON(data))
  })
}

#' Send an SQL Update
#'
#' @inheritParams procData
#' @inheritParams procWhere
#' @inheritParams observer
#' @param uitable The table to operate on
#'
#' @export
tableObserver = function(session, input, id, uitable, .comp="==", .op="&"){
  observer(session, input, id, function(message){
    if(purrr::is_empty(message$where)&&purrr::is_empty(message$data))return(
      list(status= "reject", effect=list(error="Nothing Sent"))
    )

    #  where:list(
    #    ID:value |
    #    ID:c(value, ">" | "<" | ">=" | "<=" | "=", "&" | "|"),
    #    ...
    #  )
    #  data=list(
    #    col1=val1, col2=val2, ... coln=valn
    #  )
    switch (message$action,
      "create" = {
        return(
          sendCreate(message$data, uitable@keys, uitable@name, uitable@con, .autoinc=uitable@autoinc)
        )
      },
      "update" = {
        return(
          sendUpdate(message$where, message$data, uitable@name, uitable@con, .comp=.comp, .op=.op)
        )
      },
      "remove" = {
        return(
          sendRemove(message$where, uitable@name, uitable@con, .comp=.comp, .op=.op)
        )
      },
      "read" = {
        return(
          sendRead(message$where, uitable@name, uitable@con, .comp=.comp, .op=.op)
        )
      }
    )

  })
}
