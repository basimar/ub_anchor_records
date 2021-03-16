#! /usr/bin/perl

use warnings;
use strict;

# Skript zur Selektion von Aufnahmen, die in den Alma IZs verankert werden sollen.
# Input 1: Aleph Sequential Datei mit Feld 773 der Aufnahmen ohne Inventar
# Input 2: Systemnummernliste der Aufnahmen, die in die IZ  migriert worden sind
# Autor: Basil Marti (basil.marti@unbas.ch)

die "Argumente: $0 Input (SEQ/773), Input (SYS), Output\n" unless @ARGV == 3;

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

    # Unterfelder von Feld 773 aufsplitten
    my @subfields = split(/\$\$/, $line);
    shift @subfields;

    my $sfw;

    foreach (@subfields) {
        # Unterfeld 773 $w in sfw abspeichern
        if (substr($_,0,1) eq 'w')  {
            $sfw = substr($_,1);
            # Systemnummer in $w auf 9 Stellen ergänzen
            $sfw = sprintf("%09d", $sfw);
        }
    }

    # Prüfen, ob Systemnummer in 773 $w in der Array mit den migrierten Systemnummern vorkommt, wenn ja, Feld 773 ausgeben (relevant ist Position 1-9 von Feld 773, d.h. Systemnummern der Aufnahmen, in denen Feld 773 vorkommt).
    if ($sfw ~~ @lines2 ) { print $out $_ . "\n" };

}

close $out or warn "$0: close $outputfile:: $!";

