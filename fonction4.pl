
#!/usr/bin/perl
use strict;
use DBI;
#connect
my $dbh = DBI->connect("DBI:Pg:dbname=tfrances;host=dbserver","tfrances", "", {'RaiseError' => 1});
#execute INSERT query
sub afficheChat{
    print "Voici la liste de tous les chats enregistres";
    my $requete = $dbh->do("Select * From Animal, Suivie WHERE Animal = 'Chat' OR Animal ='chat'"); 
}

afficheChat();

$dbh->disconnect();
