use Data::TypeSystem::Predicates;

#===========================================================
role Data::TypeSystem::Type {
    has $.type is rw;
    has $.count is rw;
    submethod BUILD(:$!type = Any, :$!count = 1) {}
    multi method new($type, $count) {
        self.bless(:$type, :$count)
    }
    method Str(-->Str) {
        self.gist;
    }
}

class Data::TypeSystem::Atom
        does Data::TypeSystem::Type {
    method gist(-->Str) {
        'Atom(' ~ $.type.gist ~ ')'
    }
}

class Data::TypeSystem::Pair
        does Data::TypeSystem::Type {
    has $.keyType;

    submethod BUILD(:$!keyType = Any, :$!type = Any, :$!count = Any) {}
    multi method new($keyType, $type) {
        self.bless(:$keyType, :$type)
    }
    method gist(-->Str) {
        'Pair(' ~ $.keyType.gist ~ ', ' ~ $.type.gist ~ ')'
    }
}

class Data::TypeSystem::Vector
        does Data::TypeSystem::Type {
    method gist(-->Str) {
        if $.type.elems == 1 {
            'Vector(' ~ $.type>>.gist.join(', ') ~ ', ' ~ $.count.gist ~ ')'
        } else {
            'Vector([' ~ $.type>>.gist.join(', ') ~ '], ' ~ $.count.gist ~ ')'
        }
    }
}

class Data::TypeSystem::Tuple
        does Data::TypeSystem::Type {
    method gist(-->Str) {
        if $!count == 1 {
            'Tuple([' ~ $.type>>.gist.join(', ') ~ '])'
        } else {
            'Tuple([' ~ $.type>>.gist.join(', ') ~ '], ' ~ $.count.gist ~ ')'
        }
    }
}

class Data::TypeSystem::Assoc
        does Data::TypeSystem::Type {
    has $.keyType;

    submethod BUILD(:$!keyType = Any, :$!type = Any, :$!count = Any) {}
    multi method new($keyType, $type, $count) {
        self.bless(:$keyType, :$type, :$count)
    }

    method gist(-->Str) {
        if $!keyType eq 'Tally' {
            'Assoc([' ~ $.type>>.gist.join(', ') ~ '], ' ~ $.count.gist ~ ')'
        } else {
            'Assoc(' ~ $.keyType.gist ~ ', ' ~ $.type.gist ~ ', ' ~ $.count.gist ~ ')'
        }
    }
}

class Data::TypeSystem::Struct
        does Data::TypeSystem::Type {
    has $.keys;
    has $.values;

    submethod BUILD(:$!keys = Any, :$!values = Any) {}
    multi method new($keys, $values) {
        self.bless(:$keys, :$values)
    }

    method gist(-->Str) {
        'Struct([' ~ $!keys.join(', ') ~ '], [' ~ $!values.map({ $_.^name }).join(', ') ~ '])';
    }
}

#===========================================================

#multi sub circumfix:<%O( )> (@p) { Hash::Ordered.new.STORE: @p }

#===========================================================
class Data::TypeSystem::Examiner {

    has UInt $.max-enum-elems is rw = 6;
    has UInt $.max-struct-elems is rw = 16;
    has UInt $.max-tuple-elems is rw = 16;

    #------------------------------------------------------------
    method has-homogeneous-shape($l) {
        so $l[*].&{ $_».elems.all == $_[0].elems }
    }

    #------------------------------------------------------------
    method has-homogeneous-type($l) {
        if $l.elems > 0 && ($l[0] ~~ Map || $l[0] ~~ List) {
            so $l[*].&{ $_».are.all eqv $_[0]>>.are }
        } else {
            so $l[*].&{ $_».are.all eqv $_[[0,]].are }
        }
    }

    #------------------------------------------------------------
    proto method is-reshapable(|) {*}

    multi method is-reshapable($data, :$iterable-type = Positional, :$record-type = Hash) {
        $data ~~ $iterable-type and ([and] $data.map({ $_ ~~ $record-type }).cache )
    }

    multi method is-reshapable($iterable-type, $record-type, $data) {
        self.is-reshapable($data, :$iterable-type, :$record-type)
    }

