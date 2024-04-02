% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/container.R
\name{UIContainer}
\alias{UIContainer}
\title{Generates a list of UITables with a configuration object}
\usage{
UIContainer(data)
}
\arguments{
\item{data}{A Data Structure}
}
\value{
An object containing a list of UITables and the original data
}
\description{
Generates a list of UITables with a configuration object
}
\section{Data Structure}{

An R nested list with the flowing structure.
It is recommended to use yaml and import it into R with \code{\link{read_yaml}}

\if{html}{\out{<div class="sourceCode yaml">}}\preformatted{<TableName>:
  tab:
    title: <TableName>
    [value: null]
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
      [width: <css width not implemented>]
      input:
        [con: <SQL connection>]
        table: <SQL Table>
        key: <SQL column to use as a key>
        val: <SQL column to use as a value>
      [...]]
    [js: <not implemented>]
    [tbl: <function to modify the table>]
    keys: <Primary keys of the table>
  [...]
}\if{html}{\out{</div>}}
}

\examples{
data = yaml::read_yaml("config.yaml")$tables
container = UIContainer(data)

}