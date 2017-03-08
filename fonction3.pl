#!/usr/bin/perl
use strict;
use DBI;
#connect

#execute INSERT query
sub ajoutVaccin{

    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});

    print "Voici la liste des animaux enregistrés dans la base\n";
    my $selectAnimaux = $dbh->prepare("SELECT IdAnimal, NomAnimal, TypeAnimal FROM Animal\n");
    my $requete = $selectAnimaux->execute();
    while(my $ref=$selectAnimaux->fetchrow_hashref()){
	print "$ref->{'idanimal'} $ref->{'nomanimal'} $ref->{'typeanimal'} \n"
    }
    
    print "Indiquer l'id de l'animal pour lequel vous voulez ajouter le vaccin\n";
    my $id=<>; chomp($id);
    my $selectVaccin = $dbh->prepare("SELECT Vaccin1, Vaccin2, Vaccin3 FROM Suivie WHERE IdAnimal = '$id'\n");
    my $requete2 = $selectVaccin->execute();
    
    print "Quel vaccin voulez-vous modifier(1, 2 ou 3)?\n";
    my $rep=<>; chomp($rep);
    my $vaccin;
    if ($rep == 1){
	print "Indiquer l'annee du vaccin1\n";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE Suivie SET Vaccin1 = '$vaccin'");
    }
    elsif ($rep == 2){
	print "Indiquer l'annee du vaccin2\n";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE Suivie SET Vaccin2 = '$vaccin'");
    }
    elsif ($rep ==3){
	print "Indiquer l'annee du vaccin3";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE Suivie SET Vaccin2 = '$vaccin'");
    }   

    $selectVaccin->finish();
    $selectAnimaux->finish();
    $dbh->disconnect();
}

ajoutVaccin();
