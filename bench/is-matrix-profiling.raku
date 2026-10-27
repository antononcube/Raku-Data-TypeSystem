#!/usr/bin/env raku
use v6.d;

use Data::TypeSystem::Predicates;

my $nrow = 10;
my $ncol = 1_000;
my @mat = (2.rand xx ($ncol * $nrow)).rotor($ncol);

my $start = now;
my $res = is-matrix(@mat);
my $end = now;
say (:$res, " obtained for {$end - $start} s");