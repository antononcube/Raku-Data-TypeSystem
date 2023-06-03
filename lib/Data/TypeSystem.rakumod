use v6.d;

use Data::TypeSystem::Examiner;

unit module Data::TypeSystem;

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
