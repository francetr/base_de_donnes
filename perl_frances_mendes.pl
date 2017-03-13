#!usr/bin/perl
use strict;
use warnings;
use DBI;
use Text::CSV_XS;
use Text::CSV;
use Time::Piece;
use HTML::Template;


#declar var
my @IdAnimal;
my @NomAnimal;
my @TypeAnimal;
my @Couleur;
my @Sexe;
my @Sterilise;
my @AnneeNaissance;
my @Vaccin1;
my @Vaccin2;
my @Vaccin3;
my @Telephone;
my @Nom;
my @Prenom;
my @Rue;
my @CodePostal;
my @Commune;
my @NbHabitantsCommune;
my @CodeDepartement;



my $statement;
my @data;
my $htmlvar1;
my $htmlvar2;
my $htmlvar3;



################# Creation des tables, mise a jour, et ajouts des clés #################



sub createTable(){  #Create all the tables, drop if it already exist
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

	# Table Proprietaire
	print "Création de la table : Proprietaire\n";
	my $sql_creation_table_proprietaire = <<"SQL";
	CREATE TABLE Proprietaire (
	  Telephone  INT 	         ,
	  Nom        VARCHAR   ,
	  Prenom	 VARCHAR	         ,
	  Rue	     VARCHAR  ,
	  CodePostal INT             
	)
SQL

	# Table Lieu
	print "Création de la table : Lieu\n";

	my $sql_creation_table_lieu = <<"SQL";
	CREATE TABLE Lieu (
	  CodePostal              INT   	    ,
	  Commune                 VARCHAR       ,
	  NbHabitantsCommune      INT 	        ,
	  CodeDepartement         INT           
	)
SQL

	# Table Animal
	print "Création de la table : Animal\n";
	my $sql_creation_table_animal = <<"SQL";
	CREATE TABLE Animal (
	  IdAnimal       INT 	         ,
	  NomAnimal      VARCHAR           ,
	  TypeAnimal	 VARCHAR 	 ,
	  Sexe	         VARCHAR  ,
	  Couleur        VARCHAR   ,
	  Sterilise  VARCHAR  ,
	  AnneeNaissance INT            ,
	  Telephone      INT             

	)
SQL

	# Table Suivie
	print "Création de la table : Suivie\n";
	my $sql_creation_table_suivie = <<"SQL";
	CREATE TABLE Suivie (
	  IdAnimal   INT 	        ,
	  Vaccin1	 INT	                 ,
	  Vaccin2	 INT	    			 ,
	  Vaccin3    INT     				 
	)
SQL
	my $sql_creation_table_tmpProprietaire = <<"SQL";
	CREATE TABLE tmpProprietaire (
	  Telephone  INT 	    ,
	  Nom        VARCHAR   ,
	  Prenom	 VARCHAR   ,
	  Rue	     VARCHAR  ,
	  CodePostal INT             
	)
SQL
	my $sql_creation_table_tmpLieu = <<"SQL";
	CREATE TABLE tmpLieu (
	  CodePostal              INT   	    ,
	  Commune                 VARCHAR       ,
	  NbHabitantsCommune      INT 	        ,
	  CodeDepartement         INT           
	)
SQL
	#supprime table si existe deja
	$dbh->do("DROP TABLE if exists proprietaire cascade");
	$dbh->do("DROP TABLE if exists lieu cascade");
	$dbh->do("DROP TABLE if exists animal cascade");
	$dbh->do("DROP TABLE if exists suivie cascade");
	$dbh->do("DROP TABLE if exists tmpProprietaire cascade");
	$dbh->do("DROP TABLE if exists tmpLieu cascade");



	# Creation des differentes tables
	$dbh->do($sql_creation_table_proprietaire)     or die "Echec lors de la creation de la table Proprietaire\n\n";
	$dbh->do($sql_creation_table_lieu)             or die "Echec lors de la creation de la table Lieu\n\n";
	$dbh->do($sql_creation_table_animal)           or die "Echec lors de la creation de la table Animal\n\n";
	$dbh->do($sql_creation_table_suivie)           or die "Echec lors de la creation de la table Suivie\n\n";
	$dbh->do($sql_creation_table_tmpProprietaire)  or die "Echec lors de la creation de la table tmpProprietaire\n\n";
	$dbh->do($sql_creation_table_tmpLieu)          or die "Echec lors de la creation de la table tmpLieu\n\n";



	print "\nToutes les tables ont été crée avec succès\n\n";

	$dbh->disconnect();
}

