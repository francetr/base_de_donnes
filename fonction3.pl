#!/usr/bin/perl
use strict;
use DBI;

sub ajoutVaccin(){
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});

    my $anneeNaissance;
    my $vaccin1;
    my $vaccin2;
    my $vaccin3;

    print "Indiquer l'id de l'animal pour lequel vous voulez ajouter le vaccin\n";
    my $id=<>; chomp($id);

    my $tmp;
    my $verifId = $dbh->prepare("SELECT EXISTS (SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND Animal.IdAnimal = $id) AS IdExiste");
    my $requete=$verifId->execute();
    while(my $ref = $verifId->fetchrow_hashref()){
	    $tmp= $ref->{'idexiste'};
    }

    ######## ID PAS DANS BD #########
    if ($tmp == 0){
	print"Pas d'identifiant $id trouvé dans la base de données\n";
    }
    
    ############ ID DANS BD #############
    else{
	my $selectAnimaux = $dbh->prepare("SELECT * FROM Animal, Suivie WHERE Animal.IdAnimal = Suivie.IdAnimal AND Animal.IdAnimal = $id\n");
	my $requete = $selectAnimaux->execute();
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
		my $verifVaccin1 = $dbh->prepare("SELECT EXISTS (SELECT Vaccin1 FROM Suivie WHERE IdAnimal = $id AND Vaccin1 =0 ) AS vaccin1Existe");
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
		my $verifVaccin2 = $dbh->prepare("SELECT EXISTS (SELECT Vaccin2 FROM Suivie WHERE IdAnimal = $id AND Vaccin2 =0) AS vaccin2Existe");
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
		my $verifVaccin3 = $dbh->prepare("SELECT EXISTS (SELECT Vaccin3 FROM Suivie WHERE IdAnimal = $id AND Vaccin3 =0) AS vaccin3Existe");
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
    $dbh->disconnect();
}

ajoutVaccin();

sub ajoutVaccin1{
    my($an) = @_;
    print "Indiquer l'année ou l'animal à reçu le vaccin1 (0 sinon)\n";
    my $vaccin1 = <>; chomp($vaccin1);
    while($vaccin1 =~/^[^0]+/ && $vaccin1<$an && $vaccin1 =~/\D/ && $vaccin1 !~/^\d{4}$/){
	print "Indiquer l'année ou l'animal à reçu le vaccin1 (0 sinon)\n";
	$vaccin1 = <>; chomp($vaccin1);
    }
    return $vaccin1;
}


sub ajoutVaccin2{
    my($an) = @_;
    print "Indiquer l'année ou l'animal à reçu le vaccin2 (0 sinon)\n";
    my $vaccin2 = <>; chomp($vaccin2);
    while($vaccin2 =~/^[^0]+/ && $vaccin2<$an && $vaccin2 =~/\D/ && $vaccin2 !~/^\d{4}$/){
	print "Indiquer l'année ou l'animal à reçu le vaccin2 (0 sinon)\n";
	$vaccin2 = <>; chomp($vaccin2);
    }
    return $vaccin2;
}

sub ajoutVaccin3{
    my($an) = @_;
    print "Indiquer l'année ou l'animal à reçu le vaccin3 (0 sinon)\n";
    my $vaccin3 = <>; chomp($vaccin3);
    while($vaccin3 =~/^[^0]+/ && $vaccin3<$an && $vaccin3 =~/\D/ && $vaccin3 !~/^\d{4}$/ ){
	print "Indiquer l'année ou l'animal à reçu le vaccin3 (0 sinon)\n";
	$vaccin3 = <>; chomp($vaccin3);
    }
    return $vaccin3;
}
