#' Motif enrichment analysis across a database of motifs
#' 
#' Test for motif enrichment in a set of genes of interest. The function
#' performs a fisher exact test to calculate the enrichment of each motif for
#' the set of selected genes, from the background genes in promoter.DB.
#' 
#' %% ~~ If necessary, more details than the description above ~~
#' 
#' @param Genes list of the genes of interest
#' @param promoterDB promoterDB object
#' @return An R object with 3 elements. The element names of the resulting
#' object can be retreived with the function \code{\link[base]{names}}. Each of
#' the elements is a data frame with motifs on the rows and the enrichment
#' statistics on the columns. Each row corresponds to one-sided
#' \code{\link[stats]{fisher.test}} for motif enirchment in the given gene set,
#' based on occurence of the motif in the plus, minus or both strands combined.
#' The columns of the data frame are:
#' 
#' p.value - the p.value of the Fisher test,
#' 
#' odds.ratio - the estimate of the odds ration from the Fisher test,
#' 
#' genes - subset of the genes that are enirched with the motif and
#' 
#' p.adj.BH - the multiple test correction of the p.value with the "BH"
#' adjustment.
#' @note %% ~~further notes~~
#' @author %% ~~who you are~~
#' @seealso %% ~~objects to See Also as \code{\link{help}}, ~~~
#' @references %% ~put references to the literature/web site here ~
#' @examples
#' 
#' # Read an example gene set. 
#' genes=read.table(system.file("extdata","test_geneSet.txt",package="TFbindR"),stringsAsFactors=F)
#' 
#' # Run the function with the promoterDB generated by the function makePromoterDBfromFIMO.
#' enrichment=computeEnrichments(as.character(unlist(genes)), "TAIR10_500bp_upstream.fimo.db.rda") 
#' 
#' @export computeEnrichments
computeEnrichments <- function(Genes, promoterDB = "promoter.DB") {
	# Compute 
	# Args:
	#	Genes: list of the genes of interest. 
	#	promoterDB: promoterDB object generated by \code{\link{makePromoterDBfromFIMO}} or \code{\link{makePromoterDBfromRE}}. The name of the object stored in the promoterDB should be "Strands".
	# Returns:
	#	A list of 3 data frames, each with motifs on the rows and the enrichment statistics on the columns. The motif enrichment is calculated for the 3 elements in the promoter DB, namely "plus", "minus" and "both". 	
	# Save the genes from the promoterDB.
    if (promoterDB!="TAIR10_500bp_upstream.fimo.db.rda")
    	load(promoterDB)
    Allgenes = rownames(Strands[[1]])
    
    # Test if all genes exist in promoterDB
    t1 = which(!(Genes %in% Allgenes))
    if (length(t1) > 0) {
        message("Gene(s) ", paste(Genes[t1], collapse = ","), " not found from promoter DB. Dropping from analysis.")
        Genes = Genes[Genes %in% Allgenes]
    }
    
    geneset = (Allgenes %in% Genes)
    res = list()
    for (k in 1:3) {
        Nmotif = ncol(Strands[[k]])
        # Data frame where the results will be stored. The analysis is repated for each motif. 
        ftest = data.frame(p.value = rep(NA, Nmotif), odds.ratio = rep(NA, Nmotif), p.adj.BH = rep(NA, 
            Nmotif), genes = rep("", Nmotif), stringsAsFactors = F)
        rownames(ftest) = colnames(Strands[[k]])
        for (i in 1:Nmotif) {
            if (sum(Strands[[k]][Genes, i] > 0) > 0) {
                MM = fisher.test(geneset, Strands[[k]][, i] > 0, alternative = "greater")
                ftest$p.value[i] = MM$p.value
                ftest$odds.ratio[i] = MM$estimate
                ftest$genes[i] = paste(names(which(Strands[[k]][Genes, i] > 0)), collapse = ";")
            }
        }
        if (max(ftest$p.value, na.rm = T) > 1) 
            ftest$p.value[which(ftest$p.value > 1)] = 1
        ftest = ftest[which(!is.na(ftest$p.value)), ]
        # Correction for multiple hypothesis testing
        ftest$p.adj.BH = p.adjust(ftest$p.value, method = "BH")
        # Ordering of the result based on p-value.
        t1 = order(ftest$p.value)
        names(t1) = rownames(ftest)[t1]
        ftest = ftest[t1, ]
        res[[k]] = ftest
    }
    names(res) = names(Strands)
    return(res)
}