sub deleteduplicate(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

	print"Supression des duplicatas... \n";
	my $sql_duplicateProp = <<"SQL";

	INSERT INTO tmpProprietaire SELECT DISTINCT * FROM proprietaire;
	DROP TABLE proprietaire;
	ALTER TABLE tmpProprietaire RENAME TO proprietaire;
SQL

	my $sql_duplicateLieu = <<"SQL";

	INSERT INTO tmpLieu SELECT DISTINCT * FROM lieu;
	DROP TABLE lieu;
	ALTER TABLE tmpLieu RENAME TO lieu;
SQL


	$dbh -> do($sql_duplicateProp);
	$dbh -> do($sql_duplicateLieu);

	$dbh->disconnect();
}
sub loadData(){
	my $filename = 'Animaux.csv';
	my $csv = Text::CSV->new();
	open (my $file, "<", $filename) or die $!;
	while (<$file> ) {
		next if ($. == 1); #skip the first line containing the header here
		# next if (/^\s*$/); #vous pouvez rejeter les lignes vides, puis virer ;; de la fin des lignes: 
		# s/;;$//;
		if ($csv->parse($_)) {
			my @columns = $csv->fields();
			push(@IdAnimal,$columns[0]);
			#In order to put a default value if no animal names are given
			if ($columns[1] eq ""){
				push(@NomAnimal,"NA");
			}
			else{
				push(@NomAnimal,$columns[1])
			}
			push(@TypeAnimal,$columns[2]);
			push(@Couleur,$columns[3]);
			push(@Sexe,$columns[4]);
			push(@Sterilise,$columns[5]);
			push(@AnneeNaissance,$columns[6]);
			#Mandatory to replace the blanks when no vaccine date has been entered
			if ($columns[7] eq ""){
				push(@Vaccin1,0);
			}
			else{
				push(@Vaccin1,$columns[7])
			}
			if ($columns[8] eq ""){
				push(@Vaccin2,0);
			}
			else{
				push(@Vaccin2,$columns[8])
			}
			if ($columns[9] eq ""){
				push(@Vaccin3,0);
			}
			else{
				push(@Vaccin3,$columns[9])
			}	
			push(@Telephone,$columns[10]);
			push(@Nom,$columns[11]);
			push(@Prenom,$columns[12]);
			push(@Rue,$columns[13]);
			push(@CodePostal,$columns[14]);
			push(@Commune,$columns[15]);
			push(@NbHabitantsCommune,$columns[16]);
			push(@CodeDepartement,$columns[17]);
		 } else {
			my $err = $csv->error_input;
			print "Failed to parse the file : $err";
		}
	}
close $file;
}

sub updateTable(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";
	my $size;
	$size=scalar @IdAnimal;

	for (my $i=0 ; $i<$size; $i++){
		$dbh ->do("INSERT INTO proprietaire VALUES ($Telephone[$i], '$Nom[$i]', '$Prenom[$i]', '$Rue[$i]', $CodePostal[$i])") ;
		$dbh ->do("INSERT INTO lieu VALUES ($CodePostal[$i], '$Commune[$i]', $NbHabitantsCommune[$i], $CodeDepartement[$i])") ;
		$dbh ->do("INSERT INTO animal VALUES ($IdAnimal[$i], '$NomAnimal[$i]', '$TypeAnimal[$i]', '$Sexe[$i]', '$Couleur[$i]','$Sterilise[$i]',$AnneeNaissance[$i], $Telephone[$i])") ;
		$dbh ->do("INSERT INTO suivie VALUES ($IdAnimal[$i], $Vaccin1[$i], $Vaccin2[$i], $Vaccin3[$i])") ;
	}
	$dbh->disconnect();	
}

sub addPkFk(){
	#####Constraint####
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

	$dbh -> do(" ALTER TABLE animal ADD CONSTRAINT pk1 PRIMARY KEY (IdAnimal)");
	$dbh -> do(" ALTER TABLE suivie ADD CONSTRAINT pk2 PRIMARY KEY (IdAnimal)");
	$dbh -> do(" ALTER TABLE proprietaire ADD CONSTRAINT pk3 PRIMARY KEY (Telephone)"); 
	$dbh -> do(" ALTER TABLE lieu ADD CONSTRAINT pk4 PRIMARY KEY(CodePostal)");
	$dbh -> do(" ALTER TABLE animal ADD CONSTRAINT fk1 FOREIGN KEY (Telephone) REFERENCES proprietaire(Telephone)"); 
	$dbh -> do(" ALTER TABLE suivie ADD CONSTRAINT fk2 FOREIGN KEY (IdAnimal) REFERENCES animal(IdAnimal)");
	$dbh->disconnect();	
}



##################################################################


################# Differentes fonctions demandés #################


#### Fonction 1 : ajout Animal ####



