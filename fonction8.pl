#!/usr/bin/perl
use strict;
use DBI;

sub afficheCommuneProprio{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});

my $selectSuperieur = $dbh->prepare(
"
SELECT DISTINCT Commune, NbProprio
FROM (SELECT CodePostal, Count(*) AS NbProprio 
FROM Proprietaire GROUP BY CodePostal) AS Table1, lieu
WHERE Table1.CodePostal=Lieu.CodePostal
"
);
    my $requete = $selectSuperieur->execute();
    while(my $ref = $selectSuperieur->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Commune : $ref->{'commune'}  Nombre Porpriétaire : $ref->{'nbproprio'}\n";
    }
    print "\n";
        
    $selectSuperieur->finish();
    $dbh->disconnect();
    
}

afficheCommuneProprio();
