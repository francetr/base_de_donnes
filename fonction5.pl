
#!/usr/bin/perl
use strict;
use DBI;
#connect

#execute INSERT query
sub afficheSelectionUtilisateur{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    print"Quelle est l'annee actuelle?\n";
    my $anneeActuelle=<>;
    print "Voici la liste de tous les types d'animaux enregistres\n";
    my $requete = $dbh->prepare("SELECT DISTINCT TypeAnimal From Animal");
    my $select = $requete->execute();
    while(my $ref = $requete->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "$ref->{'typeanimal'}\n";
    }
    print "\n";
    
    
    print "Choisissez un type d'animal\n";
    my $choixType = <>; chomp($choixType);
    print "Entrer un nombre d'annee\n";
    my $choixAnnee = <>; chomp($choixAnnee);
    
    my $requete2=$dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal ='$choixType' AND $anneeActuelle - $choixAnnee < AnneeNaissance");
    my $select2 = $requete2->execute();
    
    while(my $ref = $requete2->fetchrow_hashref()){
	print "$ref->{'idanimal'} $ref->{'nomanimal'} $ref->{'typeanimal'} $ref->{'couleur'} $ref->{'sexe'} $ref->{'anneenaissance'} \n";
    }
    
    $requete->finish();
    $requete2->finish();
    $dbh->disconnect();
    
}

afficheSelectionUtilisateur();


