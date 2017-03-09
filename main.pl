#!/usr/bin/perl
use strict;
use DBI;

####### Contient les choix de l'utilisateur
my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});

while (1){
    afficheMenu();
    my $choix = <>;
    if($choix eq 1){
	ajoutAnimal();
    }
    elsif ($choix eq 2){
	modifierAdresse();
    }
    elsif ($choix eq 3){
	ajoutVaccin();
    }
    elsif ($choix eq 4){
	afficheChat();
    }
    elsif ($choix eq 5){
	afficheSelectionUtilisateur();
    }
    elsif ($choix eq 6){
	afficheMoyenneAnimaux();
    }
    elsif ($choix eq 7){
	afficheSuperieurAnimaux();
    }
    elsif ($choix eq 8){
	afficheCommuneProprio();
    }
    elsif ($choix eq 9){
	afficheCommuneAnimaux();
    }
    else{
	print"Arrêt du programme\n";
	last;
    }

}

sub afficheMenu{
    print "------  Menu Principal  ------\n\n";
    print "Taper 1 pour ajouter un nouvel animal\n";
    print "Taper 2 pour modifier l'dresse d'un proprietaire\n";
    print "Taper 3 pour enregistrer un nouveau vaccin\n";
    print "Taper 4 pour afficher tous les chats enregistres\n";
    print "Taper 5 pour afficher les certains animaux ayant X annees\n";
    print "Taper 6 pour afficher le nombre moyen d'animaux par proprietaire\n";
    print "Taper 7 pour afficher les proprietaires qui ont plus de 3 animaux\n";
    print "Taper 8 pour afficher le nombre de proprietaires distincts par commune\n";
    print "Taper 9 pour afficher le nombre total d'animaux par commune chats enregistres\n";
}

sub ajoutAnimal{
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
}

sub modifierAdresse{    
    print "Voici la liste de tous les propriétaires enregistrés\n";
    my $selectProprio = $dbh->prepare("SELECT DISTINCT * FROM Proprietaire");
    my $requete = $selectProprio->execute();
    while(my $ref = $selectProprio->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Nom : $ref->{'nom'}  Prénom : $ref->{'prenom'}  Rue : $ref->{'rue'}  Code Postal:  $ref->{'codepostal'} \n";
    }
    print "\n";
    
    print "Indiquer le nom du propriétaire\n";
    my $nom=<>; chomp($nom);
    print "Indiquer le prenom du propriétaire\n";
    my $prenom =<>; chomp($prenom);
    
    my $verif = $dbh->prepare("SELECT Rue, CodePostal FROM Proprietaire WHERE Nom = '$nom' AND Prenom = '$prenom'");
    my $requete2 = $verif->execute();
    
    print "Indiquer la nouvelle rue de $prenom $nom\n";
    my $newRue = <>; chomp($newRue);
    print "Indiquer le nouveau code postal de $prenom $nom\n";
    my $newCodePostal = <>; chomp($newCodePostal);
    my $requete3 = $dbh->do("UPDATE Proprietaire SET Rue = '$newRue', CodePostal ='$newCodePostal' WHERE Nom = '$nom' AND Prenom = '$prenom'");

    print"Modification effectuee\n";

    $selectProprio->finish();
    $verif->finish();
}


