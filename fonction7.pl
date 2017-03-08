#!/usr/bin/perl
use strict;
use DBI;

sub afficheSuperieurAnimaux{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    print "Voici les propriétaires qui ont plus de 3 animaux\n";
    my $selectSuperieur = $dbh->prepare("
					SELECT nom, prenom
					FROM(SELECT telephone FROM Animal
					GROUP BY telephone
					HAVING COUNT(*) > 3
					) AS table1,
					(SELECT DISTINCT nom, prenom, telephone
					FROM Proprietaire
					GROUP BY nom, prenom, telephone
					) AS table2
					WHERE table1.telephone=table2.telephone
					");
    my $requete = $selectSuperieur->execute();
    while(my $ref = $selectSuperieur->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "$ref->{'prenom'} $ref->{'nom'}\n";
    }
    print "\n";
        
    $selectSuperieur->finish();
    $dbh->disconnect();
    
}

afficheSuperieurAnimaux();
