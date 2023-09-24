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