sub ajoutAnimal{
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

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
     
    my $verifTel = $dbh->prepare("SELECT EXISTS (SELECT Nom, Prenom FROM Proprietaire WHERE Telephone=$telephone) AS TelExiste");  #requête pour vois si tel dans BD
    my $requete = $verifTel->execute();
    my $tmp;
    while(my $ref= $verifTel->fetchrow_hashref()){
	$tmp = $ref->{'telexiste'}; # tmp = 1 si vrai et 0 si faux
    }

    ###TELEPHONE EXISTE DEJA DANS BASE DE DONNEES#####
    if ($tmp == 1){
	$dbh ->do("INSERT INTO animal VALUES ($idAnimal, '$nomAnimal', '$type', '$sexe', '$couleur','$sterilise',$anneeNaissance, $telephone)") ; #insere nouvelles valeurs dans Animal	
	$dbh ->do("INSERT INTO suivie VALUES ($idAnimal, $vaccin1, $vaccin2, $vaccin3)") ;     #insere nouvelles valeurs dans suivie	
    }

    ### PAS DE TELEPHONE POPRIETAIRE DANS BASE DE DONNEES ######
    else{
	my $nom = ajoutNom();
	my $prenom = ajoutPrenom();
	my $rue = ajoutRue();
	my $codePostal = ajoutCodePostal();
	
	my $tmp2;
	my $verifCp = $dbh->prepare("SELECT EXISTS (SELECT * FROM Lieu, Proprietaire WHERE Lieu.CodePostal =$codePostal) As CpExiste");
	my $requte2=$verifCp->execute();
	while(my $ref2 = $verifCp->fetchrow_hashref()){
	    $tmp2= $ref2->{'cpexiste'};
	}
	
	#### CODE POSTAL EXISTE DANS BASE DE DONNEES ######
	if($tmp2 == 1)
	{
	    $dbh ->do("INSERT INTO proprietaire VALUES ($telephone, '$nom', '$prenom', '$rue', $codePostal)") ;  # insere nouvelles valeurs dans proprietaire
	    $dbh ->do("INSERT INTO animal VALUES ($idAnimal, '$nomAnimal', '$type', '$sexe', '$couleur','$sterilise',$anneeNaissance, $telephone)") ;# insere nouvelles valeurs dans Animal
	    $dbh ->do("INSERT INTO suivie VALUES ($idAnimal, $vaccin1, $vaccin2, $vaccin3)") ;     #insere nouvelles valeurs dans suivie
	}
	
	####CODE POSTAL PAS DANS BASE DE DONNEES ######
	else{
	    my $commune = ajoutCommune();
	    my $nbHabitantsCommune = ajoutNbHabitantsCommune();
	    my $codeDepartement = ajoutCodeDepartement($codePostal); 
	    
	    $dbh ->do("INSERT INTO proprietaire VALUES ($telephone, '$nom', '$prenom', '$rue', $codePostal)") ;   #insere nouvelles valeurs dans proprietaire
	    $dbh ->do("INSERT INTO lieu VALUES ($codePostal, '$commune', $nbHabitantsCommune, $codeDepartement)") ;# insere nouvelles valeurs dans lieu
	    $dbh ->do("INSERT INTO animal VALUES ($idAnimal, '$nomAnimal', '$type', '$sexe', '$couleur','$sterilise',$anneeNaissance, $telephone)") ; #insere nouvelles valeurs dans Animal	
	    $dbh ->do("INSERT INTO suivie VALUES ($idAnimal, $vaccin1, $vaccin2, $vaccin3)") ;    #insere nouvelles valeurs dans suivie	    
	}
	
	$verifCp->finish; #finit requête cpexiste
    }
    $verifTel->finish;

    $dbh->disconnect();
    appuyezPourContinuer();
}



#### Fonction 2 : modification de l'adresse du proprietaire ####



