#!/usr/bin/perl
use strict;
use DBI;

sub afficheCommuneAnimaux{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    my $vueanimal = $dbh->do("CREATE VIEW vueanimal AS SELECT COUNT(*) AS nbanimaux,telephone FROM animal GROUP BY telephone");
    
    my $vueproprio = $dbh->do("CREATE VIEW vueproprio AS SELECT SUM(nbanimaux) AS nbanimauxcommune, codepostal FROM vueanimal, proprietaire WHERE vueanimal.telephone = proprietaire.telephone GROUP BY codepostal");
    
    
    my $selectAnimaux = $dbh->prepare("select nbanimauxcommune, commune from vueproprio, lieu where lieu.codepostal=vueproprio.codepostal");
    
    my $requete = $selectAnimaux->execute();
    
    print"Voici le nombre total d'animaux par commune\n";
    while(my $ref = $selectAnimaux->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Commune : $ref->{'commune'}  Nombre Animaux : $ref->{'nbanimauxcommune'}\n";
    }
    print "\n";
    
    $dbh->do("drop view vueproprio CASCADE");
    $dbh->do("drop view vueanimal CASCADE");

    $selectAnimaux->finish();
    $dbh->disconnect();
}

afficheCommuneAnimaux();
