# Raku Data::TypeSystem

[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

This Raku package provides a type system for different data structures that are 
coercible to full arrays. Its code was originally developed in 
["Data::Reshapers"](https://github.com/antononcube/Raku-Data-Reshapers), [AAp1].


------

## Installation

From [Zef ecosystem](https://raku.land):

```
zef install Data::TypeSystem
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Data-TypeSystem.git
```

------

## Usage examples

The type system conventions follow those of Mathematica's 
[`Dataset`](https://reference.wolfram.com/language/ref/Dataset.html) 
-- see the presentation 
["Dataset improvements"](https://www.wolfram.com/broadcast/video.php?c=488&p=4&disp=list&v=3264).

Here we get the Titanic dataset, change the "passengerAge" column values to be numeric, 
and show dataset's dimensions:

```perl6
use Data::ExampleDatasets;
my $url = 'https://raw.githubusercontent.com/antononcube/Raku-Data-Reshapers/main/resources/dfTitanic.csv';
my @dsTitanic = example-dataset($url, headers => 'auto');
@dsTitanic = @dsTitanic.map({$_<passengerAge> = $_<passengerAge>.Numeric; $_}).Array;
@dsTitanic.elems
```
```
# 1309
```

Here is a sample of dataset's records:

```perl6
.say for @dsTitanic.pick(5)
```
```
# {id => 1097, passengerAge => 0, passengerClass => 3rd, passengerSex => male, passengerSurvival => died}
# {id => 1018, passengerAge => 20, passengerClass => 3rd, passengerSex => male, passengerSurvival => survived}
# {id => 31, passengerAge => 40, passengerClass => 1st, passengerSex => male, passengerSurvival => died}
# {id => 1030, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died}
# {id => 126, passengerAge => -1, passengerClass => 1st, passengerSex => male, passengerSurvival => died}
```

Here is the type of a single record:

```perl6
use Data::TypeSystem;
deduce-type(@dsTitanic[12])
```
```
# Struct([id, passengerAge, passengerClass, passengerSex, passengerSurvival], [Int, Int, Str, Str, Str])
```

Here is the type of single record's values:

```perl6
deduce-type(@dsTitanic[12].values.List)
```
```
# Tuple([Atom((Int)), Atom((Str)), Atom((Str)), Atom((Str)), Atom((Int))])
```

Here is the type of the whole dataset:

```perl6
deduce-type(@dsTitanic)
```
```
# Vector(Struct([id, passengerAge, passengerClass, passengerSex, passengerSurvival], [Int, Int, Str, Str, Str]), 1309)
```

Here is the type of "values only" records:

```perl6
my @valArr = @dsTitanic>>.values>>.Array;
deduce-type(@valArr)
```
```
# Vector((Any), 1309)
```

Here is the type of the string values only records:

```perl6
my @valArr = @dsTitanic.map({ $_.grep({ $_.value ~~ Str }).Hash })>>.values>>.Array;
.say for @valArr.pick(4);
```
```
# [1st male died]
# [3rd male died]
# [male died 3rd]
# [died 3rd male]
```

```perl6
deduce-type(@valArr);
```
```
# Vector(Vector(Atom((Str)), 3), 1309)
```

-------

## References

[AAp1] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube/).

