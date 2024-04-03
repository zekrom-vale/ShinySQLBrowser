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

CSSKEYS = c("width", "height")

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
#' @examples
#' data = yaml::read_yaml("config.yaml")$tables
#' container = UIContainer(data)
#'
UIContainer = function(data){
  env = parent.frame()
  tables = purrr::map(data, function(table){
    input = purrr::map(table$rows, function(x){
      r = x$input
      if(is.list(r))if(!is.null(r$con))r$con = get(r$con, envir = env)
      r
    })|>
      purrr::discard(is.null)
    css = purrr::imap(table$rows, function(val, col){
    	kv=purrr::imap(val, function(css, key){
    		`if`(
    			key %in% CSSKEYS,
    			glue::glue("{key}:{css};\n"),
    			""
    		)
    	})|>
    		glue::glue_collapse()
    	glue::glue("<table$name>-<col>{<kv>}", .open = "<", .close = ">")
    })|>
    	glue::glue_collapse()

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
      keys = table$keys,
      css = sass::sass(css)
    )
  })
  methods::new("UIContainer", data=data, tables=tables)
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
#' @examples
#' ui = bootstrapPage(
#'   theme = bslib::bs_theme(version = 4), # Optional don't use 5 https://github.com/zekrom-vale/ShinySQLBrowser/issues/2
#'   includeUITable(container)
#' )
observeSwitch = function(session, input, container){
  observeTab(
    session, input, "tabset",
    .commitout=FALSE,
    .tabs=container@tables
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
includeUITable = function(
    container,
    jqueryCSS = "https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.css",
    jqueryJS = "https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.4/jquery-confirm.min.js"
  ){
  shiny::div(
  	htmltools::includeScript(system.file("tbl.js", package="ShinySQLBrowser")),
  	htmltools::includeScript(system.file("connection.js", package="ShinySQLBrowser")),
  	`if`(is.null(jqueryCSS), NULL, htmltools::includeCSS(jqueryCSS)),
  	`if`(is.null(jqueryJS), NULL, htmltools::includeScript(jqueryJS)),
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

getConfig = function(){
  getOption(
  	"SSQLB:Config",
  	yaml::read_yaml(system.file("default.yaml", package="ShinySQLBrowser"))
  )
}

setConfig = function(data){
	getConfig()|>
		utils::modifyList(data)|>
		options("SSQLB:Config" = _)
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
					yaml::read_yaml(system.file("default.yaml", package="ShinySQLBrowser")),
					getOption(
						glue::glue("{prefix}{path[[1]]}"),
						list()
					)
				)
			)
		}
		# upper is more general
		upper = rec(path[1:length(path)-1]) # IE list(x=list(y=1)) || list(x=list(y=list(z=1)))
		lower = getOption(
			glue::glue("{prefix}{paste0(path, collapse='.')}"), # IE list(y=1) || list(x=list(y=list(z=1)))
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
