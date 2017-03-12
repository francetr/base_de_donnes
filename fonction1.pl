#!/usr/bin/perl
use strict;
use warnings;
use DBI;

sub ajoutAnimal{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});

    my $idAnimal = ajoutId();
    my $nomAnimal = ajoutNomAnimal();
    my $type = ajoutType();
    my $couleur = ajoutCouleur();
    my $sexe = ajoutSexe();
    my $sterilise = ajoutSterilise();
    my $anneeNaissance = ajoutNaissance();
    my $vaccin1 = ajoutVaccin1($anneeNaissance) ;
    my $vaccin2 = ajoutVaccin2($anneeNaissance);
    my $vaccin3 = ajoutVaccin3($anneeNaissance);
    
    my $telephone = ajoutTelephone();
    my $nom;
    my $prenom;
    my $rue;
    my $codePostal;
    my $commune;
    my $nbHabitantsCommune;
    my $codeDepartement;
    
     
    my $verifTel = $dbh->prepare("SELECT EXISTS (SELECT Nom, Prenom FROM Proprietaire WHERE Telephone=$telephone) AS TelExiste");  #requête pour vois si tel dans BD
    my $requte = $verifTel->execute();
    my $tmp;
    while(my $ref= $verifTel->fetchrow_hashref()){
	$tmp = $ref->{'telexiste'}; # tmp = 1 si vrai et 0 si faux
    }

    ###TELEPHONE EXISTE DEJA DANS BASE DE DONNEES#####
    if ($tmp == 1){
	my $selectInfosProprio = $dbh->prepare("SELECT * FROM Proprietaire, Lieu WHERE Telephone=$telephone AND Proprietaire.CodePostal=Lieu.CodePostal");
	my $requete2=$selectInfosProprio->execute();
	while(my $ref= $selectInfosProprio->fetchrow_hashref()){
	    $nom = $ref->{'nom'};
	    $prenom = $ref->{'prenom'};
	    $rue = $ref->{'rue'};
	    $codePostal = $ref->{'codepostal'};
	    $commune = $ref->{'commune'};
	    $nbHabitantsCommune = $ref->{'nbhabitantscommune'};
	    $codeDepartement = $ref->{'codedepartement'};	    
	}
	$dbh ->do("INSERT INTO proprietaire VALUES ($telephone, '$nom', '$prenom', '$rue', $codePostal)") ;   #insere nouvelles valeurs dans proprietaire
	$dbh ->do("INSERT INTO lieu VALUES ($codePostal, '$commune', $nbHabitantsCommune, $codeDepartement)") ; # insere nouvelles valeurs dans lieu
	$dbh ->do("INSERT INTO animal VALUES ($idAnimal, '$nomAnimal', '$type', '$sexe', '$couleur','$sterilise',$anneeNaissance, $telephone)") ; #insere nouvelles valeurs dans Animal	
	$dbh ->do("INSERT INTO suivie VALUES ($idAnimal, $vaccin1, $vaccin2, $vaccin3)") ;     #insere nouvelles valeurs dans suivie	
    }

    ### PAS DE TELEPHONE POPRIETAIRE DANS BASE DE DONNEES ######
    else{
	$nom = ajoutNom();
	$prenom = ajoutPrenom();
	$rue = ajoutRue();
	$codePostal = ajoutCodePostal();
	
	my $tmp2;
	my $verifCp = $dbh->prepare("SELECT EXISTS (SELECT * FROM Lieu, Proprietaire WHERE Lieu.CodePostal =$codePostal) As CpExiste");
	my $requte3=$verifCp->execute();
	while(my $ref2 = $verifCp->fetchrow_hashref()){
	    $tmp2= $ref2->{'cpexiste'};
	}
	
	#### CODE POSTAL EXISTE DANS BASE DE DONNEES ######
	if($tmp2 == 1)
	{
	    my $selectCp = $dbh->prepare("SELECT commune,nbhabitantscommune, codedepartement FROM Proprietaire, Lieu WHERE Telephone=$telephone AND Proprietaire.CodePostal=Lieu.CodePostal");
	    my $requete2=$selectCp->execute();
	    while(my $ref= $selectCp->fetchrow_hashref()){
		$commune = $ref->{'commune'};
		$nbHabitantsCommune = $ref->{'nbhabitantscommune'};
		$codeDepartement = $ref->{'codedepartement'};
	    }
	    $selectCp->finish;

	    $dbh ->do("INSERT INTO proprietaire VALUES ($telephone, '$nom', '$prenom', '$rue', $codePostal))") ;  # insere nouvelles valeurs dans proprietaire
	    $dbh ->do("INSERT INTO lieu VALUES ($codePostal, '$commune', $nbHabitantsCommune, $codeDepartement)") ;# insere nouvelles valeurs dans lieu
	    $dbh ->do("INSERT INTO animal VALUES ($idAnimal, '$nomAnimal', '$type', '$sexe', '$couleur','$sterilise',$anneeNaissance, $telephone)") ;# insere nouvelles valeurs dans Animal
	    $dbh ->do("INSERT INTO suivie VALUES ($idAnimal, $vaccin1, $vaccin2, $vaccin3)") ;     #insere nouvelles valeurs dans suivie
	}
	
	####CODE POSTAL PAS DANS BASE DE DONNEES ######
	else{
	    $commune = ajoutCommune();
	    $nbHabitantsCommune = ajoutNbHabitantsCommune();
	    $codeDepartement = ajoutCodeDepartement($codePostal); 
	    
	    $dbh ->do("INSERT INTO proprietaire VALUES ($telephone, '$nom', '$prenom', '$rue', $codePostal)") ;   #insere nouvelles valeurs dans proprietaire
	    $dbh ->do("INSERT INTO lieu VALUES ($codePostal, '$commune', $nbHabitantsCommune, $codeDepartement)") ;# insere nouvelles valeurs dans lieu
	    $dbh ->do("INSERT INTO animal VALUES ($idAnimal, '$nomAnimal', '$type', '$sexe', '$couleur','$sterilise',$anneeNaissance, $telephone)") ; #insere nouvelles valeurs dans Animal	
	    $dbh ->do("INSERT INTO suivie VALUES ($idAnimal, $vaccin1, $vaccin2, $vaccin3)") ;    #insere nouvelles valeurs dans suivie	    
	}
	
	$verifCp->finish; #finit requête cpexiste
    }
    $verifTel->finish;
    $dbh->disconnect();
}

