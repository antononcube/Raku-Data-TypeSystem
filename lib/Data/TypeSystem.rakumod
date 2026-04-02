use Data::TypeSystem::Examiner;

unit module Data::TypeSystem;

#===========================================================
#| Determines if given data is reshapable.
#| (For example, a Positional of Maps.)
#| C<:$iterable-type> - Expected type of the given argument.
#| C<:$record-type> - Expected type of the elements of the given argument.
our proto is-reshapable($data, |) is export {*}

multi is-reshapable($data, *%args) {
    return Data::TypeSystem::Examiner.is-reshapable($data, |%args);
}

multi is-reshapable($iterable-type, $record-type, $data) {
    Data::TypeSystem::Examiner.is-reshapable($data, :$iterable-type, :$record-type)
}

#===========================================================
#| Returns the record types of the given argument.
our proto record-types($data) is export {*}

multi record-types($data) {
    return Data::TypeSystem::Examiner.record-types($data);
}

#===========================================================
#| Deduces the type of the given argument.
#| C<:$max-enum-elems> -- Max number of enum elements.
#| C<:$max-struct-elems> -- Max number of struct elements.
#| C<:$max-tuple-elems> -- Max number of tuple elements.
#| C<:$tally> -- should tally be returned or not?
our proto deduce-type($data,|) is export {*}

multi deduce-type($data, UInt :$max-enum-elems = 6, UInt :$max-struct-elems = 16, UInt :$max-tuple-elems = 16, Bool :$tally = False) {
    my $ts = Data::TypeSystem::Examiner.new(:$max-enum-elems, :$max-struct-elems, :$max-tuple-elems);
    return $ts.deduce-type($data, :$tally);
}

#===========================================================
#| Determines is a given object a full array.
#| C<$data> -- Data object to be tested.
#| C<:$depth> -- Depth of the full array; an integer, a list of integers, a range, or Whatever.
#| C<:$element-type> -- Type of the array elements.
proto sub is-full-array($data, |) is export {*}

multi sub is-full-array($data, $depth = Whatever, $element-type = Any) {
    is-full-array($data, :$depth, :$element-type);
}

multi sub is-full-array($data, :$depth = Whatever, :$element-type = Any) {

    my $obj = deduce-type($data);
    my @res;
    @res.push($obj.type);
    while $obj.^find_method('type') // Nil {
        @res.push($obj.type);
        $obj .= type
    }

    my $fullArrayVectorsQ = @res.head(*-2).all ~~ Data::TypeSystem::Vector;
    return False unless $fullArrayVectorsQ;

    my $bottomAtomQ = @res[*-2] ~~ Data::TypeSystem::Atom;
    return False unless $bottomAtomQ;

    my $elemTypeQ = @res[*-1] ~~ $element-type;
    return False unless $elemTypeQ;

    my $arr-depth = @res.elems - 2;
    my $depthQ = do given $depth {
        when Whatever { True }
        when Int:D { $arr-depth == $_ }
        when Range:D { $arr-depth ∈ $_.List }
        when $_ ~~ (Array:D | List:D | Seq:D) { $arr-depth ∈ $_ }
        default {
            die 'The argument $depth is expected to be an integer, a list of integers, a range, or Whatever.'
        }
    }
    return $depthQ;
}