#' Apply a function recursively to a list
#'
#' This function applies a given function `func` to each element in a list `l`.
#' If an element is a list itself, the function is applied recursively to each of its elements.
#'
#' @param l A list to which the function will be applied.
#' @param func A function that takes two arguments: an element from the list and its name.
#' @return A list with the function applied to each element.
recursivefor = function(l, func){
	# Loop over the names of the list
	for(i in names(l)){
		# If the current element is a list
		if(typeof(l[[i]])=="list")
			# Apply the function recursively to the list
			l[[i]] = recursivefor(l[[i]], func)
		else
			# Apply the function to the current element
			l[[i]]=func(l[[i]], i)
	}
	# Return the modified list
	l
}

#'Returns the first element that is not NULL
#'@param ... A list of elements
retnn = function(...){
  #`if`(is.null(input$con),this@con,input$con)
  l = list(...)
  for(i in l){
    if(!is.null(i))return(i)
  }
}

#'Returns the first element that is not NA
#'@param ... A list of elements
retna = function(...){
  l = list(...)
  for(i in l){
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
ve = Vectorize(function(lhs,rhs)lhs[rhs], vectorize.args = "rhs")

#' Vectorize `[[` Ie. $ or x[[i]]
#' @param lhs The list to access
#' @param rhs A vector of things to access
#' @returns A vector of results
#'
#' @examples
#' vd(list(a=1,b=2,c=3), c("b","a","c"))
#'
vd = Vectorize(function(lhs,rhs)lhs[[rhs]], vectorize.args = "rhs")

vdn = Vectorize(function(lhs,rhs,n)lhs[[rhs]][n], vectorize.args = "rhs")
