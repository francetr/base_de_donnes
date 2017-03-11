#!/usr/bin/perl
use strict;
use DBI;

sub afficheMoyenneAnimaux{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    my $selectMoyenne = $dbh->prepare("
    SELECT AVG(NbAnimaux) as NbMoyen FROM (SELECT COUNT(*) AS NbAnimaux, Telephone From Animal GROUP BY Telephone) AS table1
    ");
    my $requete = $selectMoyenne->execute();
    
while(my $ref = $selectMoyenne->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Le nombre moyen d'animal par propriétaire est de : $ref->{'nbmoyen'} \n";
    }
    print "\n";
        
    $selectMoyenne->finish();

    $dbh->disconnect();
    
}

afficheMoyenneAnimaux();


# pour question h
#select telephone, count(telephone) from animal group by telephone