#### AJOUT DES ATTRIBUTS #####
sub ajoutId{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});

    my $selectId=$dbh->prepare("SELECT Max(IdAnimal) FROM Animal");
    my $requete1=$selectId->execute();
    my $idAnimal;    
    while(my $ref = $selectId->fetchrow_hashref()){
	    $idAnimal= $ref->{'max'}+1;
    }
    $dbh->disconnect();
    return $idAnimal;

}
sub ajoutNomAnimal{
    print "Entrer le nom de l'animal (NA si aucun)\n";
    my $nomAnimal = ucfirst(lc(<>));chomp($nomAnimal); # mettre NA
    if ($nomAnimal=~/Na/ ){
	$nomAnimal = uc($nomAnimal);
    }
    while($nomAnimal =~/\d/){
	print "Entrer le nom de l'animal (NA sinon)\n";
	$nomAnimal = ucfirst(lc(<>)); chomp($nomAnimal);	
    }
    return $nomAnimal;
}

sub ajoutType{
    print "Entrer le type de l'animal\n";
    my $type = ucfirst(lc(<>));chomp($type);
    while($type =~/\d/){
	print "Entrer le type de l'animal\n";
	$type = ucfirst(lc(<>)); chomp($type);	
    }
    return $type;
}

sub ajoutCouleur{
    print "Entrer la couleur de l'animal\n";
    my $couleur = ucfirst(lc(<>));chomp($couleur);
    while($couleur =~/\d/){
	print "Entrer le couleur de l'animal\n";
	$couleur = ucfirst(lc(<>)); chomp($couleur);	
    }
    return $couleur;
}

sub ajoutSexe{
    print "Entrer le sexe de l'animal (M ou F)\n";
    my $sexe = ucfirst(lc(<>)); chomp($sexe);
    while($sexe =~/\d/ && $sexe =~/[^MF]/){
	print "Entrer le sexe de l'animal (M ou F)\n";
	$sexe = ucfirst(lc(<>)); chomp($sexe);	
    }
    return $sexe; 
}

sub ajoutSterilise{
    print "Indiquer si l'animal a été stérilisé ou non (Oui ou Non)\n";
    my $sterilise = ucfirst(lc(<>));chomp($sterilise); 

    while($sterilise !~/^[^O][^u][^i]$/ & $sterilise !~/^[^N][^o][^n]$/){
	print "Indiquer si l'animal a été stérilisé ou non (Oui ou Non)\n";
	$sterilise = ucfirst(lc(<>)); chomp($sterilise);	
    }
    return $sterilise;
}

sub ajoutNaissance{
    print "Entrer la date de naissance de l'animal\n";
    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;

    my $anneeNaissance = <>; chomp($anneeNaissance);
    while($anneeNaissance =~/\D/ || $anneeNaissance gt $anneeActuelle || $anneeNaissance !~/^20\d{2}$/ && $anneeNaissance !~/^19\d{2}$/)
{
	print "Entrer la date de naissance de l'animal\n";
	$anneeNaissance = <>; chomp($anneeNaissance);	
    }
    return $anneeNaissance;
}

