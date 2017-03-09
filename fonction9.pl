#!/usr/bin/perl
use strict;
use DBI;

sub afficheCommuneAnimaux{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    my $vueanimal = $dbh->do("create view vueanimal as select count(*) as nbanimaux,telephone from animal group by telephone");

    my $vueproprio = $dbh->do("create view vue proprietaire as select sum(nbanimaux)as nbanimalcommune, codepostal from vueanimal, proprietaire where vueanimal.telephone = proprietaire.telephone group by codepostal");


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
