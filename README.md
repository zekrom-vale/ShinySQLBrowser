# ShinySQLBrowser
A Shiny application that allows easy SQL data entry for anyone once set up with the `configuration.yaml` file or any other object from R.

There are 4 steps in setting up the application with Shiny. Installing ShinySQLBrowser, `UIContainer`, `includeUITable`, and `observeSwitch` provide ease of access wrapers.
If needed you can sill call `UITable` directly, but for that you will need to read the R/man files.

## Instalation

```r
devtools::install_github("https://github.com/zekrom-vale/ShinySQLBrowser")
library(ShinySQLBrowser)
```

## Table Generation `UIContainer(tables, opt = NULL)`
This function takes a list of tables and optionaly a configuration object for `format_default`s and advanced configuration such as HTML building.
It returns a container object containing the generated `UITables`.

### Paramater 1: `tables`
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
See [`config.yaml:tables`](https://github.com/zekrom-vale/ShinySQLBrowser/blob/main/config.yaml) for an example of the table data

### Paramater 2: Optional `opt`
```yaml
[format_default:
    <type>: <JS function>
    [...]]
```
See [`config.yaml:otp`](https://github.com/zekrom-vale/ShinySQLBrowser/blob/main/config.yaml) for an example of the simple options data.  For more advanced configuration that is default to generating the HTML, see [`default.yaml`](https://github.com/zekrom-vale/ShinySQLBrowser/blob/main/inst/default.yaml).


## HTML Generation with  `includeUITable(container)`

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

## Server triggering on switch with: `observeSwitch(session, input, container)`
This function observes the switching of tabs and geerates or desposes the table

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
See [`app.R`](https://github.com/zekrom-vale/ShinySQLBrowser/blob/main/app.R) for an example I have been testing with.
I will eventualy publish a sanitized version of this data.
