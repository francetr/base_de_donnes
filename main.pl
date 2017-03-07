#!/usr/bin/perl
use strict;
use DBI;

####### Contient les choix de l'utilisateur

#connect
my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
#execute INSERT query


while (1){
    #afficheMenu();
    my $choix = <>;
    if($choix==1){
	#ajoutAnimal();
	;
    }
    elsif ($choix==2){
	#modifierAdresse();
	print"Bravo\n";
    }
    elsif ($choix==3){
	#ajoutVaccin();
	print"Bravo\n";
    }
    elsif ($choix==4){
	print"Bravo\n";
    }
    elsif ($choix==5){
	print"Bravo\n";
    }
    elsif ($choix==6){
	print"Bravo\n";
    }
    elsif ($choix==7){
	print"Bravo\n";
    }
    elsif ($choix==8){
	print"Bravo\n";
    }
    elsif ($choix==9){
	print"Bravo\n";
    }
    else{
	last;
    }

}


$dbh->disconnect();
