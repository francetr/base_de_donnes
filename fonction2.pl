#!/usr/bin/perl
use strict;
use DBI;
#connect

#execute INSERT query
sub modifAdresse{

    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    print "Voici la liste de tous les proprietaire enregistres\n";
    my $requete = $dbh->prepare("SELECT DISTINCT * FROM Proprietaire");
    my $select = $requete->execute();
    while(my $ref = $requete->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "$ref->{'nom'} $ref->{'prenom'} $ref->{'rue'} $ref->{'codepostal'} \n";
    }
    print "\n";
    
    print "Indiquer le nom du propriétaire\n";
    my $nom=<>; chomp($nom);
    print "Indiquer le prenom du propriétaire\n";
    my $prenom =<>; chomp($prenom);
    my $verif = $dbh->prepare("SELECT Rue, CodePostal FROM Proprietaire WHERE Nom = '$nom' AND Prenom = '$prenom'");
    my $select2 = $verif->execute();

    
    print "Indiquer la nouvelle rue de $prenom $nom\n";
    my $newRue = <>; chomp($newRue);
    print "Indiquer le nouveau code postal de $prenom $nom\n";
    my $newCodePostal = <>; chomp($newCodePostal);
    my $requete2 = $dbh->do("UPDATE Proprietaire SET Rue = '$newRue', CodePostal ='$newCodePostal' WHERE Nom = '$nom' AND Prenom = '$prenom'");

    print"Modification effectuee\n";

    $requete->finish();
    $verif->finish();
    $dbh->disconnect();
    
}

modifAdresse();
