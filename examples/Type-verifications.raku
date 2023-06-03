#!/usr/bin/env perl6

use lib './lib';
use lib '.';

use Data::TypeSystem;
use Data::TypeSystem::Predicates;
use Data::Reshapers;

my @tbl0 = get-titanic-dataset(headers => 'auto');
my @tbl1 = get-titanic-dataset(headers => 'skip');

#note @tbl1.pick(20).raku;
#note @tbl0.pick(20).raku;

say '@tbl0[^2].gist : ', @tbl0[^2].gist;
say '@tbl1[^4].gist : ', @tbl1[^4].gist;

@tbl0 = @tbl0.map({ $_<passengerAge> = $_<passengerAge>.Num; $_ });
@tbl1 = @tbl1.map({ $_[2] = $_[2].Num; $_ });

say @tbl0[^2].raku;

say '@tbl0.&has-homogeneous-shape : ', @tbl0.&has-homogeneous-shape;
say '@tbl0.&has-homogeneous-keys : ', @tbl0.&has-homogeneous-keys;
say '@tbl0.&has-homogeneous-hash-types : ', @tbl0[^12].&has-homogeneous-hash-types;

say '@tbl1.&has-homogeneous-shape : ', @tbl1.&has-homogeneous-shape;
say '@tbl1.&has-homogeneous-keys : ', @tbl1.&has-homogeneous-keys;
say '@tbl1.&has-homogeneous-array-types : ', @tbl1[^12].&has-homogeneous-array-types;
