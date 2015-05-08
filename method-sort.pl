#!/usr/bin/env perl

use strict;
use warnings;
use 5.020;
use Path::Tiny;
use File::Find::Rule;
use Data::Compare;

@ARGV or die "Usage: $0 path-to-repo\n";

my $repo = shift;

my @files = File::Find::Rule->file->name('*.pm', '*.pl')->in($repo);

for ( @files ) {
    my $data = path($_)->slurp =~ s/(__DATA__|__END__).+//rs;
    my @methods = $data =~ /^sub\s+(\w+)\s*{/mg;

    my @sorted = sort {
        return 1 if $a =~ /^_/ and $b !~ /^_/;
        return -1  if $a !~ /^_/ and $b =~ /^_/;
        return 0;
    } sort @methods;
    next if Compare(\@methods, \@sorted);

    say "$_ has unsorted methods:";

    my @diff;
    for ( 0..$#methods ) {
        $diff[$_] = $methods[$_] ne $sorted[$_] ? '#' : ' ';
    }

    unshift @diff, ' ';
    unshift @methods, "==Original===";
    unshift @sorted,  "===Sorted===" ;
    my $max = 0;

    length > $max and $max = length for @methods;
    printf "%s %${max}s | %s\n", $diff[$_], $methods[$_], $sorted[$_]
        for 0..$#methods;

    say "\n\n";
}

say "All done!";


__END__