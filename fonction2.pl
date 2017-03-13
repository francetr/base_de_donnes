#!/usr/bin/perl
use strict;
use DBI;


#execute INSERT query
sub modifierAdresse{
    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    
    my $nom = ajoutNom();
    my $prenom =ajoutPrenom();

    my $rue;
    my $codePostal;
    my $commune;
    my $nbHabitantsCommune;
    my $codeDepartement;
    
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
	my $requte=$verifTel->execute();
	while(my $ref2 = $verifTel->fetchrow_hashref()){
	    $tmp= $ref2->{'telexiste'};
	}
	
	#### PAS DE TELEPHONE DANS BASE DE DONNEES  ####
	if ($tmp == 0){
	    print"Pas de poprietaire trouvé pour le téléphone $telephone\n";
	}
	#### TELEPHONE EST DANS BASE DE DONNEES ####
	else{
	    $rue=ajoutRue();
	    $codePostal=ajoutCodePostal();
	    
	    my $tmp2;
	    my $verifCp=$dbh->prepare("SELECT EXISTS (SELECT * FROM Lieu WHERE Lieu.CodePostal = $codePostal ) AS cpExiste");  # requête pour voir si code postal dans BD
	    my $requte=$verifCp->execute();
	    while(my $ref2 = $verifCp->fetchrow_hashref()){
		$tmp2 = $ref2->{'cpexiste'};
	    }
	    ##### CODE POSTAL EXISTE DANS BASE DE DONNEES ######
	    if ($tmp2 == 1){ 
		my $selectCp = $dbh->prepare("SELECT commune,nbhabitantscommune, codedepartement FROM Proprietaire, Lieu WHERE Telephone=$telephone AND Proprietaire.CodePostal=Lieu.CodePostal");
		my $requete2=$selectCp->execute();
		while(my $ref= $selectCp->fetchrow_hashref()){
		    $commune = $ref->{'commune'};
		    $nbHabitantsCommune = $ref->{'nbhabitantscommune'};
		    $codeDepartement = $ref->{'codedepartement'};
		}
		$selectCp->finish;
		$dbh->do("UPDATE Proprietaire SET Rue = '$rue', CodePostal ='$codePostal' WHERE Telephone = '$telephone'");
		$dbh->do("UPDATE Lieu SET CodePostal = '$codePostal', Commune ='$commune', nbHabitantsCommune = '$nbHabitantsCommune' WHERE codePostal = '$codePostal'");
	    }
	    ##### CODE POSTAL PAS DANS BASE DE DONNEES ######
	    else{         
		$commune = ajoutCommune();
		$nbHabitantsCommune = ajoutNbHabitantsCommune();
		$codeDepartement = ajoutCodeDepartement();
		
		$dbh->do("UPDATE Proprietaire SET Rue = '$rue', CodePostal ='$codePostal' WHERE Telephone = '$telephone'");
		$dbh->do("UPDATE Lieu SET CodePostal = '$codePostal', Commune ='$commune', nbHabitantsCommune = '$nbHabitantsCommune' WHERE codePostal = '$codePostal'");
	    }
	    $verifCp->finish;
	}
	$dbh->disconnect();	
    }
}
modifierAdresse();


sub ajoutTelephone{
    print "Indiquer le numéros de téléphone du propriétaire de l'animal (5 chiffres)\n";
    my $telephone = <>; chomp($telephone);
    while($telephone =~/\D/ || $telephone !~/^\d{5}$/ ){
	print "Indiquer le numéros de téléphone du propriétaire de l'animal (5 chiffres)\n";
	my $telephone = <>; chomp($telephone);
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
    while($codePostal =~/\D/ | $codePostal !~/^\d{5,6}$/){
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
    while($nbHabitantsCommune =~/\D/ && $nbHabitantsCommune<=0){
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
