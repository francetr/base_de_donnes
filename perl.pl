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
#HTML

################################################################################################Creation table ################################################################################################

# Connection
#my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";


sub createTable(){  #Create all the tables, drop if it already exist
	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";

	# Table Proprietaire
	print "Creating table : Proprietaire\n";
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
	print "Creating table : Lieu\n";

	my $sql_creation_table_lieu = <<"SQL";
	CREATE TABLE Lieu (
	  CodePostal              INT   	    ,
	  Commune                 VARCHAR       ,
	  NbHabitantsCommune      INT 	        ,
	  CodeDepartement         INT           
	)
SQL

	# Table Animal
	print "Creating table : Animal\n";
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
	print "Creating table : Suivie\n";
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
	$dbh->do($sql_creation_table_proprietaire)     or die "Failed to create table Proprietaire\n\n";
	$dbh->do($sql_creation_table_lieu)             or die "Failed to create table Lieu\n\n";
	$dbh->do($sql_creation_table_animal)           or die "Failed to create table Animal\n\n";
	$dbh->do($sql_creation_table_suivie)           or die "Failed to create table Suivie\n\n";
	$dbh->do($sql_creation_table_tmpProprietaire)  or die "Failed to create table tmpProprietaire\n\n";
	$dbh->do($sql_creation_table_tmpLieu)          or die "Failed to create table tmpLieu\n\n";



	print "\nAll tables have been created successfully !\n\n";

	$dbh->disconnect();
}

