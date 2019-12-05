#' Combine multiple independent P-values together using Fisher's method
#' 
#' Fisher's method for combining P-values together consists of studying a test statistic of \eqn{T = \sum_i -log(P_i)} and 
#' finding the corresponding point in the cumulative distribution of an appropriately parameterised chi-squared distribution.
#'  
#' The basic assumption is that P-values are uniformly distributed under the null-hypothesis, meaning that \eqn{-log(P) \sim exp(1)}. Recall that
#' if \eqn{X \sim exp(1)} then \eqn{\sum_{k} X_{k} \sim \Gamma (k,1) \sim \chi^2 (2k) } (note that the gamma and erlang distributions are identical for integer \eqn{k}).
#' We therefore simply calculate the point in the cumulative of the gamma distribution
#' 
#' Note that the use of this method for analysis of omics datasets was pioneered by Luo et al.
#' 
#' @param testPvalues A numerical vector of P-values to be tested
#' @param ... Unused. Included to allow for similar form to betaUniformPvalueSumTest
#' @return combindedP A single P-value combining the results of multiple independent hypothesis tests into one
#' @references \url{https://en.wikipedia.org/wiki/Fisher%27s_method}
#' @references \url{https://en.wikipedia.org/wiki/Erlang_distribution}
#' @references Luo, W., Friedman, M. S., Shedden, K., Hankenson, K. D., & Woolf, P. J. (2009). GAGE: generally applicable gene set enrichment for pathway analysis. BMC Bioinformatics
#' @importFrom stats pgamma
#' @importFrom Biobase mkScalar
#' @export
setGeneric("fishersPvalueSumTest",
           signature = c("testPvalues"),
           valueClass = "Pvalue",
           function(testPvalues, ...) standardGeneric("fishersPvalueSumTest"))

#' @describeIn fishersPvalueSumTest Convert to P-values on the fly
setMethod("fishersPvalueSumTest",
          signature = c( testPvalues = "numeric"),
          function(testPvalues, ...) callGeneric( new("Pvalues", testPvalues)) )

#' @describeIn fishersPvalueSumTest Fisher's combinded probability test
setMethod("fishersPvalueSumTest",
          signature = c(testPvalues = "Pvalues"),
          function(testPvalues){
            
            testStatistic <- sum(-log(testPvalues))
            nValues <- length(testPvalues)
            
            #Using the pgama parameterisation, rather than chi-squared, so as to be consistent with the betaUniformPvalueSumTest
            combinedPval <- pgamma(testStatistic, shape = nValues, rate = 1, lower.tail = FALSE) 
            
            return( new("Pvalue", mkScalar(combinedPval)) )
          })