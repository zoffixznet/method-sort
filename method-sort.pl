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
    my @methods = path($_)->slurp =~ /^sub\s+(\w+)\s*{/mg;
    # use Acme::Dump::And::Dumper;
    # die DnD [ @methods ];
    my @sorted = sort @methods;
    next if Compare(\@methods, \@sorted);

    say "$_ has unsorted methods:";

    unshift @methods, "==Original===";
    unshift @sorted,  "===Sorted===" ;
    my $max = 0;
    length > $max and $max = length for @methods;
    printf "%${max}s | %s\n", $methods[$_], $sorted[$_]
        for 0..$#methods;

    say "\n\n";
}

say "All done!";


__END__