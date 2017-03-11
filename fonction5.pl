#!/usr/bin/perl
use strict;
use DBI;
use Time::Piece;

sub afficheSelectionUtilisateur{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});

    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;
    print "Voici la liste de tous les types d'animaux enregistres\n";
    my $selectType = $dbh->prepare("SELECT DISTINCT TypeAnimal From Animal");
    my $requete = $selectType->execute();
    while(my $ref = $selectType->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "$ref->{'typeanimal'}\n";
    }
    print "\n";    
    
    print "Choisissez un type d'animal\n";
    my $choixType = ucfirst(lc(<>)); chomp($choixType);
    print "Entrer un nombre d'annee\n";
    my $choixAnnee = <>; chomp($choixAnnee);

    my $tmp;
    my $verifChoix = $dbh->prepare("SELECT EXISTS (SELECT *  FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal ='$choixType' AND $anneeActuelle - $choixAnnee < AnneeNaissance) AS choixExiste");
    my $requete = $verifChoix->execute();
    while(my $ref = $verifChoix->fetchrow_hashref()){
	$tmp = $ref->{'choixexiste'};
    }

    ####### CHOIX DE L'UTILISATEUR EXISTE #########
    if ($tmp == 1){
	my $selection= $dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal ='$choixType' AND $anneeActuelle - $choixAnnee < AnneeNaissance");
	my $requete2 = $selection->execute();
	
	while(my $ref = $selection->fetchrow_hashref()){
	    print "Id : $ref->{'idanimal'}  Nom : $ref->{'nomanimal'}  Type : $ref->{'typeanimal'}  Couleur : $ref->{'couleur'}  Sexe : $ref->{'sexe'}  Naissance : $ref->{'anneenaissance'} \n";
	}
	$selection->finish();
    }

    ####### CHOIX D'UTILISATEUR N'EXISTE PAS ########
    else{
	print "Pas d'animal $choixType agé de moins de $choixAnnee an\n";
    }

    $verifChoix->finish;
    $selectType->finish();

    $dbh->disconnect();
    
}

afficheSelectionUtilisateur();