    #------------------------------------------------------------
    method record-types($data) {

        my $types;

        given $data {
            when is-array-of-pairs($_) {
                $types = $data>>.are.map({ $_.map({ $_.key => $_.value }).Hash }).List;
            }

            when self.is-reshapable(Positional, Map, $_) {
                $types = $data>>.are.map({ $_.map({ $_.key => $_.value }).Hash }).List;
            }

            when is-hash-of-hashes($_) {
                return %( $_.keys Z=> self.record-types($_.values));
            }

            when $_ ~~ List {
                $types = $_.map({ $_.are }).List;
            }

            when $_ ~~ Map {
                $types = $_.map({ $_.key => $_.value }).Hash;
            }

            default {
                warn 'Do not know how to find the type(s) of the given record(s).';
            }
        }

        return $types;
    }

    #------------------------------------------------------------
    multi method deduce-type($data, Bool :$tally = False) {
        given $data {
            when $_ ~~ Int { return Data::TypeSystem::Atom.new(Int, 1) }
            when $_ ~~ Rat { return Data::TypeSystem::Atom.new(Rat, 1) }
            when $_ ~~ Numeric { return Data::TypeSystem::Atom.new(Numeric, 1) }
            when $_ ~~ Str { return Data::TypeSystem::Atom.new(Str, 1) }
            when $_ ~~ DateTime { return Data::TypeSystem::Atom.new(DateTime, 1) }
            when $_ ~~ Dateish {return Data::TypeSystem::Atom.new(Dateish, 1) }
            when $_ ~~ Pair { return Data::TypeSystem::Pair.new(self.deduce-type($_.key), self.deduce-type($_.value)) }

            when $_ ~~ Seq { return self.deduce-type($data.List); }

            when $_ ~~ List && self.has-homogeneous-type($_) && !($_[0] ~~ Pair) {
                return Data::TypeSystem::Vector.new(self.deduce-type($_[0]), $_.elems)
            }

            when $_ ~~ List {
                my @t = $_.map({ self.deduce-type($_) }).List;
                my $tbag = @t>>.gist.BagHash;
                if $tbag.elems == 1 && !$tally {
                    return Data::TypeSystem::Vector.new(@t[0], $_.elems)
                } elsif $tally {
                    return Data::TypeSystem::Tuple.new($tbag.pairs.sort({ $_.key }).cache, $_.elems)
                }
                if $_.elems ≤ self.max-tuple-elems {
                    return Data::TypeSystem::Tuple.new(@t, 1)
                } else {
                    return Data::TypeSystem::Vector.new(Nil, $_.elems)
                }
            }

            when is-hash-of-hashes($_) {
                my $kType = self.deduce-type($_.keys[0], :$tally);
                my $vType = self.deduce-type($_.values.List, :$tally);

                if $vType ~~ Data::TypeSystem::Vector {
                    return Data::TypeSystem::Assoc.new( keyType => $kType, type => $vType.type, count => $_.elems)
                }
                return Data::TypeSystem::Assoc.new( keyType => $kType, type => $vType, count => $_.elems)
            }

            when $_ ~~ Hash {
                my @res = |$_>>.are.sort({ $_.key }).cache;
                if !self.has-homogeneous-type($_.values) && $_.elems ≤ self.max-struct-elems  {
                    return Data::TypeSystem::Struct.new(keys => @res>>.key.List, values => @res>>.value.List);
                } elsif self.has-homogeneous-type($_.values) {
                    return Data::TypeSystem::Assoc.new(keyType => self.deduce-type($_.keys[0]), type => self.deduce-type($_.values[0]), count => $_.elems);
                } elsif $tally {
                    my @t = $_.pairs.map({ self.deduce-type($_) }).Array;
                    my $tbag = @t>>.gist.BagHash;
                    return Data::TypeSystem::Assoc.new(keyType => 'Tally', type => $tbag.pairs.sort(*.key).cache, count => $_.elems );
                } else {
                    return Data::TypeSystem::Assoc.new(keyType => self.deduce-type($_.keys.List):tally, type => self.deduce-type($_.values.List):tally, count => $_.elems);
                }
            }

            default { Any }
        }
    }
}