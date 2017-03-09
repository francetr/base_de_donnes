#!/usr/bin/perl
use strict;
use DBI;

sub afficheCommuneAnimaux{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    my $vueanimal = $dbh->do("CREATE VIEW vueanimal AS SELECT COUNT(*) AS nbanimaux,telephone FROM animal GROUP BY telephone");
    
    my $vueproprio = $dbh->do("CREATE VIEW vueproprio AS SELECT SUM(nbanimaux) AS nbanimalcommune, codepostal FROM vueanimal, proprietaire WHERE vueanimal.telephone = proprietaire.telephone GROUP BY codepostal");
    
    
    my $selectAnimaux = $dbh->prepare("select distinct nbanimalcommune, commune from vueproprio, lieu where lieu.codepostal=vueproprietaire.codepostal");
    
    my $requete = $selectAnimaux->execute();
    
    print"Voici le nombre total d'animaux par commune";
    while(my $ref = $selectAnimaux->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Commune : $ref->{'commune'}  Nombre Animaux : $ref->{'nbanimalcommune'}\n";
    }
    print "\n";
    
    $dbh->do(drop view vueproprio);
    $dbh->do(drop view vueanimal);

    $selectAnimaux->finish();

    
    $dbh->disconnect();
    
}

afficheCommuneAnimaux();