sub modifierAdresse{
    my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";
    
    my $nom = ajoutNom();
    my $prenom =ajoutPrenom();
    
    my $tmp3;
    my $verifProprio=$dbh->prepare("SELECT EXISTS (SELECT * FROM Proprietaire, Lieu WHERE Nom = '$nom' AND Prenom = '$prenom') AS proprioExiste");
    my $requete1=$verifProprio->execute();
    while(my $ref2 = $verifProprio->fetchrow_hashref()){
	$tmp3= $ref2->{'proprioexiste'};
    }

    ###### NOM ET PRENOM PAS DANS BASE DE DONNEES #######
    if($tmp3==0){
	print "Les noms et prénoms séléctionnés ne sont pas dans la base de données\n";
    }
    ###### NOM ET PRENOM EXISTE DANS BASE DE DONNEES #######
    else{
	my $selectProprio = $dbh->prepare("SELECT * FROM Proprietaire, LIEU WHERE Nom = '$nom' AND Prenom = '$prenom' AND Proprietaire.CodePostal = Lieu.codePostal ");
	my $requete2=$selectProprio->execute();
	while(my $ref= $selectProprio->fetchrow_hashref()){
	    print "Nom : $ref->{'nom'} | Prenom : $ref->{'prenom'} | Téléphone : $ref->{'telephone'} | rue : $ref->{'rue'} | Code Postal : $ref->{'codepostal'} | Commune : $ref->{'commune'} \n";	    
	}
	my $telephone = ajoutTelephone();
	
	my $tmp;
	my $verifTel=$dbh->prepare("SELECT EXISTS (SELECT * FROM Proprietaire, Lieu WHERE Telephone = $telephone ) AS telExiste");  # requête pour voir si le telephone existe dans BD
	my $requete=$verifTel->execute();
	while(my $ref2 = $verifTel->fetchrow_hashref()){
	    $tmp= $ref2->{'telexiste'};
	}
	
	#### PAS DE TELEPHONE DANS BASE DE DONNEES  ####
	if ($tmp == 0){
	    print"Pas de poprietaire trouvé pour le téléphone $telephone\n";
	}
	#### TELEPHONE EST DANS BASE DE DONNEES ####
	else{
	    my $rue=ajoutRue();
	    my $codePostal=ajoutCodePostal();
	    
	    my $tmp2;
	    my $verifCp=$dbh->prepare("SELECT EXISTS (SELECT * FROM Lieu WHERE Lieu.CodePostal = $codePostal ) AS cpExiste");  # requête pour voir si code postal dans BD
	    my $requte=$verifCp->execute();
	    while(my $ref2 = $verifCp->fetchrow_hashref()){
		$tmp2 = $ref2->{'cpexiste'};
	    }
	    ##### CODE POSTAL EXISTE DANS BASE DE DONNEES ######
	    if ($tmp2 == 1){ 
		$dbh->do("UPDATE Proprietaire SET Rue = '$rue', CodePostal =$codePostal WHERE Telephone = $telephone");
	    }
	    ##### CODE POSTAL PAS DANS BASE DE DONNEES ######
	    else{         
		my $commune = ajoutCommune();
		my $nbHabitantsCommune = ajoutNbHabitantsCommune();
		my $codeDepartement = ajoutCodeDepartement($codePostal);
		
		$dbh->do("UPDATE Proprietaire SET Rue = '$rue', CodePostal =$codePostal WHERE Telephone = $telephone");
		$dbh->do("INSERT INTO Lieu VALUES($codePostal, '$commune', $nbHabitantsCommune,  $codeDepartement)");
	    }
	    $verifCp->finish;
	}
	$verifTel->finish;
	$selectProprio->finish;
    }
    $verifProprio->finish;
     $dbh->disconnect();
     appuyezPourContinuer();
}



#### Fonction 3 : Ajout d'un vaccin ####