sub deleteduplicate(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";

	print"Deleting duplicatas \n";
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

sub displayAverage(){
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
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
    
}

sub updateTable(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
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
	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";

	$dbh -> do(" ALTER TABLE animal ADD CONSTRAINT pk1 PRIMARY KEY (IdAnimal)");
	$dbh -> do(" ALTER TABLE suivie ADD CONSTRAINT pk2 PRIMARY KEY (IdAnimal)");
	$dbh -> do(" ALTER TABLE proprietaire ADD CONSTRAINT pk3 PRIMARY KEY (Telephone)"); 
	$dbh -> do(" ALTER TABLE lieu ADD CONSTRAINT pk4 PRIMARY KEY(CodePostal)");
	#a check !!!!
	####$dbh -> do(" ALTER TABLE suivie ADD CONSTRAINT pk5 CHECK (Vaccin1>anAnneeiNaissance AND Vaccin2>AnneeNaissance AND Vaccin3>AnneeNaissance)");
	$dbh -> do(" ALTER TABLE animal ADD CONSTRAINT fk1 FOREIGN KEY (Telephone) REFERENCES proprietaire(Telephone)"); #chaque animal doit avoir un proprio
	$dbh -> do(" ALTER TABLE suivie ADD CONSTRAINT fk2 FOREIGN KEY (IdAnimal) REFERENCES animal(IdAnimal)");
	$dbh->disconnect();	

}
sub displayCat()
{
	my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
    my $sth = $dbh->prepare("SELECT * FROM animal WHERE typeanimal = 'Chat'");
    my $num = $sth->execute();
    print "Here is a list of all the cats : \n\n";
    while(my $ref = $sth->fetchrow_hashref()){
    #print "$ref->{'idanimal'} $ref->{'nomanimal'}\n";
	print "ID : $ref->{'idanimal'} | Nom : $ref->{'nomanimal'} | Couleur : $ref->{'couleur'} | Sexe : $ref->{'sexe'} | Sterilise : $ref->{'sterilise'} | AnneeNaissance : $ref->{anneenaissance}\n";
    }
    print "\nPress ENTER to go back to menu:";
	<STDIN>;
	print"\n";
	system 'clear';
	menu();
	$dbh->disconnect();	

}

sub onlyPerl(){
	#loadData();
	my %count;
	foreach my $element(@Commune) {
			++$count{$element};
	}
	foreach my $element( keys %count ) {
		print "\n";
		print "There is $count{$element} animals in $element that are in our system.\n";
	}
	print "\nPress ENTER to go back to menu:";
	<STDIN>;
	print"\n";
	system 'clear';
	menu();
}


sub ownerMoreThanThree(){

   	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
	my $view = $dbh->prepare("CREATE VIEW averageAnimals AS (
	 	SELECT count(nomanimal) AS animals,telephone
	 	FROM animal 
	 	GROUP BY telephone having count(nomanimal)>3)");
    my $reqv1 = $view->execute();
	my $sql = $dbh->prepare("SELECT nom,prenom,animals 
		FROM averageAnimals,proprietaire 
		WHERE averageAnimals.telephone = proprietaire.telephone");
    my $reqv2 = $sql->execute();
    print "The owners that have more than three animals are : \n\n";
    while (my $ref = $sql ->fetchrow_hashref()){
    	print "$ref->{'nom'} $ref->{'prenom'} ($ref->{'animals'})\n";
   }
	print"\n";
    my $drop = $dbh ->prepare("DROP VIEW averageAnimals");
    my $reqv3 = $drop->execute();

	print "\nPress ENTER to go back to menu:";
	<STDIN>;
	print"\n";
	system 'clear';
	menu();	 
	$dbh->disconnect();	

}

sub ownerCity(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
	my $view = $dbh->prepare("create view ownerCity as(
	select commune,telephone,nom,prenom 
	from lieu,proprietaire 
	where lieu.codepostal = proprietaire.codepostal 
	ORDER BY commune)");
    my $reqv1 = $view->execute();
	my $sql = $dbh->prepare("select commune,count(proprietaire.telephone) AS count 
	from ownerCity,proprietaire 
	where ownerCity.telephone = proprietaire.telephone 
	group by commune");
    my $reqv2 = $sql->execute();
    while (my $ref = $sql ->fetchrow_hashref()){
    	print "There is $ref->{'count'} owners of animals in $ref->{'commune'} that are in our system.\n";

   }
	print"\n";
    my $drop = $dbh ->prepare("DROP VIEW ownerCity");
    my $reqv3 = $drop->execute();

	print "\nPress ENTER to go back to menu:";
	<STDIN>;
	print"\n";
	system 'clear';
	menu();	
	$dbh->disconnect();

}
sub animauxCity(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
    my $view = $dbh ->prepare("create view animalCity as(
    	select commune,telephone 
    	from lieu,proprietaire
		where lieu.codepostal = proprietaire.codepostal 
		ORDER BY commune)");
    my $reqv1 = $view->execute();
    my $sql = $dbh->prepare("select commune,count(nomanimal) AS number from animalCity,animal where animalCity.telephone = animal.telephone group by commune");
    my $reqv2 = $sql->execute();
    while (my $ref = $sql ->fetchrow_hashref()){
    	print "There is $ref->{'number'} animals in $ref->{'commune'} that are in our system.\n";

    }
	print"\n";
    my $drop = $dbh ->prepare("DROP VIEW animalCity");
    my $reqv3 = $drop->execute();

	print "\nPress ENTER to go back to menu:";
	<STDIN>;
	print"\n";
	system 'clear';
	menu();
	$dbh->disconnect();	

}
sub addvaccine()
{
    my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
    my $sth = $dbh -> prepare("SELECT NomAnimal as name,IdAnimal as id FROM animal");
    my $num = $sth->execute();
    #check ann enaissacne
    print "Please enter the phone number of the concerned animal : ";
    my $phone = <STDIN>;



}
sub userSelection(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";

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

sub generateHTML(){
	my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
	my $request;	

	print "\n";
	print " _______________________________________________________________________________________________\n";
	print "|                                     Welcome user                                              |\n";
	print "|                          	Which data to you want to export?                               |\n";
	print "|_______________________________________________________________________________________________|\n";
	print "|                                                                                               |\n";
	print "| Press 1 to display all the owners that have more than 3 animals and save the result           |\n";
	print "| Press 2 to display the number of animals for each cities and save the result                  |\n";
	print "| Press 3 to display the number of animals for each cities only using Perl and save the result  |\n";
	print "| Press 9 to go back to the main menu                                                           |\n";
	print "| Press 0 to quit                                                                               |\n";
	print "|_______________________________________________________________________________________________|\n";
	print "\n";

	my $answer=999;
		while ($answer ){
			$answer = <STDIN>;
			chomp($answer);
			if ($answer eq 1){
				my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
				my $view = $dbh->prepare("CREATE VIEW averageAnimals AS (SELECT count(nomanimal) AS animals,telephone FROM animal GROUP BY telephone having count(nomanimal)>3)");
   				my $reqv1 = $view->execute();
				$request="SELECT nom,prenom,animals FROM averageAnimals,proprietaire WHERE averageAnimals.telephone = proprietaire.telephone";
				my $filename;
				print "Enter a filename in which you want your result to be saved in (please put .html at the end of your filename --> example.html) : ";
				$filename = <STDIN>;
				chomp($filename);
				open(my $fh, '>', $filename) or die "Could not open file '$filename' : $!";

				print $fh "Results table";
				print $fh "<table border=\"1\" width=\"800\"> \n"; #do some effect because pretty=better
				print $fh "<tr><td><b>Owner Last name</b></td><td><b>Owner First name</b></td><td><b>Number of animals</b></td></tr>\n"; #print table column headers
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

				print "\nPress ENTER to go back to menu:";
				<STDIN>;
				print"\n";
				system 'clear';
				$dbh->disconnect();	
				menu();		
						
			}
			if ($answer eq 2){
				my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
				my $view = $dbh->prepare("create view ownerCity as(select commune,telephone,nom,prenom from lieu,proprietaire where lieu.codepostal = proprietaire.codepostal ORDER BY commune)");
   				my $reqv1 = $view->execute();
				$request="select commune,count(proprietaire.telephone) AS count from ownerCity,proprietaire where ownerCity.telephone = proprietaire.telephone group by commune";
				my $filename;
				print "Enter a filename in which you want your result to be saved in (please put .html at the end of your filename --> example.html) : ";
				$filename = <STDIN>;
				chomp($filename);
				open(my $fh, '>', $filename) or die "Could not open file '$filename' : $!";

				print $fh "Results table";
				print $fh "<table border=\"1\" width=\"800\"> \n"; #do some effect because pretty=better
				print $fh "<tr><td><b>Commune</b></td><td><b>Residents</b></td></tr>\n"; #print table column headers
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

				print "\nPress ENTER to go back to menu:";
				<STDIN>;
				print"\n";
				system 'clear';
				$dbh->disconnect();
				menu();	
			}
	
			if ($answer eq 3){
				my $dbh =  DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances","",{"RaiseError" => 1}) or die "Error : Connection failed.\n";
    			my $view = $dbh ->prepare("create view animalCity as(select commune,telephone from lieu,proprietaire where lieu.codepostal = proprietaire.codepostal ORDER BY commune)");   				
    			my $reqv1 = $view->execute();
				$request="select commune,count(nomanimal) AS number from animalCity,animal where animalCity.telephone = animal.telephone group by commune";
				my $filename;
				print "Enter a filename in which you want your result to be saved in (please put .html at the end of your filename --> example.html) : ";
				$filename = <STDIN>;
				chomp($filename);
				open(my $fh, '>', $filename) or die "Could not open file '$filename' : $!";

				print $fh "Results table";
				print $fh "<table border=\"1\" width=\"800\"> \n"; #do some effect because pretty=better
				print $fh "<tr><td><b>Commune</b></td><td><b>Animal Numbers</b></td></tr>\n"; #print table column headers
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

				print "\nPress ENTER to go back to menu:";
				<STDIN>;
				print"\n";
				system 'clear';
				$dbh->disconnect();	
				menu();	 
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


sub menu
{
	print "\n";
	print " _________________________________________________________________________________________\n";
	print "|                                     Welcome user                                        |\n";
	print "|                          	What can we do for you ?                                  |\n";
	print "|_________________________________________________________________________________________|\n";
	print "|                                                                                         |\n";
	print "| Press 1 to add an animal                                                                |\n";
	print "| Press 2 to change the adress of an owner                                                |\n";
	print "| Press 3 to add a new vaccine                                                            |\n";
	print "| Press 4 to display all the cats                                                         |\n";
	print "| Press 5 to display all the animals from a specific type and younger than a specific age |\n";
	print "| Press 6 to display the average number of pets per owner                                 |\n";
	print "| Press 7 to display the owners who have more than three animals                          |\n";
	print "| Press 8 to display all the owners for each cities                                       |\n";
	print "| Press 9 to display the number of animals for each cities                                |\n";
	print "| Press 10 to display the number of animals for each cities only using Perl               |\n";
	print "| Press 11 to go to the HTML generator menu                                               |\n";
	print "| Press 0 to quit                                                                         |\n";
	print "|_________________________________________________________________________________________|\n";
	print "\n";

	my $choice=999;
	while ($choice )
	{
		$choice = <STDIN>;
		chomp($choice);
		if ($choice eq 1){
			
		}
		if ($choice eq 2){

		}
		if ($choice eq 3){

		}
		if ($choice eq 4){
			displayCat();
		}
		if ($choice eq 5){
			userSelection();
		}
		if ($choice eq 6){
			displayAverage();
		}
		if ($choice eq 7){
			ownerMoreThanThree();
		}
		if ($choice eq 8){
			ownerCity();
		}
		if ($choice eq 9){
			animauxCity();
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


sub hereWeGo(){
	createTable();
	loadData();
	updateTable();
	deleteduplicate();
	addPkFk();
	#generateHTML();
	print "\n";
	print "\nPress ENTER to go back to menu:";
	<STDIN>;
	print"\n";
	system 'clear';

	menu();
}



#################### Launch the program ###################

hereWeGo();


#print join("| ", @IdAnimal); #check all values in an array




######TODO#####

	# print "| Press 1 to add an animal                                                                |\n";
	# print "| Press 2 to change the adress of an owner                                                |\n";
	# print "| Press 3 to add a new vaccine                                                            |\n";




# my $sth = $dbh ->prepare ("SELECT(MAX(IdAnimal)) FROM animal");
# my $num = $sth->execute();
# print "query return $num rows\n";
# while (my $ref = $sth ->fetchrow_hashref()){
#     my $res = $ref->{'max'};
# 	my $maj = $res+1;
# 	print "$maj \n";
# 					    $dbh->do("INSERT INTO animal VALUES('$maj','$rep','$rep1','$rep2','$rep3','$rep4','$rep5','$rep6','$rep7','$rep8','$rep9')");
# push(@IdAnimal, $res+1);  }				    					    					
# $sth -> finish;	
