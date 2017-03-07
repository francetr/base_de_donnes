
#!/usr/bin/perl
use strict;
use DBI;
#connect
my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
#execute INSERT query
sub ajoutAnimal{
    print "Entrer l' id de l'animal\n";
    my $id=<>; chomp($id);
    print "Entrer le nom de l'animal $id\n";
    my $nom=<>; chomp($nom);
    print "Entrer le type de l'animal $id\n";
    my $type=<>; chomp($type);
    print "Entrer la couleur de l'animal avec id $id\n";
    my $couleur=<>; chomp($couleur);
    print "Entrer le sexe de l'animal $id (M ou F)\n";
    my $sexe=<>; chomp($sexe);
    print "Indiquer si l'animal $id a été sterilise ou non (oui ou non)\n";
    my $sterilise=<>; chomp($sterilise);
    print "Indiquer l'annee de naissance de $id\n";
    my $anneeNaissance=<>; chomp($anneeNaissance);
    print "Indiquer l'annee ou l'animal $id a recu le vaccin1\n";
    my $vaccin1=<>; chomp($vaccin1);
    print "Indiquer l'annee ou l'animal $id a recu le vaccin2\n";
    my $vaccin2=<>; chomp($vaccin2);
    print "Indiquer l'annee ou l'animal $id a recu le vaccin3\n";
    my $vaccin3=<>; chomp($vaccin3);
    my $requete = $dbh->do("INSERT INTO Animal VALUES($id,'$nom','$type','$couleur','$sexe',$anneeNaissance)");
    my $requete2 = $dbh->do("INSERT INTO Suivie VALUES ($id,'$sterilise','$vaccin1','$vaccin2','$vaccin3')"); 
}

ajoutAnimal();

$dbh->disconnect();