sub ajoutVaccin(){
    my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

    my $anneeNaissance;
    my $vaccin1;
    my $vaccin2;
    my $vaccin3;

  	print "Voici la liste de tous les types d'animaux enregistres\n";
    my $selectType = $dbh->prepare("SELECT DISTINCT TypeAnimal From Animal");
    my $requete = $selectType->execute();
    while(my $ref = $selectType->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Type : $ref->{'typeanimal'}\n";
    }
    print "\n";  
    
  	my $typeAnimal=ajoutType(); chomp($typeAnimal);
	my $selectTypeBis = $dbh->prepare("SELECT * FROM  Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal = '$typeAnimal' \n");
	my $requete0 = $selectTypeBis->execute();
	while(my $ref=$selectTypeBis->fetchrow_hashref()){
	    print "Id : $ref->{'idanimal'} | Type : $ref->{'typeanimal'} | Année Naissance : $ref->{'anneenaissance'} | Vaccin1 : $ref->{'vaccin1'} | Vaccin2 : $ref->{'vaccin2'} | Vaccin3 : $ref->{'vaccin3'} \n";
	}	
	
	print "Indiquer l'id de l'animal pour lequel vous voulez ajouter le vaccin\n";
	my $id=<>; chomp($id);
	
	my $tmp;
	my $verifId = $dbh->prepare("SELECT EXISTS (SELECT * FROM Animal, Suivie WHERE TypeAnimal = '$typeAnimal' AND Animal.IdAnimal = Suivie.IdAnimal AND Animal.IdAnimal = $id) AS IdExiste");
	my $requete9=$verifId->execute();
	while(my $ref = $verifId->fetchrow_hashref()){
	    $tmp= $ref->{'idexiste'};
	}
	
	######## ID PAS DANS BD #########
	if ($tmp == 0){
	    print"Pas d'identifiant $id trouvé dans la base de données\n";
	}
    
	############ ID DANS BD #############
	else{
	    my $selectAnimaux = $dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.TypeAnimal = '$typeAnimal' AND Animal.IdAnimal = Suivie.IdAnimal AND Animal.IdAnimal = $id\n");
	    my $requete8 = $selectAnimaux->execute();
	    while(my $ref=$selectAnimaux->fetchrow_hashref()){
		print "Id : $ref->{'idanimal'} | Type : $ref->{'typeanimal'} | Année Naissance : $ref->{'anneenaissance'} | Vaccin1 : $ref->{'vaccin1'} | Vaccin2 : $ref->{'vaccin2'} | Vaccin3 : $ref->{'vaccin3'} \n";
		$anneeNaissance = $ref->{'anneenaissance'}; # définit année de naissance de l'animal
	    }	
	    my $selectVaccin = $dbh->prepare("SELECT Vaccin1, Vaccin2, Vaccin3 FROM Suivie WHERE IdAnimal = $id\n");
	    my $requete2 = $selectVaccin->execute();
	    
	    while(-1){
		print "Quel vaccin voulez-vous ajouter? - \nTaper 1 pour ajouter le vaccin1\nTaper 2 pour ajouter le vaccin2\nTaper 3 pour ajouter le vaccin3\nTaper 0 pour terminer votre saisie\n";
		my $rep=<>; chomp($rep);	    
		if ($rep eq 1){
		my $tmp2;
		my $verifVaccin1 = $dbh->prepare("SELECT EXISTS (SELECT Vaccin1 FROM Suivie WHERE IdAnimal = $id AND Vaccin1 !=0 ) AS vaccin1Existe");
		my $requete3=$verifVaccin1->execute();
		while(my $ref = $verifVaccin1->fetchrow_hashref()){
		    $tmp2= $ref->{'vaccin1existe'};
		}
		###### VACCIN 1 DEJA ENREGISTRE POUR CET ANIMAL ####
		if ($tmp2==1){
		    print "Le vaccin1 existe déjà\n";
		    $rep=1;
		    
		}
		###### VACCIN 1 PAS ENREGISTRE POUR CET ANIMAL ####
		else{
		    $vaccin1 = ajoutVaccin1($anneeNaissance);
		    my $requete4 = $dbh->do("UPDATE Suivie SET Vaccin1 = '$vaccin1'");
		}
		$verifVaccin1->finish();
	    }
	    elsif ($rep eq 2){
		my $tmp2;
		my $verifVaccin2 = $dbh->prepare("SELECT EXISTS (SELECT Vaccin2 FROM Suivie WHERE IdAnimal = $id AND Vaccin2 !=0) AS vaccin2Existe");
		my $requete3=$verifVaccin2->execute();
		while(my $ref = $verifVaccin2->fetchrow_hashref()){
		    $tmp2= $ref->{'vaccin2existe'};
		}
		###### VACCIN 2 DEJA ENREGISTRE POUR CET ANIMAL DANS BD ####
		if ($tmp2==1){
		    print "Le vaccin2 existe déjà\n";
		}
		###### VACCIN 2 PAS ENREGISTRE POUR CET ANIMAL  ####
		else{
		    $vaccin2 = ajoutVaccin2($anneeNaissance);
		    my $requete4 = $dbh->do("UPDATE Suivie SET Vaccin2 = '$vaccin2'");
		}
		$verifVaccin2->finish();
	    }
	    elsif ($rep eq 3){

		my $tmp2;
		my $verifVaccin3 = $dbh->prepare("SELECT EXISTS (SELECT Vaccin3 FROM Suivie WHERE IdAnimal = $id AND Vaccin3 !=0) AS vaccin3Existe");
		my $requete3=$verifVaccin3->execute();
		while(my $ref = $verifVaccin3->fetchrow_hashref()){
		    $tmp2= $ref->{'vaccin3existe'};
		}
		###### VACCIN 3 DEJA ENREGISTRE POUR CET ANIMAL ####
		if ($tmp2==1){
		    print "Le vaccin3 existe déjà\n";
		}
		###### VACCIN 3 PAS ENREGISTRE POUR CET ANIMAL ####
		else{
		    $vaccin3 = ajoutVaccin3($anneeNaissance);
		    my $requete4 = $dbh->do("UPDATE Suivie SET Vaccin3 = '$vaccin3'");
		}     	
		
		$verifVaccin3->finish();
	    }
	    elsif ($rep eq 0){
		last;
	    }
	    else{
		print"Entrer 1, 2, 3 ou 0 pour sortir\n\n";
	       	
	    }
	}	
	$selectVaccin->finish();
	$selectAnimaux->finish();
	}

    $verifId->finish();
    $selectTypeBis->finish;
    $selectType->finish;

    $dbh->disconnect();
	appuyezPourContinuer();
}



#### Fonction 4 : Afficher les chats ####



sub afficheChat{

	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

    print "Voici la liste de tous les chats enregistrés\n";
    my $selectChat = $dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal = 'Chat'");
    my $requete = $selectChat->execute();

    
    while(my $ref= $selectChat->fetchrow_hashref()){
		print "Id : $ref->{'idanimal'} | Nom : $ref->{'nomanimal'} | Couleur : $ref->{'couleur'} | Sexe : $ref->{'sexe'} | Naissance : $ref->{'anneenaissance'} | Sterilise : $ref->{'sterilise'} | Vaccin1 : $ref->{'vaccin1'} | Vaccin2 : $ref->{'vaccin2'} | Vaccin3 : $ref->{'vaccin3'}\n";
    }

    $selectChat->finish();
    $dbh->disconnect();
	appuyezPourContinuer();
}



#### Fonction 5 : Afficher les animaux de type X ayant moins de Y années ####



