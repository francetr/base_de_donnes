#!/usr/bin/perl
use strict;
use DBI;
#connect
my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
#execute INSERT query
sub ajoutVaccin{
    print "Indiquer l'id de l'animal pour lequel vous voulez ajouter le vaccin\n";
    my $id=<>; chomp($id);
    my $requete = $dbh->do("SELECT Vaccin1, Vaccin2, Vaccin3 FROM Suivie WHERE IdAnimal = '$id'\n");
    print "Quel vaccin voulez-vous modifier(1, 2 ou 3)?\n";
    my $rep=<>; chomp($rep);
    my $vaccin;
    if ($rep == 1){
	print "Indiquer l'annee du vaccin1\n";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE TABLE Suivie SET Vaccin1 = '$vaccin'");
    }

    elsif ($rep == 2){
	print "Indiquer l'annee du vaccin2\n";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE TABLE Suivie SET Vaccin2 = '$vaccin'");
    }
    elsif ($rep ==3){
	print "Indiquer l'annee du vaccin3";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE TABLE Suivie SET Vaccin2 = '$vaccin'");
    }   
}

ajoutVaccin();

$dbh->disconnect();
