#! /usr/bin/perl

use warnings;
use strict;

# Skript zur Selektion von Aufnahmen, die in den Alma IZs verankert werden sollen.
# Input 1: Aleph Sequential Datei mit Feld 490 der Aufnahmen, die in die IZ migriert worden sind
# Input 2: Systemnummernliste der Aufnahmen ohne Inventar
# Autor: Basil Marti (basil.marti@unbas.ch)

die "Argumente: $0 Input (SEQ/490), Input (SYS), Output\n" unless @ARGV == 3;

my($input1file,$input2file,$outputfile) = @ARGV;

# 1. Inputdatei öffnen und in Array einlesen
open my $handle1, '<', $input1file or die "$0: open $input1file: $!";
chomp(my @lines1 = <$handle1>);
close $handle1;

# 2. Inputdatei öffnen und in Array einlesen
open my $handle2, '<', $input2file or die "$0: open $input2file: $!";
chomp(my @lines2 = <$handle2>);
close $handle2;

open my $out, ">", $outputfile or die "$0: open $outputfile: $!";

for (@lines1) {

    #print $_ . "\n";

    my $line = $_;
    chomp $line;

    # Unterfelder von Feld 490 aufsplitten
    my @subfields = split(/\$\$/, $line);
    shift @subfields;

    my $sfw;

    foreach (@subfields) {
        # Unterfeld 490 $w in sfw abspeichern
        if (substr($_,0,1) eq 'w')  {
            $sfw = substr($_,1);
            # Systemnummer in $w auf 9 Stellen ergänzen
            $sfw = sprintf("%09d", $sfw);
        }
    }
    
    # Prüfen, ob Systemnummer in 490 $w in der Array mit den Aufnahmen ohne Inventar vorkommt, wenn ja, Systemnummer in 490 $w ausgeben
    if ($sfw ~~ @lines2 ) { print $out $sfw . "\n" };

}

close $out or warn "$0: close $outputfile:: $!";

