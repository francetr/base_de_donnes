#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Time::Piece;

sub ajoutNaissance{
    print "Entrer la date de naissance de l'animal\n";
    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;

    my $anneeNaissance = <>; chomp($anneeNaissance);
    while($anneeNaissance =~/\D/ || $anneeNaissance gt $anneeActuelle || $anneeNaissance !~/^20\d{2}$/ && $anneeNaissance !~/^19\d{2}$/)
{
	print "Entrer la date de naissance de l'animal\n";
	$anneeNaissance = <>; chomp($anneeNaissance);	
    }
    return $anneeNaissance;
}

sub ajoutVaccin1{
    my($an) = @_;
    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;    
    print "Indiquer l'année ou l'animal à reçu le vaccin1 (0 sinon)\n";
    my $vaccin1 = <>; chomp($vaccin1);
    while($vaccin1 =~/\D/ || $vaccin1 =~/^[^0]+/ && (length($vaccin1) ne length($an) || $vaccin1 lt $an || $vaccin1 gt $anneeActuelle)
){
	print "Indiquer l'année ou l'animal à reçu le vaccin1 (0 sinon)\n";
	$vaccin1 = <>; chomp($vaccin1);
    }
    return $vaccin1;
}

sub ajoutVaccin2{
    my($an) = @_;
    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;  
    print "Indiquer l'année ou l'animal à reçu le vaccin2 (0 sinon)\n";
    my $vaccin2 = <>; chomp($vaccin2);
    while($vaccin2 =~/\D/ || $vaccin2 =~/^[^0]+/ && (length($vaccin2) ne length($an) || $vaccin2 lt $an || $vaccin2 gt $anneeActuelle)
){
	print "Indiquer l'année ou l'animal à reçu le vaccin2 (0 sinon)\n";
	$vaccin2 = <>; chomp($vaccin2);
    }
    return $vaccin2;
}

sub ajoutVaccin3{
    my($an) = @_;
    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;  
    print "Indiquer l'année ou l'animal à reçu le vaccin3 (0 sinon)\n";
    my $vaccin3 = <>; chomp($vaccin3);
    while($vaccin3 =~/\D/ || $vaccin3 =~/^[^0]+/ && (length($vaccin3) ne length($an) || $vaccin3 lt $an || $vaccin3 gt $anneeActuelle)
){
	print "Indiquer l'année ou l'animal à reçu le vaccin3 (0 sinon)\n";
	$vaccin3 = <>; chomp($vaccin3);
    }
    return $vaccin3;
}


sub ajoutCodePostal{
    print "Entrer le numéros de code postal du propriétaire de l'animal\n";
    my $codePostal = <>; chomp($codePostal);
    while($codePostal =~/\D/ || $codePostal !~/^\d{5}$/){
	print "Entrer le numéros de code postal du propriétaire de l'animal\n";
	$codePostal = <>; chomp($codePostal);	
    }
    return $codePostal;
}

sub ajoutNbHabitantsCommune{
    print "Entrer le nombre d'habitants de la commune du propriétaire de l'animal\n";
    my $nbHabitantsCommune = <>; chomp($nbHabitantsCommune);
    while($nbHabitantsCommune =~/\D/ || $nbHabitantsCommune le 0){
	print "Entrer le nombre d'habitants de la commune du propriétaire de l'animal\n";
	$nbHabitantsCommune = <>; chomp($nbHabitantsCommune);	
    }
    return $nbHabitantsCommune;
}

sub ajoutCodeDepartement{
    my ($cp)=@_;
    my $codeDepartement;
    if ($cp=~/^(\d{2})(\d{3})$/){
	$codeDepartement = $1;
    }
    return $codeDepartement;
}
