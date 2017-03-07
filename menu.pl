#!/usr/bin/perl
use strict;
use DBI;

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

afficheMenu();
