recursivefor = function(l, func){
  for(i in names(l)){
    if(typeof(l[[i]])=="list")l[[i]]=recursivefor(l[[i]], func)
    else l[[i]]=func(l[[i]], i)
  }
  l
}

#'Returns the first element that is not NULL
#'@param ... A list of elements
retnn=function(...){
  #`if`(is.null(input$con),this@con,input$con)
  l=list(...)
  for(i in l) {
    if(!is.null(i))return(i)
  }
}

#'Returns the first element that is not NA
#'@param ... A list of elements
retna=function(...){
  l=list(...)
  for(i in l) {
    if(!is.na(i))return(i)
  }
}

#' Vectorize `[` Ie x[i]
#' @param lhs The vector to access
#' @param rhs A vector of things to access
#' @returns A vector of results
#' 
#' @examples
#' ve(c(1,2,3,4), c(1,3,2))
#' ve(letters, c(26, 5, 11, 18, 15, 13))
ve=Vectorize(function(lhs,rhs)lhs[rhs], vectorize.args = "rhs")

#' Vectorize `[[` Ie. $ or x[[i]]
#' @param lhs The list to access
#' @param rhs A vector of things to access
#' @returns A vector of results
#' 
#' @examples
#' vd(list(a=1,b=2,c=3), c("b","a","c"))
#' 
vd=Vectorize(function(lhs,rhs)lhs[[rhs]], vectorize.args = "rhs")

vdn=Vectorize(function(lhs,rhs,n)lhs[[rhs]][n], vectorize.args = "rhs")