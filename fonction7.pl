#!/usr/bin/perl
use strict;
use DBI;

sub afficheSuperieurAnimaux{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    print "Voici les propriétaires qui ont plus de 3 animaux\n";
    my $selectSuperieur = $dbh->prepare("SELECT Nom, Prenom, avg(telephone) AS NombreMoyen From Animal, Proprietaire WHERE (SELECT telephone FROM animal GROUP BY telephone HAVING count(*) > 3)");
    my $requete = $selectSuperieur->execute();
    while(my $ref = $selectSuperieur->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "$ref->{'prenom'} $ref->{'nom'}\n";
    }
    print "\n";
        
    $selectSuperieur->finish();
    $dbh->disconnect();
    
}

afficheSuperieurAnimaux();
