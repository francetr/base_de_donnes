#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;

my $file = "Animaux.csv";
open my $fh, "<::encoding(utf-8)", $file or die "$file: $!";

my $csv = Text::CSV->new ({
    binary    => 1, # Allow special character. Always set this
    auto_diag => 1, # Report irregularities immediately
			  });
my @donnees;
while (my $row = $csv->getline ($fh)) {
    print "@$row\n";
    my $valeur=split(@$row, ",");
    push(@donnees, $valeur);
    
}

print "@donnees[0]\n";
close $fh;
