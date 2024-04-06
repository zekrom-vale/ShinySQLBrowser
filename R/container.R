#' UIContainer
#'
#' @description
#' A simple container to hold \code{\link{UITable}} objects
#'
#' @slot data The original data used to generate the \code{\link{UITable}}
#' @slot tables A list of \code{\link{UITable}}
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


#' Generate UITables
#'
#' @description
#' Generates a list of UITables with a configuration object
#'
#' @param data A Data Structure
#' @slot data The original data used to generate the \code{\link{UITable}}
#' @slot tables A list of \code{\link{UITable}}
#'
#' @return An object containing a list of UITables and the original data
#' @export
#'
#' @section Data Structure:
#' An R nested list with the flowing structure.
#' It is recommended to use yaml and import it into R with \code{\link{read_yaml}}
#'
#' ```yaml
#' <TableName>:
#'   tab:
#'     title: <TableName>
#'     [value: null]
#'     [icon: <Icon of the tab>]
#'   con: <SQL connection>
#'   name: <SQL table name>
#'   id: <HTML ID of table>
#'   [types:
#'     <HTML input/select types>[...]]
#'   opt: <option object>
#'   [rows:
#'     <row name>:
#'       [width: <css width not implemented>]
#'       input: <html input/select override>
#'     <row name>:
#'       [width: <css width not implemented>]
#'       input:
#'         [con: <SQL connection>]
#'         table: <SQL Table>
#'         key: <SQL column to use as a key>
#'         val: <SQL column to use as a value>
#'       [...]]
#'     [js: <not implemented>]
#'     [tbl: <function to modify the table>]
#'     keys: <Primary keys of the table>
#'   [...]
#' ```
#'
#' @example examples/sqlite/app.R
#' @example examples/logs/app.R
UIContainer = function(data, opt = NULL, .resetCfg = TRUE, env = parent.frame()){
  if(.resetCfg) resetConnfig()
  if(!is.null(opt))setConfig(opt)
  tables = purrr::map(data, function(table){
    input = purrr::map(table$rows, function(x){
      r = x$input
      if(is.list(r))if(!is.null(r$con))r$con = get(r$con, envir = env)
      r
    })|>
      purrr::discard(is.null)
    css = purrr::imap(table$rows, function(val, col){
    	kv = purrr::imap(val, function(css, key){
    		`if`(
    			!key %in% getConfig()$opt$cssExclude,
    			glue::glue("{key}:{css};\n"),
    			""
    		)
    	})|>
    		glue::glue_collapse()
    	if(!is.null(val$css)){
    		css = get(val$css, envir = env)(glue::glue(".{table$id}-{col}"), table$id, col)
    	}
    	else css = ""
    	glue::glue(
    		"<css>
.<table$id>-<col> div,
.<table$id>-<col> input,
.<table$id>-<col> select{<kv>}",
    		.open = "<",
    		.close = ">"
    	)
    })|>
    	glue::glue_collapse()

    UITable(
      get(table$con, envir = env),
      table$name,
      id = table$id,
      types = retnn(table$types, list()),
      opt = retnn(table$opt, list()),
      input = input,
      js = table$js,
      tbl = `if`(is.null(table$tbl), dplyr::tbl, get(table$tbl, envir = env)),
      keys = table$keys,
      css = sass::sass(css)
    )
  })
  methods::new("UIContainer", data = data, tables = tables)
};


#' Observe Switch of Tabs
#'
#' @description
#' Observes the switching of tabs to trigger loading of the tables
#' Put this in the \code{\link{shinyApp}} \code{server} code
#'
#' @seealso \code{\link{UIContainer}}
#' @seealso \code{\link{shinyApp}}
#'
#' @param session The Shiny session
#' @param input The Shiny input
#' @param container A container object of \code{\link{UITables}}
#'
#' @return  an observer reference class object
#' @export
#'
#' @example examples/sqlite/app.R
#' @example examples/logs/app.R
observeSwitch = function(session, input, container, .onClickOff = "commit"){
  observeTab(
    session, input, "tabset",
    .onClickOff = .onClickOff,
    .tabs = container@tables
  )
}

