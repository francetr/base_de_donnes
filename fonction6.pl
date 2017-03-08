#!/usr/bin/perl
use strict;
use DBI;

sub afficheMoyenneAnimaux{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    print "Voici le nombre moyen d'animaux par proprietaire\n";
    my $selectMoyenne = $dbh->prepare("SELECT nom, prenom, AVG(telephone) AS nombremoyen FROM Animal, Proprietaire WHERE animal.telephone=proprietaire.telephone");
    my $requete = $selectMoyenne->execute();
    while(my $ref = $selectMoyenne->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "$ref->{'prenom'} $ref->{'nom'} $ref->{'nombremoyen'} \n";
    }
    print "\n";
        
    $selectMoyenne->finish();
    $dbh->disconnect();
    
}

afficheMoyenneAnimaux();
