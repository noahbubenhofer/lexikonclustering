source("_dispersions2.r")

griesdp <- function (v, s, m="dpnorm") {
	r <- dispersions2(v, (s/sum(s)*100));
	if (m == "dpnorm") {
		return (r$`Deviation of proportions DP (normalized)`);
	} else if (m == "chi") {
		return (r$`Chi-square`);
	} else if (m == "var") {
		return (r$`variation coefficient`);
	}
}