sub ajoutVaccin1{
    my($an) = @_;
    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;    
    print "Indiquer l'année ou l'animal à reçu le vaccin1 (0 sinon)\n";
    my $vaccin1 = <>; chomp($vaccin1);
    while($vaccin1 =~/\D/ || $vaccin1 =~/^[^0]+/ && (length($vaccin1) ne length($an) || $vaccin1 lt $an || $vaccin1 gt $anneeActuelle)
){
	print "Indiquer l'année ou l'animal à reçu le vaccin1 (0 sinon)\n";
	$vaccin1 = <>; chomp($vaccin1);
    }
    return $vaccin1;
}

sub ajoutVaccin2{
    my($an) = @_;
    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;  
    print "Indiquer l'année ou l'animal à reçu le vaccin2 (0 sinon)\n";
    my $vaccin2 = <>; chomp($vaccin2);
    while($vaccin2 =~/\D/ || $vaccin2 =~/^[^0]+/ && (length($vaccin2) ne length($an) || $vaccin2 lt $an || $vaccin2 gt $anneeActuelle)
){
	print "Indiquer l'année ou l'animal à reçu le vaccin2 (0 sinon)\n";
	$vaccin2 = <>; chomp($vaccin2);
    }
    return $vaccin2;
}

sub ajoutVaccin3{
    my($an) = @_;
    my $t = Time::Piece->new();
    my $anneeActuelle=$t->year;  
    print "Indiquer l'année ou l'animal à reçu le vaccin3 (0 sinon)\n";
    my $vaccin3 = <>; chomp($vaccin3);
    while($vaccin3 =~/\D/ || $vaccin3 =~/^[^0]+/ && (length($vaccin3) ne length($an) || $vaccin3 lt $an || $vaccin3 gt $anneeActuelle)
){
	print "Indiquer l'année ou l'animal à reçu le vaccin3 (0 sinon)\n";
	$vaccin3 = <>; chomp($vaccin3);
    }
    return $vaccin3;
}

sub ajoutTelephone{
    print "Indiquer le numéros de téléphone du propriétaire de l'animal (5 chiffres)\n";
    my $telephone = <>; chomp($telephone);
    while($telephone =~/\D/ || $telephone =~/\D/ !~/^\d{5}$/ ){
	print "Indiquer le numéros de téléphone du propriétaire de l'animal (5 chiffres)\n";
	$telephone = <>; chomp($telephone);
    }
    return $telephone;
}

sub ajoutNom{
    print "Entrer le nom du propriétaire\n";
    my $nom = ucfirst(lc(<>));chomp($nom);
    while($nom =~/\d/){
	print "Entrer le nom du propriétaire\n";
	$nom = ucfirst(lc(<>)); chomp($nom);	
    }
    return $nom;
}

sub ajoutPrenom{
    print "Entrer le prénom du propriétaire\n";
    my $prenom = ucfirst(lc(<>));chomp($prenom);
    while($prenom =~/\d/){
	print "Entrer le prénom du propriétaire\n";
	$prenom = ucfirst(lc(<>)); chomp($prenom);	
    }
    return $prenom;
}

sub ajoutRue{
    print "Entrer le nom de la rue où le propriétaire habite\n";
    my $rue = ucfirst(lc(<>));chomp($rue);
    while($rue =~/\d/){
	print "Entrer le nom de la rue où le propriétaire habite\n";
	$rue = ucfirst(lc(<>)); chomp($rue);	
    }
    return $rue;
}

sub ajoutCodePostal{
    print "Entrer le numéros de code postal du propriétaire de l'animal\n";
    my $codePostal = <>; chomp($codePostal);
    while($codePostal =~/\D/ || $codePostal !~/^\d{5,6}$/){
	print "Entrer le numéros de code postal du propriétaire de l'animal\n";
	$codePostal = <>; chomp($codePostal);	
    }
    return $codePostal;
}

sub ajoutCommune{
    print "Entrer le nom de la commune où le propriétaire habite\n";
    my $commune = ucfirst(lc(<>));chomp($commune);
    while($commune =~/\d/){
	print "Entrer le nom de la commune où le propriétaire habite\n";
	$commune = ucfirst(lc(<>)); chomp($commune);	
    }
    return $commune;
}


sub ajoutNbHabitantsCommune{
    print "Entrer le nombre d'habitants de la commune du propriétaire de l'animal\n";
    my $nbHabitantsCommune = <>; chomp($nbHabitantsCommune);
    while($nbHabitantsCommune =~/\D/ || $nbHabitantsCommune le 0){
	print "Entrer le nombre d'habitants de la commune du propriétaire de l'animal\n";
	$nbHabitantsCommune = <>; chomp($nbHabitantsCommune);	
    }
    return $nbHabitantsCommune;
}

sub ajoutCodeDepartement{
    my ($cp)=@_;
    my $codeDepartement;
    if ($cp=~/^(\d{2})(\d{3})$/){
	$codeDepartement = $1;
    }
    elsif($cp=~/^(\d{3})(\d{3})$/){
	$codeDepartement = $1;
    }
    return $codeDepartement;
}
