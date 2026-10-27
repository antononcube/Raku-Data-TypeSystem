#!/usr/bin/env raku
use v6.d;

use Data::TypeSystem::Predicates;

# Typical matrix shape from Quantile Regression
my $nrow = 1_000;
my $ncol = 10 + 2 * 1_000;
my @mat = (2.rand xx ($ncol * $nrow)).rotor($ncol);

my $start = now;
my $res = is-matrix(@mat);
my $end = now;
say (:$res, " obtained for {$end - $start} s");