#!/usr/local/bin/perl -w

# Erstellt am 2. Dezember 2012
# Noah Bubenhofer
# Zaehlt in einer Inputdatei die vorkommenden Wörter und ihre Frequenzen
# und gibt eine Tabelle aus, separiert nach Datensätzen, die über den 
# Tag definiert sind, der angegeben werden kann.

use strict;
use warnings;
use Data::Dumper;
use Statistics::Descriptive;
use Getopt::Long;
use Term::ProgressBar;

# Voreinstellungen:
#my $acceptedPOS = "^(AD|V|NN|K|PD|PI|PP|PR|PW)";
#my $acceptedPOS = "^(AD|NN|PPER|VV|VM)";
#my $acceptedPOS = "^(.+)";
my $acceptedPOS = "^(ADJ|ADP|ADV|NOUN|NUM|PRON|VERB)";
my $minMean = 3;

# define min and max year to be considered:
my $minYear = 2016;
my $maxYear = 2018;


my @inputfiles;

my $outfile;
GetOptions ('out=s' => \$outfile);

if ($ARGV[0]) {
	@inputfiles = @ARGV;
	print STDERR "\nLade Dateien...\n";
} else {
	print STDERR "\nFehlende Parameter zum Programmaufruf: perl semtracks_words.pl --out [Datei] [Korpora]\n";
	exit(1);
}

my %values;
my @years;
my %years;
my %counter;
my $ignoreYearsAbove = 2018;

sub getMovingAve($$\@\@) {
             my ($count, $number, $values, $movingAve) =  @_;
             my $i;
             my $a = 0;
             my $v = 0;
 
             return 0 if ($count == 0);
             return -1 if ($count > $number);
             return -2 if ($count < 2);
 
             $$movingAve[0] = 0;
             $$movingAve[$number - 1] = 0;
             for ($i=0; $i<$count;$i++) {
                         $v = $$values[$i];
                         $a += $v / $count;
                         $$movingAve[$i] = 0;
                         }
             for ($i=$count; $i<$number;$i++) {
                         $v = $$values[$i];
                         $a += $v / $count;
                         $v = $$values[$i - $count - 1];
                         $a -= $v / $count;
                         $$movingAve[$i] = $a;
                         }
             return      0;
             }
 
 1;

foreach (@inputfiles) {
	my $inputfile = $_;
	print STDERR "\nKorpus $inputfile einlesen und zaehlen\n";
	
	open (FH, $inputfile) || die "cannot open \"$inputfile\": $!";
	
	my $totalLines = qx(wc -l $inputfile);
	$totalLines =~ /\s*(\d+)/;
	$totalLines = $1;
	
	my $progress = Term::ProgressBar->new({name => 'Verarbeite Datei', count => $totalLines, remove => 1});
	$progress->minor(0);
 	my $next_update = 0;
 	my $line = 0;
 	
 	my $status = 0;
	
	while (my $fullline = <FH>) {
	
		if ($fullline =~ /<w pos="(.+?)" lemma="(.+?)">(.+?)<\/w>/) {
			$fullline = "$3\t$1\t$2";
		}
		
		if ($fullline =~ /<text .+year="(.+?)"/) {
			if (@years == 0 || $years[(@years-1)] ne $1) {
				$years[(@years)] = $1;
			}
			if ($1 < $minYear || $minYear == 0) { $minYear = $1; }
			if ($1 > $maxYear) { $maxYear = $1; }
		}
		
		if ($fullline =~ /<text_year (\d\d\d\d)/) {
			if (@years == 0 || $years[(@years-1)] ne $1) {
				$years[(@years)] = $1;
			}
			if ($1 < $minYear || $minYear == 0) { $minYear = $1; }
			if ($1 > $maxYear) { $maxYear = $1; }
		}
		
		if ($fullline =~ /<text_date_published (\d\d\d\d)/) {
			my $y = $1;
			if ($y <= $ignoreYearsAbove) {	$status = 1; } else { $status = 0; }
			if (@years == 0 || $years[(@years-1)] ne $y) {
				$years[(@years)] = $y;
			}
			if ($y < $minYear || $minYear == 0) { $minYear = $y; }
			if ($y > $maxYear) { $maxYear = $y; }
		}
		
		if ($fullline =~ /^(.+?)\t(.+?)\t([^\t\n\r]+)\t(.+?)\t(.+?)$/ && $status == 1) {
			my $pos = $2;
			my $lemma = $4;
			if ($pos =~ /$acceptedPOS/) {
				$values{$lemma."_$pos"}{$years[(@years-1)]}++;
				#$values{$lemma}{$years[(@years-1)]}++;
				#print STDERR $pos."\n";
				$years{$years[(@years-1)]}++;
				$counter{"Wörter akzeptiert"}++;
			}
			$counter{"Wörter bearbeitet"}++;
		} elsif ($fullline =~ /^(.+?)\t(.+?)\t([^\t\n\r]+)\t?(.+)?$/ && $status == 1) {
			my $pos = $2;
			my $lemma = $3;
			if ($pos =~ /$acceptedPOS/) {
				$values{$lemma."_$pos"}{$years[(@years-1)]}++;
				#$values{$lemma}{$years[(@years-1)]}++;
				#print STDERR $pos."\n";
				$years{$years[(@years-1)]}++;
				$counter{"Wörter akzeptiert"}++;
			}
			$counter{"Wörter bearbeitet"}++;
		}
		
		$counter{"Zeilen bearbeitet"}++;
		
		$next_update = $progress->update($line)
        if $line >= $next_update;
		
		$line++;
	}
	
	close (FH);
}

