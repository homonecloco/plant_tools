#!/bin/env perl
use strict;
use warnings;

# add genes to a GFF file containing transcript, exon and CDS features
# by Bruno Contreras Moreira EMBL-EBI 2020

if(!$ARGV[0]){ die "# usage: $0 <GFF>\n" }

my ($fparent, $tparent, $tname, $fname, $feature, $gene, $transcript);

open(GFF,"<",$ARGV[0]) || die "# ERROR: cannot read $ARGV[0]\n";
while(<GFF>){

#CM012293.1      FilteringA2     transcript      9756    14465   .       +       .       gene_id "QL01p000012"; transcript_id "QL01p000012";
#CM012293.1      FilteringA2     exon    9756    10164   .       +       .       gene_id "QL01p000012"; transcript_id "QL01p000012"; exon_number "1"; exon_id "QL01p000012.1";
#CM012293.1      FilteringA2     exon    10872   10973   .       +       .       gene_id "QL01p000012"; transcript_id "QL01p000012"; exon_number "2"; exon_id "QL01p000012.2";
#CM012293.1      FilteringA2     CDS     10913   10973   .       +       0       gene_id "QL01p000012"; transcript_id "QL01p000012"; exon_number "2"; exon_id "QL01p000012.2";

	my @col = split(/\t/,$_);
	
	if(defined($col[2]) && $col[2] eq 'transcript'){

		# copy transcript as a seed for gene
		$gene = $_;
		$gene =~ s/\ttranscript\t/\tgene\t/;
		$gene =~ s/transcript_id "[^"]+";//;
		if($gene =~ /gene_id "([^"]+)"/){ $tparent = $1 }
		print $gene;
		
		# now take care of transcript
		$transcript = $_;
		if($col[8] =~ m/transcript_id "([^"]+)"/){

			$tname = $1 . ':mrna';
			$fparent = $tname;
			$transcript =~ s/transcript_id "[^"]+";/transcript_id "$tname"; parent "$tparent";/;
			print $transcript;
		}
	} elsif(defined($col[2]) && ($col[2] eq 'exon' || $col[2] eq 'CDS')){
		
		$feature = $_;
	
		$feature =~ s/transcript_id "[^"]+";/transcript_id "$tname"; parent "$fparent";/;	
		print $feature;
		
	} else {
		print;
	}

}
close(GFF);