sub ajoutVaccin{
    print "Voici la liste des animaux enregistrés dans la base\n";
    my $selectAnimaux = $dbh->prepare("SELECT IdAnimal, NomAnimal, TypeAnimal FROM Animal\n");
    my $requete = $selectAnimaux->execute();
    while(my $ref=$selectAnimaux->fetchrow_hashref()){
	print "$ref->{'idanimal'} $ref->{'nomanimal'} $ref->{'typeanimal'} \n"
    }
    
    print "Indiquer l'id de l'animal pour lequel vous voulez ajouter le vaccin\n";
    my $id=<>; chomp($id);
    my $selectVaccin = $dbh->prepare("SELECT Vaccin1, Vaccin2, Vaccin3 FROM Suivie WHERE IdAnimal = '$id'\n");
    my $requete2 = $selectVaccin->execute();
    
    print "Quel vaccin voulez-vous modifier(1, 2 ou 3)?\n";
    my $rep=<>; chomp($rep);
    my $vaccin;
    if ($rep eq 1){
	print "Indiquer l'annee du vaccin1\n";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE Suivie SET Vaccin1 = '$vaccin'");
    }
    elsif ($rep eq 2){
	print "Indiquer l'annee du vaccin2\n";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE Suivie SET Vaccin2 = '$vaccin'");
    }
    elsif ($rep eq3){
	print "Indiquer l'annee du vaccin3";
	$vaccin = <>; chomp($vaccin);
	my $requete2 = $dbh->do("UPDATE Suivie SET Vaccin2 = '$vaccin'");
    }   

    $selectVaccin->finish();
    $selectAnimaux->finish();
}


sub afficheChat{
    print "Voici la liste de tous les chats enregistrés\n";
    my $selectChat = $dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal = 'Chat'");
    my $requete = $selectChat->execute();

    
    while(my $ref= $selectChat->fetchrow_hashref()){
	print "Id : $ref->{'idanimal'}  Nom : $ref->{'nomanimal'}  Couleur : $ref->{'couleur'}  Sexe : $ref->{'sexe'}  Naissance : $ref->{'anneenaissance'}  Sterilise : $ref->{'sterilise'}  Vaccin1 : $ref->{'vaccin1'} Vaccin2 : $ref->{'vaccin2'}  Vaccin3 : $ref->{'vaccin3'}\n";
    }

    $selectChat->finish();
}



sub afficheSelectionUtilisateur{
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
}


sub afficheMoyenneAnimaux{
    my $selectMoyenne = $dbh->prepare("
SELECT(NbAnimaux/NbProprio) AS NbMoyen 
FROM (SELECT COUNT(*) AS NbProprio FROM Proprietaire) AS table1,
(SELECT COUNT(*) AS NbAnimaux FROM Animal) AS table2
    ");
    my $requete = $selectMoyenne->execute();
    
while(my $ref = $selectMoyenne->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Le nombre moyen d'animal par propriétaire est de : $ref->{'nbmoyen'} \n";
    }
    print "\n";
        
    $selectMoyenne->finish();
}


sub afficheSuperieurAnimaux{
    print "Voici les propriétaires qui ont plus de 3 animaux\n";
    my $selectSuperieur = $dbh->prepare("
SELECT nom, prenom
FROM(SELECT telephone FROM Animal
GROUP BY telephone
HAVING COUNT(*) > 3
) AS table1,
(SELECT DISTINCT nom, prenom, telephone
FROM Proprietaire
GROUP BY nom, prenom, telephone
) AS table2
WHERE table1.telephone=table2.telephone
    ");
    my $requete = $selectSuperieur->execute();
    while(my $ref = $selectSuperieur->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "$ref->{'prenom'} $ref->{'nom'}\n";
    }
    print "\n";
        
    $selectSuperieur->finish();
}


sub afficheCommuneProprio{
    my $selectSuperieur = $dbh->prepare(
"
SELECT DISTINCT Commune, NbProprio
FROM (SELECT CodePostal, Count(*) AS NbProprio 
FROM Proprietaire GROUP BY CodePostal) AS Table1, lieu
WHERE Table1.CodePostal=Lieu.CodePostal
"
);
    my $requete = $selectSuperieur->execute();
    while(my $ref = $selectSuperieur->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Commune : $ref->{'commune'}  Nombre Porpriétaire : $ref->{'nbproprio'}\n";
    }
    print "\n";
        
    $selectSuperieur->finish();
    $dbh->disconnect();
    
}


sub afficheCommuneAnimaux{
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
}

$dbh->disconnect();