# Überprüfen, ob wir jedes Jahr haben:
for (my $i = $minYear; $i <= $maxYear; $i++) {
	if (!$years{$i}) { $years{$i} = 0; }
}

my @valueKeys = keys (%values);
print STDERR "Anzahl Types: ".@valueKeys."\n";

print STDERR Dumper(\%years);

print STDERR "\nTabelle umformatieren und Daten zusammenstellen\n";

#print "Lemma\t".join("\t",sort(keys(%years)))."\n";

open (OUTREL, ">$outfile.rel.csv") || die "Die Datei $outfile kann nicht angelegt werden: $!";
open (OUTABS, ">$outfile.abs.csv") || die "Die Datei $outfile kann nicht angelegt werden: $!";
open (OUTNORM, ">$outfile.norm.csv") || die "Die Datei $outfile kann nicht angelegt werden: $!";

my $nrOfWords = keys(%values);
my $progress = Term::ProgressBar->new({name => 'Umformatieren', count => $nrOfWords, remove => 1});
$progress->minor(0);
my $next_update = 0;
my $line = 0;
 	
foreach my $words (sort(keys(%values))) {
	my @data;
	my @data_abs;
	my @y = sort(keys(%years));
	for (my $i=0;$i<@y;$i++) {
		if ($values{$words}{$y[$i]}) {
			push(@data, ($values{$words}{$y[$i]}/$years{$y[$i]}*1000000));
			push(@data_abs, $values{$words}{$y[$i]});
		} else {
			push(@data, 0);
			push(@data_abs, 0);
		}
	}
	my @mv;
	my @norm;
	my $size = @data;
	#print STDERR "Daten:\n";
	#print STDERR Dumper(@data);
	#getMovingAve(5,$size,@data,@mv);
	@mv = @data;
	@norm = normalize(@mv);
	my $stat = Statistics::Descriptive::Full->new();
	$stat->add_data( @mv ) ;
	#print STDERR "mean: ".$stat->mean()."\n";
	if ($stat->mean() > $minMean) {
		print OUTREL "\"$words\"\t";
		print OUTREL join("\t",@mv)."\n";
		print OUTABS "\"$words\"\t";
		print OUTABS join("\t",@data_abs)."\n";
		print OUTNORM "\"$words\"\t";
		print OUTNORM join("\t",@norm)."\n";
	} else {
		$counter{"Lemma-Mittelwert <= $minMean"}++;
	}
	$next_update = $progress->update($line)
    if $line >= $next_update;
		
	$line++;
}

close OUTREL;
close OUTABS;
close OUTNORM;


sub normalize {
	my @data = @_;
	#print STDERR Dumper(@data);
	my @data_s = sort { $a <=> $b } @data;
	my $minimum = $data_s[0];
	my $maximum = $data_s[(@data_s-1)];
	#print STDERR "norm: $maximum - $minimum\n";
	my $divisor = $maximum - $minimum;
	my @data_n;
	foreach (@data) {
		push(@data_n, ($_ - $minimum) / $divisor);
	}
	return @data_n;
}