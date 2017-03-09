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
    my $choixType = <>; chomp($choixType);
    print "Entrer un nombre d'annee\n";
    my $choixAnnee = <>; chomp($choixAnnee);

    print "Voici l'ensemble des $choixType qui ont moins de ", $choixAnnee, " an\n" ;
    my $selection=$dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal ='$choixType' AND $anneeActuelle - $choixAnnee < AnneeNaissance");
    my $requete2 = $selection->execute();
    
    while(my $ref = $selection->fetchrow_hashref()){
	print "Id : $ref->{'idanimal'}  Nom : $ref->{'nomanimal'}  Type : $ref->{'typeanimal'}  Couleur : $ref->{'couleur'}  Sexe : $ref->{'sexe'}  Naissance : $ref->{'anneenaissance'} \n";
    }
    
    $selectType->finish();
    $selection->finish();

    $dbh->disconnect();
    
}

afficheSelectionUtilisateur();
