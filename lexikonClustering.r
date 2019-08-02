# Clusterberechnung

# How To Lexikon Clustering
# ======================================
#   Wortverlaufskuven clustern und darstellen.
# 
# 1. Wortfrequenzen pro Einheit berechnen:
#   
#   Perl-Script semtracks_words.pl
# - richtigen Klassifikator (Jahr oder was auch immer) auswählen/im Script anpassen.
# 
# 2. Clustering: R-Script lexiconClustering.r


# specify input file:
filename <- "frequencyfile.tbl";

###### ACHTUNG: Entscheid, ob mit gleitendem Durchschnitt oder nicht gearbeitet werden soll!
l <- read.table(paste0(filename,".norm.csv"), sep="\t", header = F, row.names = 1);
l_abs <- read.table(paste0(filename,".abs.csv"), sep="\t", header = F, row.names = 1);

# Bei Datei mit gleitendem Durchschnitt die ersten fünf Spalten löschen (die alle 0 sind):

###### ACHTUNG: Entscheid, ob mit gleitendem Durchschnitt oder nicht gearbeitet werden soll!
#l <- l[,-c(1:5)];

# Auswahl von Fällen mit bestimmten DP-Werten:

# Berechnung DP
source("~/Documents/programmierung/R/lib/griesDP.r")
corpus_sizes <- NULL;
for (i in 1:length(colnames(l_abs))) { 
	corpus_sizes <- c(corpus_sizes, sum(l_abs[,i])) 
}

l_dp <- NULL;
for (i in 1:length(rownames(l))) {
	cat("Verarbeite Zeile ", i, " von ", length(rownames(l)), "\n");
	l_dp[rownames(l_abs[i,])] <- griesdp(l_abs[i,], corpus_sizes);
}
# entweder oder:
#l_sel_names <- subset(l_dp, l_dp > 0.3 & l_dp < 0.8);
#l_sel_names <- subset(l_dp, l_dp > 0.3);
l_sel_names <- subset(l_dp, l_dp >= 0);
#l_sel_names <- subset(l_dp, l_dp > 0 & l_dp < 1);

l_sel_names <- colnames(t(l_sel_names));

l_sel <- subset(l, rownames(l) %in% l_sel_names);
l_dp_sel <- subset(l_dp, colnames(t(l_dp)) %in% l_sel_names);

# Clusterberechnung
nrOfGroups <- 20;


c <- dist(l_sel, method="euclidean");
fit <- hclust(c, method="ward.D");

pdf(paste(filename, "_ClusterDendrogramm-", nrOfGroups, ".pdf", sep=""), width=8, height=5);
plot(fit, cex=0.2);
groups <- cutree(fit, k=nrOfGroups);
rect.hclust(fit, k=nrOfGroups, border="gray");
groups <- groups[order(groups)];
#groups_dp <- t(rbind(l_dp_sel, groups));
write.table(groups, file=paste(filename, "_ClusterDendrogramm-", nrOfGroups, ".txt", sep=""), sep="\t", fileEncoding="UTF8");
dev.off();

# -> Gruppen speichern, konvertieren


for (i in 1:max(groups)) {
	frames <- colnames(t(subset(groups, groups==i)));
	
	pdf(paste(filename, "_LexikonCluster-", i, "-", nrOfGroups, ".pdf", sep=""), width=8, height=5);
	
	plot(t(l[frames[1],]), type="l", xaxt="n", xlab="Jahre", ylab="Frequenz (normalisiert)",  main=paste("Lemmata Cluster-Gruppe", i));
	for (ii in 2:length(frames)) { 
		points(t(l[frames[ii],]), type="l") 
	}
	#axis(1, at=seq(from=7, to=144, by=10), labels=seq(from=1870,to=2000,by=10));
	#axis(1, at=seq(from=1, to=138, by=10), labels=seq(from=1875,to=2012,by=10));
	#axis(1, at=seq(from=1, to=61, by=10), labels=seq(from=1951,to=2011,by=10));
	axis(1, at=seq(from=1, to=4, by=1), labels=seq(from=2015,to=2018,by=1));
	
	
	
	dev.off();
	
	
}


# Darstellung von Wortwolken
library(wordcloud);

#i <- 1;

