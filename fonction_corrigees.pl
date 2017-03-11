#!/usr/bin/perl
use strict;
use warnings;
use DBI;

sub ajoutNaissance{
    print "Entrer la date de naissance de l'animal\n";
    my $anneeNaissance = <>; chomp($anneeNaissance);
    while($anneeNaissance =~/\D/ && $anneeNaissance !~/^19\d{2}$/ ||  $anneeNaissance !~/^20\d{2}$/ ){
	print "Entrer la date de naissance de l'animal\n";
	$anneeNaissance = <>; chomp($anneeNaissance);	
    }
    return $anneeNaissance;
}
ajoutNaissance;


sub ajoutVaccin1{
    my($an) = @_;
    print "Indiquer l'année ou l'animal à reçu le vaccin1 (0 sinon)\n";
    my $vaccin1 = <>; chomp($vaccin1);
    while($vaccin1 =~/\D/ || $vaccin1 =~/^[^0]+/ && length($vaccin1) != $an && $vaccin1<$an ){
	print "Indiquer l'année ou l'animal à reçu le vaccin1 (0 sinon)\n";
	$vaccin1 = <>; chomp($vaccin1);
    }
    return $vaccin1;
}


sub ajoutVaccin2{
    my($an) = @_;
    print "Indiquer l'année ou l'animal à reçu le vaccin2 (0 sinon)\n";
    my $vaccin2 = <>; chomp($vaccin2);
    while($vaccin2 =~/\D/ || $vaccin2 =~/^[^0]+/ && length($vaccin2) != $an && $vaccin2<$an ){
	print "Indiquer l'année ou l'animal à reçu le vaccin2 (0 sinon)\n";
	$vaccin2 = <>; chomp($vaccin2);
    }
    return $vaccin2;
}

sub ajoutVaccin3{
    my($an) = @_;
    print "Indiquer l'année ou l'animal à reçu le vaccin3 (0 sinon)\n";
    my $vaccin3 = <>; chomp($vaccin3);
    while($vaccin3 =~/\D/ || $vaccin3 =~/^[^0]+/ && length($vaccin3) != $an && $vaccin3<$an ){
	print "Indiquer l'année ou l'animal à reçu le vaccin3 (0 sinon)\n";
	$vaccin3 = <>; chomp($vaccin3);
    }
    return $vaccin3;
}

sub ajoutTelephone{
    print "Indiquer le numéros de téléphone du propriétaire de l'animal (5 chiffres)\n";
    my $telephone = <>; chomp($telephone);
    while($telephone =~/\D/ || $telephone !~/^\d{5}$/ ){
	print "Indiquer le numéros de téléphone du propriétaire de l'animal (5 chiffres)\n";
	$telephone = <>; chomp($telephone);
    }
    return $telephone;
}

sub ajoutCodePostal{
    print "Entrer le numéros de code postal du propriétaire de l'animal\n";
    my $codePostal = <>; chomp($codePostal);
    while($codePostal =~/\D/ || $codePostal !~/^\d{5,6}$/){
	print "Entrer le numéros de code postal du propriétaire de l'animal\n";
	$codePostal = <>; chomp($codePostal);	
    }
    return $codePostal;
}

sub ajoutNbHabitantsCommune{
    print "Entrer le nombre d'habitants de la commune du propriétaire de l'animal\n";
    my $nbHabitantsCommune = <>; chomp($nbHabitantsCommune);
    while($nbHabitantsCommune =~/\D/ || $nbHabitantsCommune<=0){
	print "Entrer le nombre d'habitants de la commune du propriétaire de l'animal\n";
	$nbHabitantsCommune = <>; chomp($nbHabitantsCommune);	
    }
    return $nbHabitantsCommune;
}
