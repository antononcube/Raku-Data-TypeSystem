unit module Data::TypeSystem::Predicates;

#------------------------------------------------------------
# From gfldex over Discord #raku channel.
#| Returns True if the argument is a list of hashes or lists that have the same number of elements.
multi has-homogeneous-shape($l) is export {
    so $l[*].&{ $_».elems.all == $_[0].elems }
}

multi has-homogeneous-shape(@l where $_.all ~~ Pair) is export {
    has-homogeneous-shape(@l.map({ .values }))
}

#------------------------------------------------------------
#| Returns True if the argument is a list of hashes and all hashes have the same keys.
sub has-homogeneous-keys(\l) is export {
    l[0].isa(Hash) and so l[*].&{ $_».keys».sort.all == $_[0].keys.sort }
}

#------------------------------------------------------------
#| Returns True if the argument is a positional of Hashes and the value types of all hashes are the same.
sub has-homogeneous-hash-types(\l) is export {
    l[0].isa(Hash) and so l[*].&{ $_.map({ $_.values.map({ $_.^name }) }).all == $_[0].values.map({ $_.^name }) }
}

#------------------------------------------------------------
#| Returns True if the argument is a list of lists and the element types of all lists are the same.
sub has-homogeneous-array-types(\l) is export {
    (l[0].isa(Positional) or l[0].isa(Array)) and so l[*].&{ $_.map({ $_.map({ $_.^name }) }).all == $_[0].map({ $_.^name }) }
}

#------------------------------------------------------------
sub is-array-of-key-array-pairs(@arr) is export {
    ( [and] @arr.map({ is-key-array-pair($_) }) ) and has-homogeneous-shape(@arr)
}

sub is-key-array-pair( $p ) { $p ~~ Pair:D && $p.key ~~ (Str:D | Numeric:D) && $p.value ~~ (Array:D | List:D | Seq:D) }

#------------------------------------------------------------
sub is-array-of-key-hash-pairs(@arr) is export {
    ( [and] @arr.map({ is-key-hash-pair($_) }) ) and has-homogeneous-shape(@arr)
}

sub is-key-hash-pair( $p ) { $p ~~ Pair and $p.key ~~ Str and $p.value ~~ Map }

#------------------------------------------------------------
sub is-array-of-hashes($arr) is export {
    $arr ~~ (Array:D | List:D | Seq:D) && $arr.all ~~ Map:D
}

#------------------------------------------------------------
sub is-array-of-arrays($arr) is export {
    $arr ~~ (Array:D | List:D | Seq:D) && $arr.all ~~ (Array:D | List:D | Seq:D)
}

#------------------------------------------------------------
sub is-hash-of-hashes($obj) is export {
    $obj ~~ Map:D && $obj.values.all ~~ Map:D
}

#------------------------------------------------------------
sub is-array-of-pairs($obj) is export {
    $obj ~~ (Array:D | List:D | Seq:D) && $obj.all ~~ Pair:D
}

#------------------------------------------------------------
sub is-matrix($obj, $type = Numeric:D) is export {
    has-homogeneous-shape($obj) && ([&&] $obj.map({ $_.all ~~ $type }))
}