for (i in 1:max(groups)) {
	frames <- colnames(t(subset(groups, groups==i)));
	wc_names <- NULL;
	wc_sizes <- NULL;
	wc_colors <- NULL;
	wc_counter_nouns <- 0;
	wc_counter_adjectives <- 0;
	wc_counter_verbs <- 0;
	wc_counter_pronouns <- 0;
	
	#ii <= 5
	for (ii in 1:length(frames)) {
		f <- strsplit(frames[ii], "_");
		color <- NULL;
		color <- "#000000"
		# if (substr(f[[1]][2], 1, 1) == "A") {
		# 	color <- "#666666";
		# 	wc_counter_adjectives <- wc_counter_adjectives+1;
		# } else if (substr(f[[1]][2], 1, 1) == "N") {
		# 	color <- "#000000";
		# 	wc_counter_nouns <- wc_counter_nouns+1;
		# } else if (substr(f[[1]][2], 1, 1) == "P") {
		# 	color <- "#CCCCCC";
		# 	wc_counter_pronouns <- wc_counter_pronouns+1;
		# } else if (substr(f[[1]][2], 1, 1) == "V") {
		# 	color <- "#999999";
		# 	wc_counter_verbs <- wc_counter_verbs+1;
		# } else {
		#   color <- "#999999";
		#   wc_counter_verbs <- wc_counter_verbs+1;
		# }
		#cat(f[[1]][1], ":", t(l_dp[frames[ii]]), ":", color, "\n", sep="");
		wc_names <- c(wc_names, f[[1]][1]);
		#wc_sizes <- c(wc_sizes, sum(t(l[frames[ii],])));
		wc_sizes <- c(wc_sizes, 200*(t(l_dp[frames[ii]])));
		wc_colors <- c(wc_colors, color);
	}
	
	pdf(paste(filename, "_Wordcloud-", i, "-", nrOfGroups, ".pdf", sep=""), width=8, height=8);
	
	wordcloud(wc_names, wc_sizes, colors=wc_colors, ordered.colors=T, scale=c(2,0.01), rot.per = 0, random.order = F, fixed.asp= T);
	#text(0,0, labels=paste0("Nomen (",wc_counter_nouns,")"), pos=4);
	#text(0.2,0, labels=paste0("Adjektive (",wc_counter_adjectives,")"), pos=4, col="#666666");
	#text(0.4,0, labels=paste0("Verben (",wc_counter_verbs,")"), pos=4, col="#999999");
	#text(0.6,0, labels=paste0("Personalpronomen (",wc_counter_pronouns,")"), pos=4, col="#CCCCCC");
	segments(0,0.03,1,0.03);
	title(main=paste0("Wortwolke Gruppe ",i));
	
	dev.off();
}





# Einzelplot:

pdf(paste(filename, "_LexikonCluster-Einzelbeispiel_", rownames(l[1001,]), ".pdf", sep=""), width=8, height=5);
plot(t(l[1001,]), type="l", main=rownames(l[1001,]), xaxt="n", xlab="Jahre", ylab="Frequenz (normalisiert)");
axis(1, at=seq(from=1, to=61, by=10), labels=seq(from=2000,to=2018,by=10));
dev.off();

# ganz viele....
pdf(paste(filename, "_LexikonCluster-alle_", ".pdf", sep=""), width=8, height=5);
plot(t(l[1,]), type="l", main="alle", xaxt="n", xlab="Jahre", ylab="Frequenz (normalisiert)");
for (ii in 2:2000) { 
  points(t(l[ii,]), type="l") 
}
dev.off()

# Plot GriesDP:
library(ggplot2)
pdf(paste(filename, "_LexikonCluster-GriesDP", ".pdf", sep=""), width=8, height=5);
#plot(l_dp, main="Verteilung Gries DP Variationsmaß")
qplot(l_dp, geom="histogram", main="Histogramm Gries DP Variationsmaß", xlab="Gries DP")
dev.off();

# Beispiele Gries DP

write.table(l_dp[l_dp > 0.3], file=paste(filename, "_GriesDPBeispiele_high", ".txt", sep=""), sep="\t", fileEncoding="UTF8");
write.table(l_dp[l_dp < 0.04], file=paste(filename, "_GriesDPBeispiele_low", ".txt", sep=""), sep="\t", fileEncoding="UTF8");

write.table(order(l_dp[l_dp > 0.3], decreasing = T), file=paste(filename, "_GriesDPBeispiele_highv2", ".txt", sep=""), sep="\t", fileEncoding="UTF8");


