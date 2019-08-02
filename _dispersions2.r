dispersions2 <- function(v, s=rep(1/length(v))) {
   # v = vector with frequencies of word/element in each corpus part
   # s = the relative sizes of the parts of the corpus (in percent, not their lengths in units)

   #cat("\nThis script was written by Stefan Th. Gries (<http://www.linguistics.ucsb.edu/faculty/stgries/>). It computes most measures of dispersion and all adjusted frequencies that I am aware of and that I discuss in these papers:\nGries, Stefan Th. 2008. Dispersions and adjusted frequencies in corpora. /International Journal of Corpus Linguistics/ 13(4). 403-437.\nGries, Stefan Th. 2010. Dispersions and adjusted frequencies in corpora: further explorations. In Stefan Th. Gries, Stefanie Wulff, & Mark Davies (eds.), /Corpus linguistic applications: current studies, new directions/, 197-212. Amsterdam: Rodopi.\n\n(The measures not included here are those by Savický & Hlavácová and Washtell, which require the exact orders of elements - for those measures, use the functions dispersions1.)\n\nThis script is made available under the GNU General Public License <http://www.gnu.org/licenses/gpl.html> and incorporates the correction of a mistake in the computation of the normalized version of DP, for which I am very much indebted to Jefrey Lijffijt. If you use it, PLEASE QUOTE the above-mentioned article; thank you. Copyright Stefan Th. Gries (2011)\n\n\n\n")

   if(length(v)!=length(s)) stop("The number of observed frequencies is not identical to the number of corpus parts!")

   n <- length(v) # n
   f <- sum(v) # f
   s <- s/sum(s) # s

   values <- list()

#    values[["observed overall frequency"]] <- f
#    values[["sizes of corpus parts / corpus expected proportion"]] <- s
#    values[["relative entropy of all sizes of the corpus parts"]] <- -sum(s*log(s))/log(length(s))
# 
#    values[["range"]] <- sum(v>0)
#    values[["maxmin"]] <- max(v)-min(v)
#    values[["standard deviation"]] <- sd(v)
#    values[["variation coefficient"]] <- sd(v)/mean(v)
#    values[["Chi-square"]] <- sum(((v-(f*s/sum(s)))^2)/(f*s/sum(s)))
# 
#    values[["Juilland et al.'s D (based on equally-sized corpus parts)"]] <- 1-((sd(v)/mean(v))/sqrt(n-1))
#    values[["Juilland et al.'s D (not requiring equally-sized corpus parts)"]] <- 1-((sd(v/s)/mean(v/s))/sqrt(length(v/s)-1))
#    values[["Carroll's D2"]] <- (log2(f)-(sum(v[v!=0]*log2(v[v!=0]))/f))/log2(n)
#    values[["Rosengren's S (based on equally-sized corpus parts)"]] <- ((sum(sqrt(v))^2)/n)/f
#    values[["Rosengren's S (not requiring equally-sized corpus parts)"]] <- sum(sqrt(v*s))^2/f
#    values[["Lyne's D3 (not requiring equally-sized corpus parts)"]] <- 1-((sum(((v-mean(v))^2)/mean(v)))/(4*f))
#    values[["Distributional consistency DC"]] <- ((sum(sqrt(v))/n)^2)/mean(v)
#    values[["Inverse document frequency IDF"]] <- log2(n/sum(v>0))
# 
#    values[["Engvall's measure"]] <- f*(sum(v>0)/n)
#    values[["Juilland et al.'s U (based on equally-sized corpus parts)"]] <- f*(1-((sd(v)/mean(v))/sqrt(n-1)))
#    values[["Juilland et al.'s U (not requiring equally-sized corpus parts)"]] <- f*(1-((sd(v/s)/mean(v/s))/sqrt(length(v/s)-1)))
#    values[["Carroll's Um (based on equally sized corpus parts)"]] <- f*((log2(f)-(sum(v[v!=0]*log2(v[v!=0]))/f))/log2(n))+(1-((log2(f)-(sum(v[v!=0]*log2(v[v!=0]))/f))/log2(n)))*(f/n)
#    values[["Rosengren's Adjusted Frequency (based on equally sized corpus parts)"]] <- (sum(sqrt(v))^2)/n
#    values[["Rosengren's Adjusted Frequency (not requiring equally sized corpus parts)"]] <- sum(sqrt(v*s))^2
#    values[["Kromer's Ur"]] <- sum(digamma(v+1)+0.577215665) # C=0.577215665
# 
   values[["Deviation of proportions DP"]] <- sum(abs((v/f)-s))/2
   values[["Deviation of proportions DP (normalized)"]] <- (sum(abs((v/f)-s))/2)/(1-min(s)) # corrected, see below
   ######################
   # Thanks a lot to Jefrey Lijffijt (p.c., 3 July 2011)
   # setting up data
   expected <- c(0.01, 0.01, 0.98)
   observed <- c(1, 0, 0)

   # computing DP
   DP <- sum(abs(expected-observed))/2

   # computing DPmax
   observed.for.DPmax <- rep(0, length(expected))
   observed.for.DPmax[which.min(expected)] <- 1
   DPmax <- sum(abs(expected-observed.for.DPmax))/2
   # this is the complex way to say
   # DPmax = 1 - min(corpus.part.sizes)

   # computing DPnorm
   DPnorm <- DP/DPmax
   ######################

   return(values)
}
