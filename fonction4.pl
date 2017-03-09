#!/usr/bin/perl
use strict;
use DBI;

sub afficheChat{

    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});

        print "Voici la liste de tous les chats enregistrés\n";
    my $selectChat = $dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal = 'Chat'");
    my $requete = $selectChat->execute();

    
    while(my $ref= $selectChat->fetchrow_hashref()){
	print "Id : $ref->{'idanimal'}  Nom : $ref->{'nomanimal'}  Couleur : $ref->{'couleur'}  Sexe : $ref->{'sexe'}  Naissance : $ref->{'anneenaissance'}  Sterilise : $ref->{'sterilise'}  Vaccin1 : $ref->{'vaccin1'} Vaccin2 : $ref->{'vaccin2'}  Vaccin3 : $ref->{'vaccin3'}\n";
    }

    $selectChat->finish();
    
    $dbh->disconnect();

}

afficheChat();