#' Load Requirements
#'
#' @description
#'
#' Includes js, css, shinyJS dependencies into the shiny UI
#' Put this in the \code{\link{shinyApp}} \code{UI} code
#'
#' @param container A container object of UITables
#' @param jqueryCSS The jquery css to use.  Default: v3.3.4 via cloudflare cdnjs. On \code{NULL} exclude it
#' @param jqueryJS The jquery js to use.  Default: v3.3.4 via cloudflare cdnjs. On \code{NULL} exclude it
#'
#' @return A list of UI HTML elements required for ShinySQLBrowser
#' @export
#'
#' @example examples/sqlite/app.R
#' @example examples/logs/app.R
includeUITable = function(
    container,
    jqueryCSS = "https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.css",
    jqueryJS = "https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.js",
    generateFormat = TRUE
  ){
  shiny::div(
  	htmltools::includeScript(system.file("tbl.js", package = "ShinySQLBrowser")),
  	htmltools::includeScript(system.file("connection.js", package = "ShinySQLBrowser")),
  	`if`(is.null(jqueryCSS), NULL, htmltools::includeCSS(jqueryCSS)),
  	`if`(is.null(jqueryJS), NULL, htmltools::includeScript(jqueryJS)),
  	`if`(
  		generateFormat,
  		htmltools::tags$script(htmltools::HTML(genFormat(container@data))),
  		NULL
  	),
  	shinyjs::useShinyjs(),  # Include shinyjs
    mainTables(
      id = "tabset",
      .adv = TRUE,
      .tabs = purrr::imap(container@data, function(table, name){
        x = table$tab|>
          purrr::discard(is.null)
        if(is.null(x$value))x$value = name
        x$id = table$id
        return(x)
      })|>
        unname()
    )
  )
}

getConfig = function(){
  opt = getOption("SSQLB:Config", NULL)
  if(is.null(opt)){
  	opt = yaml::read_yaml(system.file("default.yaml", package = "ShinySQLBrowser"))
  	options("SSQLB:Config" = opt)
  	return(opt)
  }
  else return(opt)
}

setConfig = function(data){
	getConfig()|>
		utils::modifyList(data)|>
		options("SSQLB:Config" = _)
}

resetConnfig = function(){
	options("SSQLB:Config" = NULL)
}

recGet = function(val, path){
	if(length(path)==1)return(val[[path[1]]])
	return(recGet(val[[path[1]]], path[2: length(path)]))
}

#' Experimental recursive get function
#' Explores all \code{getOption} \code{.}'s like an object
getConfigByName = function(name, prefix = "SSQLB:"){
	#' Process order
	#' root
	#' root a
	#' root a b
	#' root a b c
	rec = function(path){
		# root
		if(length(path)==1){
			return(
				utils::modifyList(
					yaml::read_yaml(system.file("default.yaml", package = "ShinySQLBrowser")),
					getOption(
						glue::glue("{prefix}{path[[1]]}"),
						list()
					)
				)
			)
		}
		# upper is more general
		upper = rec(path[1:length(path)-1]) # IE list(x = list(y = 1)) || list(x = list(y = list(z = 1)))
		lower = getOption(
			glue::glue("{prefix}{paste0(path, collapse = '.')}"), # IE list(y = 1) || list(x = list(y = list(z = 1)))
			list()
		)
		mvdLower = list()
		mvdLower[[path[length(path)]]] = lower
		return(
			utils::modifyList(
				upper,
				mvdLower # More significant
			)
		)
	}
	name = stringr::str_split(name, "[.$-_]")
	rec(name)|>
		recGet(name)
}

setConfigByName = function(name, value){

}


genFormat = function(tables, opt = getConfig()$opt){
	type = purrr::imap(opt$format_default, function(func, name){
		glue::glue('"{name}": {func}')
	})|>
		glue::glue_collapse(sep = ",\n")

	col = purrr::map(tables, function(cols){
		inner = purrr::imap(cols$rows, function(val, name){
			glue::glue('"{name}": {val$format}')
		})|>
			purrr::discard(function(x){length(x)==0})|>
			glue::glue_collapse(sep = ",\n")
		glue::glue(
			"<cols$id>:{<inner>}",
			.open = "<",
			.close = ">"
		)
	})|>
		glue::glue_collapse(sep = ",\n")

	glue::glue(
		"window.message = <stringr::str_to_lower(getConfig()$opt$message)>;
const UITable={
<type>,
<col>
}",
		.open = "<",
		.close = ">"
	)
}