sub afficheSelectionUtilisateur{
    my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

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
    my $requete2 = $verifChoix->execute();
    while(my $ref = $verifChoix->fetchrow_hashref()){
	$tmp = $ref->{'choixexiste'};
    }

    ####### CHOIX DE L'UTILISATEUR EXISTE #########
    if ($tmp == 1){
	my $selection= $dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND TypeAnimal ='$choixType' AND $anneeActuelle - $choixAnnee < AnneeNaissance");
	my $requete2 = $selection->execute();
	
	while(my $ref = $selection->fetchrow_hashref()){
	    print "Id : $ref->{'idanimal'} | Nom : $ref->{'nomanimal'} | Type : $ref->{'typeanimal'} | Couleur : $ref->{'couleur'} | Sexe : $ref->{'sexe'} | Naissance : $ref->{'anneenaissance'} \n";
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
    appuyezPourContinuer();
}



#### Fonction 6 : Afficher le nombre moyen d’animaux par propriétaire ####



sub afficheMoyenneAnimaux{
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";
    
    my $selectMoyenne = $dbh->prepare("
    SELECT AVG(NbAnimaux) as NbMoyen FROM (SELECT COUNT(*) AS NbAnimaux, Telephone From Animal GROUP BY Telephone) AS table1
    ");
    my $requete = $selectMoyenne->execute();
    
	while(my $ref = $selectMoyenne->fetchrow_hashref()){  # affiche résulat de la requête SQL
		print "Le nombre moyen d'animal par propriétaire est de : $ref->{'nbmoyen'} \n";
   	}
   	print "\n";
        
    $selectMoyenne->finish();

    $dbh->disconnect();
	appuyezPourContinuer();
}



#### Fonction 7 : Afficher les propriétaires qui ont plus de trois animaux ####



sub afficheSuperieurAnimaux{
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

    print "Voici les propriétaires qui ont plus de 3 animaux\n";
    my $selectSuperieur = $dbh->prepare("
	SELECT nom, prenom, Table1.Telephone, Compte
	FROM(SELECT telephone, count(*) AS Compte FROM Animal
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
	print "Téléphone : $ref->{'telephone'} | Prénom : $ref->{'prenom'} | Nom : $ref->{'nom'} | Nombre animaux :  $ref->{'compte'}\n";
    }
    print "\n";
        
    $selectSuperieur->finish();
    $dbh->disconnect();  
	appuyezPourContinuer();
}



#### Fonction 8 : Pour chaque commune, afficher le nombre de propriétaires distincts ####



sub afficheCommuneProprio{
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

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
	print "Commune : $ref->{'commune'} | Nombre Porpriétaire : $ref->{'nbproprio'}\n";
    }
    print "\n";
        
    $selectSuperieur->finish();
    $dbh->disconnect();   
	appuyezPourContinuer();
}



#### Fonction 9 : Pour chaque commune, afficher le nombre total d’animaux ####



sub afficheCommuneAnimaux{
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";
    
    my $vueanimal = $dbh->do("CREATE VIEW vueanimal AS SELECT COUNT(*) AS nbanimaux,telephone FROM animal GROUP BY telephone");
    
    my $vueproprio = $dbh->do("CREATE VIEW vueproprio AS SELECT SUM(nbanimaux) AS nbanimauxcommune, codepostal FROM vueanimal, proprietaire WHERE vueanimal.telephone = proprietaire.telephone GROUP BY codepostal");
    
    
    my $selectAnimaux = $dbh->prepare("select distinct nbanimauxcommune, commune from vueproprio, lieu where lieu.codepostal=vueproprio.codepostal");
    
    my $requete = $selectAnimaux->execute();
    
    print"Voici le nombre total d'animaux par commune\n";
    while(my $ref = $selectAnimaux->fetchrow_hashref()){  # affiche résulat de la requête SQL
	print "Commune : $ref->{'commune'} | Nombre Animaux : $ref->{'nbanimauxcommune'}\n";
    }
    print "\n";
    
    $dbh->do("drop view vueproprio CASCADE");
    $dbh->do("drop view vueanimal CASCADE");

    $selectAnimaux->finish();
    $dbh->disconnect(); 
	appuyezPourContinuer();
}



##################################################################

################# Only Perl #################



sub onlyPerl(){
	#loadData();
	my %count;
	foreach my $element(@Commune) {
			++$count{$element};
	}
	foreach my $element( keys %count ) {
		print "\n";
		print "Il y a $count{$element} animaux à $element qui sont dans notre système.\n"
	}
	appuyezPourContinuer();
}



##################################################################

################# Differentes fonctions utilisé pour les fonctionalités #################



sub ajoutId{
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Erreur : Connection impossible..\n";

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
    my $nomAnimal = ucfirst(lc(<>));chomp($nomAnimal); # transforme d'abord tout en mini et ensuite juste 1er maj
    if ($nomAnimal=~/Na/ ){
	$nomAnimal = uc($nomAnimal); #mettre tout le NA en maj
    }
    while($nomAnimal =~/\d/){  #si le utilsiateur met chiffre repete
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
    my $sexe = uc(<>); chomp($sexe);
    while($sexe =~/\d/ || $sexe =~/^[^MF]$/ || length($sexe) ne 1){
	print "Entrer le sexe de l'animal (M ou F)\n";
	$sexe = uc(<>); chomp($sexe);	
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
    while($telephone =~/\D/ || $telephone !~/^\d{5}$/ ){
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
    while($codePostal =~/\D/ || $codePostal !~/^\d{5}$/){
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
    return $codeDepartement;
}

sub appuyezPourContinuer(){

	print "\nAppuyez sur Entrée pour retourner au menu principal : ";
	<STDIN>;
	print"\n";
	system 'clear';
	menu();    
}


################# Generation des fichiers HTML #################



sub generateHTML(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
	my $request;	

	print "\n";
	print " __________________________________________________________________________________________________\n";
	print "|                                     Bienvenue sur AnimalCare                                     |\n";
	print "|                          	Quelles données souhaitez vous exporter ?                          |\n";
	print "|__________________________________________________________________________________________________|\n";
	print "|                                                                                                  |\n";
	print "| Tapez 1 pour afficher les propriétaires possedant plus de 3 animaux et sauvegarder les données   |\n"; 
	print "| Tapez 2 pour afficher le nombre d'animaux par ville et sauvegarder les données                   |\n";
	print "| Tapez 3 pour afficher le nombre d'animaux par ville et sauvegarder les données en utilisant Perl |\n";
	print "| Tapez 9 pour revenir au menu principal                                                           |\n";
	print "| Tapez 0 pour quitter                                                                             |\n";
	print "|__________________________________________________________________________________________________|\n";
	print "\n";

	my $answer=999;
		while ($answer ){
			$answer = <STDIN>;
			chomp($answer);
			if ($answer eq 1){
				my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
				my $view = $dbh->prepare("CREATE VIEW averageAnimals AS (SELECT count(nomanimal) AS animals,telephone FROM animal GROUP BY telephone having count(nomanimal)>3)");
   				my $reqv1 = $view->execute();
				$request="SELECT nom,prenom,animals FROM averageAnimals,proprietaire WHERE averageAnimals.telephone = proprietaire.telephone";
				my $filename;
				print "Entrez un nom de fichier pour la sauvegarde (ajouter .html à la fin du nom --> exemple.html) ";
				$filename = <STDIN>;
				chomp($filename);
				open(my $fh, '>', $filename) or die "Could not open file '$filename' : $!";

				print $fh "Proprietaire ayant plus que 3 animaux : ";
				print $fh "<table border=\"1\" width=\"800\"> \n"; #do some effect because pretty=better
				print $fh "<tr><td><b>Nom du proprietaire</b></td><td><b>Prenom du proprietaire</b></td><td><b>Nombre d'animaux</b></td></tr>\n"; #print table column headers
				$statement = $dbh->prepare($request);
				$statement->execute();
				
				while (@data = $statement->fetchrow_array()) { # retrieve the values from SQL
					$htmlvar1 = $data[0];
					$htmlvar2 = $data[1];
					$htmlvar3 = $data[2];
					print $fh "<tr><td>$htmlvar1</td><td>$htmlvar2</td><td>$htmlvar3</td></tr>\n"; #print rows
				}
				print $fh "</table>\n";
			    close $fh;  
				print"\n";
			    my $drop = $dbh ->prepare("DROP VIEW averageAnimals");
			    my $reqv3 = $drop->execute();
			
				$dbh->disconnect();	
				appuyezPourContinuer();
					
						
			}
			if ($answer eq 2){
				my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
				my $view = $dbh->prepare("create view ownerCity as(select commune,telephone,nom,prenom from lieu,proprietaire where lieu.codepostal = proprietaire.codepostal ORDER BY commune)");
   				my $reqv1 = $view->execute();
				$request="select commune,count(proprietaire.telephone) AS count from ownerCity,proprietaire where ownerCity.telephone = proprietaire.telephone group by commune";
				my $filename;
				print "Entrez un nom de fichier pour la sauvegarde (ajouter .html à la fin du nom --> exemple.html) ";
				$filename = <STDIN>;
				chomp($filename);
				open(my $fh, '>', $filename) or die "Could not open file '$filename' : $!";

				print $fh "Nombre d'aniaux par ville : ";
				print $fh "<table border=\"1\" width=\"800\"> \n"; #do some effect because pretty=better
				print $fh "<tr><td><b>Commune</b></td><td><b>Résidents</b></td></tr>\n"; #print table column headers
				$statement = $dbh->prepare($request);
				$statement->execute();
				
				while (@data = $statement->fetchrow_array()) { # retrieve the values from SQL
					$htmlvar1 = $data[0];
					$htmlvar2 = $data[1];
					print $fh "<tr><td>$htmlvar1</td><td>$htmlvar2</td></tr>\n"; #print rows
				}
				print $fh "</table>\n";
			    close $fh;  
				print"\n";
			    my $drop = $dbh ->prepare("DROP VIEW ownerCity");
			    my $reqv3 = $drop->execute();

				$dbh->disconnect();
				appuyezPourContinuer();			}
	
			if ($answer eq 3){
				my $dbh =  DBI->connect("DBI:Pg:dbname=amsantos;host=dbserver","amsantos","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
    			my $view = $dbh ->prepare("create view animalCity as(select commune,telephone from lieu,proprietaire where lieu.codepostal = proprietaire.codepostal ORDER BY commune)");   				
    			my $reqv1 = $view->execute();
				$request="select commune,count(nomanimal) AS number from animalCity,animal where animalCity.telephone = animal.telephone group by commune";
				my $filename;
				print "Entrez un nom de fichier pour la sauvegarde (ajouter .html à la fin du nom --> exemple.html) ";
				$filename = <STDIN>;
				chomp($filename);
				open(my $fh, '>', $filename) or die "Could not open file '$filename' : $!";

				print $fh "Nombre d'aniaux par ville : ";
				print $fh "<table border=\"1\" width=\"800\"> \n"; #do some effect because pretty=better
				print $fh "<tr><td><b>Commune</b></td><td><b>Nombre d'animaux</b></td></tr>\n"; #print table column headers
				$statement = $dbh->prepare($request);
				$statement->execute();
				
				while (@data = $statement->fetchrow_array()) { # retrieve the values from SQL
					$htmlvar1 = $data[0];
					$htmlvar2 = $data[1];
					print $fh "<tr><td>$htmlvar1</td><td>$htmlvar2</td></tr>\n"; #print rows
				}
				print $fh "</table>\n";
			    close $fh;  
				print"\n";
			    my $drop = $dbh ->prepare("DROP VIEW animalCity");
			    my $reqv3 = $drop->execute();

				$dbh->disconnect();	
				appuyezPourContinuer();			 
			}
			if ($answer eq 9){	
				menu();
			}
			if ($answer eq 0){	
				exit;
			}
		}
	$dbh->disconnect();	
}



##################################################################

################# Menu Principal #################

sub menu{
	print "\n";
	print " ______________________________________________________________________________________\n";
	print "|                             Bienvenue sur AnimalCare                                 |\n";
	print "|                	Quelle(s) opération(s) souhaitez vous réaliser ?               |\n";
	print "|______________________________________________________________________________________|\n";
	print "|                                                                                      |\n";
	print "| Tapez 1 pour ajouter un animal                                                       |\n";
	print "| Tapez 2 pour changer l'adresse d'un proprietaire                                     |\n";
	print "| Tapez 3 pour ajouter un vaccin                                                       |\n";
	print "| Tapez 4 pour afficher les chats                                                      |\n";
	print "| Tapez 5 pour afficher les animaux de type X ayant moins de Y années                  |\n";
	print "| Tapez 6 pour afficher le nombre moyen d’animaux par propriétaire                     |\n";
	print "| Tapez 7 pour afficher les propriétaires qui ont plus de trois animaux                |\n";
	print "| Tapez 8 pour afficher le nombre de propriétaires distincts par ville                 |\n";
	print "| Tapez 9 pour afficher le nombre total d’animaux par ville                            |\n";
	print "| Tapez 10 pour afficher le nombre total d’animaux par ville en utilisant que Perl     |\n";
	print "| Tapez 11 pour afficher le menu de genérations d'HTML                                 |\n";
	print "| Tapez 0 pour quitter                                                                 |\n";
	print "|______________________________________________________________________________________|\n";
	print "\n";

	my $choice=999;
	while ($choice )
	{
		$choice = <STDIN>;
		chomp($choice);
		if ($choice eq 1){
			ajoutAnimal(),
		}
		if ($choice eq 2){
			modifierAdresse();
		}
		if ($choice eq 3){
			ajoutVaccin();
		}
		if ($choice eq 4){
			afficheChat();
		}
		if ($choice eq 5){
			afficheSelectionUtilisateur();
		}
		if ($choice eq 6){
			afficheMoyenneAnimaux();
		}
		if ($choice eq 7){
			afficheSuperieurAnimaux();
		}
		if ($choice eq 8){
			afficheCommuneProprio();
		}
		if ($choice eq 9){
			afficheCommuneAnimaux();
		}
		if ($choice eq 10){
			onlyPerl(); 
		}
		if ($choice eq 11){
			generateHTML(); 
		}
		if ($choice eq 0){
			exit 
		}
	}
}



##################################################################

################# Main #################


sub hereWeGo(){
	createTable();
	loadData();
	updateTable();
	deleteduplicate();
	addPkFk();
	appuyezPourContinuer();
}



##################################################################

#################### Launch the program ###################

hereWeGo();



##################################################################

#print join("| ", @IdAnimal); #check all values in an array
