
#!/usr/bin/perl
use strict;
use DBI;
#connect

sub ajoutAnimal{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    print "Entrer l' id de l'animal\n";
    my $id=<>; chomp($id);
    print "Entrer le nom de l'animal avec l'id $id\n";
    my $nom=<>; chomp($nom);
    print "Entrer le type de l'animal avec l'id $id\n";
    my $type=<>; chomp($type);
    print "Entrer la couleur de l'animal avec l'id $id\n";
    my $couleur=<>; chomp($couleur);
    print "Entrer le sexe de l'animal $id (M ou F)\n";
    my $sexe=<>; chomp($sexe);
    print "Indiquer si l'animal $id a été sterilise ou non (oui ou non)\n";
    my $sterilise=<>; chomp($sterilise);
    print "Indiquer l'annee de naissance de $id\n";
    my $anneeNaissance=<>; chomp($anneeNaissance);
    print "Indiquer l'annee ou l'animal $id a recu le vaccin1 (0 sinon)\n";
    my $vaccin1=<>; chomp($vaccin1);
    print "Indiquer l'annee ou l'animal $id a recu le vaccin2 (0 sinon)\n";
    my $vaccin2=<>; chomp($vaccin2);
    print "Indiquer l'annee ou l'animal $id a recu le vaccin3 (0 sinon)\n";
    my $vaccin3=<>; chomp($vaccin3);

    my $telephone;
    my $nomProprio;
    my $prenomProprio;
    print "Le propriétaire est-il enregistré dans la base?(o/n)\n";
    my $rep2=<>; chomp($rep2);
    
    if ($rep2 eq "o" or $rep2 eq "O"){
	print "Donner le nom du propriétaire de l'animal avec id $id\n";
	$nomProprio=<>; chomp($nomProprio);
	print "Donner le prénom du propriétaire de l'animal avec id $id\n";
	$prenomProprio=<>; chomp($prenomProprio);

	my $selectTel = $dbh->prepare("SELECT DISTINCT Nom, Prenom, Telephone FROM Proprietaire WHERE Nom = '$nomProprio' AND Prenom='$prenomProprio'");
	$telephone = $selectTel->execute();
	while(my $ref= $selectTel->fetchrow_hashref()){
	    print "Nom :  $ref->{'nom'}   Prénom : $ref->{'prenom'}  Téléphone : $ref->{'telephone'}\n";
	    $telephone = $ref->{'telephone'};
	}
	$selectTel->finish();
    }
    
    elsif($rep2 eq "n" or $rep2 eq "N"){
	print "Donner le nom du propriétaire de l'animal avec l'id $id\n";
	$nomProprio=<>; chomp($nomProprio);
	print "Donner le prénom du propriétaire de l'animal avec l'id $id\n";
	$prenomProprio=<>; chomp($prenomProprio);
	print "Donner la rue du propriétaire de l'animal avec l'id $id\n";
	my $rue=<>; chomp($rue);
	print "Donner le Code Postal du propriétaire de l'animal avec id $id\n";
	my $codePostal=<>; chomp($codePostal);
	my $requete3 = $dbh->do("INSERT INTO Proprietaire VALUES ($telephone,$nomProprio,$prenomProprio,$rue,$codePostal)"); 
    }
    
    else{
	;
    }
    print "Indiquer le numéros de téléphone du propriétaire de l'animal a l'$id\n";
    my $telephone=<>; chomp($telephone);
    my $requete = $dbh->do("INSERT INTO Animal VALUES($id,'$nom','$type','$sexe','$couleur','$sterilise',$anneeNaissance,$telephone)");
    my $requete2 = $dbh->do("INSERT INTO Suivie VALUES ($id,$vaccin1,$vaccin2,$vaccin3)");    
    print"Ajout d'animal effectué\n";

    $dbh->disconnect();
}

ajoutAnimal();
