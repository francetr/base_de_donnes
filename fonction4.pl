
#!/usr/bin/perl
use strict;
use DBI;
#connect

#execute INSERT query
sub afficheChat{

    my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
    print "Voici la liste de tous les chats enregistrés";
    my $selectChat = $dbh->prepare("Select * From Animal, Suivie WHERE Animal = 'Chat' OR Animal ='chat'");
    my $requete = $selectChat->execute();
    while(my $ref= $selectChat->fetchrow_hashref()){

	print "$ref->{'idanimal'} $ref->{'nomanimal'} $ref->{'couleur'} $ref->{'sexe'} $ref->{'anneenaissance'} $ref->{'sterilise'} $ref->{'vaccin1'} $ref->{'vaccin2'} $ref->{'vaccin3'}";
    }

    $selectChat->finish();
    $dbh->disconnect();

}

afficheChat();

