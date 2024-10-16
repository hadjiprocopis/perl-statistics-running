# NAME

Statistics::Running - Basic descriptive statistics (mean/stdev/min/max/skew/kurtosis) and discrete Probability Distribution (via histogram) over data without the need to store data points ever. OOP style.

# VERSION

Version 0.14

# SYNOPSIS

         use Statistics::Running;
         my $ru = Statistics::Running->new();
         for(1..100){
                 $ru->add(rand());
         }
         print "mean: ".$ru->mean()."\n";
         $ru->add(12345);
         print "mean: ".$ru->mean()."\n";

         my $ru2 = Statistics::Running->new();
         $ru2->histogram_enable({
                 'num-bins' => 10,
                 'bin-width' => 0.01,
                 'left-boundary' => 0
         });
         for(1..100){
                 $ru2->add(rand());
         }
         print "Probability Distribution of data:\n".$ru2->histogram_stringify()."\n";

         # add two stat objects together (histograms are not!)
         my $ru3 = $ru + $ru2;
         print "mean of concatenated data: ".$ru3->mean()."\n";

         $ru += $ru2;
         print "mean after appending data: ".$ru->mean()."\n";

         print "stats: ".$ru->stringify()."\n";

         # example output:
         print $ru2."\n";
 N: 100, mean: 0.488978434779093, range: 0.0056063539679414 to 0.99129297226348, standard deviation: 0.298129905728534, kurtosis: -1.22046199974301, skewness: -0.0268827866000826, histogram:
    0.000 -    0.010:     2 #####################################################
    0.010 -    0.020:     2 #####################################################
    0.020 -    0.030:     2 #####################################################
    0.030 -    0.041:     2 #####################################################
    0.041 -    0.051:     1 ###########################
    0.051 -    0.062:     0 |
    0.062 -    0.073:     2 #####################################################
    0.073 -    0.083:     0 |
    0.083 -    0.094:     1 ###########################

# DESCRIPTION

Statistics are updated every time a new data point
is added in. The common practice to calculate descriptive
statistics for 5 data points as well as 1 billion points
is to store them in an array,
loop over the array to calculate the mean, then loop over the array
again to calculate standard deviation, as Sum (x\_i-mean)\*\*2.
Standard deviation is the reason data is stored in the array.
This module uses B.P.Welford's method to calculate descriptive
statistics by continually adjusting the stats and not storing
a single data point. Except from the computational and environmental
benefits of such an approach, B.P.Welford's method is also
immune to accumulated precision errors. It is stable and accurate.

For more details on the method and its stability look at this:
[John D. Cook's article and C++ implementation](https://www.johndcook.com/blog/skewness_kurtosis)

A version without the histogram exists under [Statistics::Running::Tiny](https://metacpan.org/pod/Statistics%3A%3ARunning%3A%3ATiny)
and is faster, obviously. About 25% faster.

There are three amazing things about B.P.Welford's algorithm implemented here:

- 1. It calculates and keeps updating mean/standard-deviation etc. on 
data without the need to store that data. As new data comes in, the
statistics are updated based on the state of a few variables (mean, number
of data points, etc.) but not the past data points. This includes the
calculation of standard deviation which most of us knew (wrongly) that
it requires a second pass on the data points, after the mean is calculated.
Well, B.P.Welford found a way to avoid this.
- 2. The standard formula for standard deviation requires to sum
the square of the difference of each sample from the mean.
If samples are large numbers then you are summing differences of large
numbers. If further there is little difference between samples, and the
discrepancy from the mean is small, then you are prone to
precision errors which accumulate to destructive effect if the number of
samples is large. In contrast,  B.P.Welford's algorithm does
not suffer from this, it is stable and accurate.
- 3. B.P.Welford's online statistics algorithm
is quite a revolutionary idea and why is not an obligatory subject
in first-year programming courses is beyond comprehension.
Here is a way to decrease those CO2 emissions.

The basis for the code in this module comes from
[John D. Cook's article and C++ implementation](https://www.johndcook.com/blog/skewness_kurtosis)

# EXPORT

Nothing, this is an Object Oriented module. Once you instantiate
an object all its methods are yours.

# SUBROUTINES/METHODS

## new

Constructor, initialises internal variables.

## add

Update our statistics after one more data point/sample (or an
array of them) is presented to us.

        my $ru1 = Statistics::Running->new();
        for(1..100){
                $ru1->add(rand());
                print $ru1."\n";
        }

Input can be a single data point (a scalar) or a reference
to an array of data points.

## copy\_from

Copy state of input object into current effectively making us like
them. Our previous state is forgotten. After that adding a new data point into
us will be with the new state copied.

        my $ru1 = Statistics::Running->new();
        for(1..100){
                $ru1->add(rand());
        }
        my $ru2 = Statistics::Running->new();
        for(1..100){
                $ru2->add(rand());
        }
        # copy the state of ru1 into ru2. state of ru1 is forgotten.
        $ru2->copy_from($ru1);

## clone

Clone state of our object into a newly created object which is returned.
Our object and returned object are identical at the time of cloning.

        my $ru1 = Statistics::Running->new();
        for(1..100){
                $ru1->add(rand());
        }
        my $ru2 = $ru1->clone();

## clear

Clear our internal state as if no data points have ever been added into us.
As if we were just created. All state is forgotten and reset to zero, including histogram.

## mean

Returns the mean of all the data pushed in us

## sum

Returns the sum of all the data pushed in us (algebraic sum, not absolute sum)

## abs\_sum

Returns the sum of the absolute value of all the data pushed in us (this is not algebraic sum)

## min

Returns the minimum data sample added in us

## max

Returns the maximum data sample added in us

## get\_N

Returns the number of data points/samples inserted, and had
their descriptive statistics calculated, so far.

## variance

Returns the variance of the data points/samples added onto us so far.

## standard\_deviation

Returns the standard deviation of the data points/samples added onto us so far. This is the square root of the variance.

## skewness

Returns the skewness of the data points/samples added onto us so far.

## kurtosis

Returns the kurtosis of the data points/samples added onto us so far.

## concatenate

Concatenates our state with the input object's state and returns
a newly created object with the combined state. Our object and
input object are not modified. The overloaded symbol `+` points
to this sub.

## append

Appends input object's state into ours.
Our state is modified. (input object's state is not modified)
The overloaded symbol `+=` points
to this sub.

## histogram\_enable

Enables histogram logging by creating a histogram with specified
parameters. These parameters can be of different formats:

        my $ru1 = Statistics::Running->new();
        $ru1->histogram_enable({
                'num-bins' => 10,
                'bin-width' => 0.01,
                'left-boundary' => 0
        });
        # or, 2 bins: 0-1 and 1-2
        $ru1->histogram_enable({
                '0:1' => 0,
                '1:2' => 1,
        });
        # or, 2 bins: 0-1 and 1-2
        $ru1->histogram_enable([0,1,2]);

- 1. by specifying the number of bins, bin-width and left boundary as a
parameters hash, e.g.
    $ru->enable\_histogram({
        'num-bins'=>5,
        'bin-width'=>1,
        'left-boundary'=>-2
    });
- 2. by specifying a HASH where keys are 'FROM:TO' and values are the bin counts,
which can be zero, or even a positive integer if you want to start with some counts already.
- 3. ARRAY of bin boundaries of the form

        [
           histo-left-boundary,
           bin1_right_boundary,
           bin2_right_boundary,
           ...
           binN-1_right_boundary,
           histo-right-boundary
        ]

    It follows that the number of bins will be 1 less than the length of this array.

## histogram\_disable

Disable histogram logging, all existing histogram data is erased. Number of bins
is forgotten, along with bin boundaries, etc.

## histogram\_reset

Set existing histogram to zero counts.

## histogram\_count 

Returns the count in bin specified by bin index (which is 0 to number-of-bins - 1)

## equals

Check if our state (number of samples and all internal state) is
the same with input object's state. Equality here implies that
ALL statistics are equal (within a small number Statistics::Running::SMALL\_NUMBER\_FOR\_EQUALITY)

## equals\_statistics

Check if our statistics only (and not sample size)
are the same with input object. E.g. it checks mean, variance etc.
but not sample size (as with the real equals()).
It returns 0 on non-equality. 1 if equal.

## equals\_histograms

Check if our histogram only (and not statitstics)
are the same with input object.
It returns 0 on non-equality. 1 if equal.

## stringify

Returns a string description of descriptive statistics we know about
(mean, standard deviation, kurtosis, skewness) as well as the
number of data points/samples added onto us so far. Note that
this method is not necessary because stringification is overloaded
and the follow `print $stats_obj."\n"` is equivalent to
`print $stats_obj->stringify()."\n"`

# Overloaded functionality

- 1. Addition of two statistics objects: `my $ru3 = $ru1 + $ru2`
- 2. Test for equality: `if( $ru2 == $ru3 ){ ... }`
- 3. Stringification: `print $ru1."\n"`

# Testing for Equality

In testing if two objects are the same, their means, standard deviations
etc. are compared. This is done using
`if( ($self->mean() - $other->mean()) < Statistics::Running::SMALL_NUMBER_FOR_EQUALITY ){ ... }`

# BENCHMARKS

Run `make bench` for benchmarks which report the maximum number of data points inserted
per second (in your system).

# SEE ALSO

- 1. [Wikipedia](http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Online_algorithm)
- 2. [John D. Cook's article and C++ implementation](https://www.johndcook.com/blog/skewness_kurtosis)
was used both as inspiration and as the basis for the formulas for
`kurtosis()` and `skewness()`
- 3. [Statistics::Welford](https://metacpan.org/pod/Statistics%3A%3AWelford) This module is equivalent but it
does not provide `kurtosis()` and `skewness()` which
current module does. Additionally,
current module builds a Histogram for inserted data as a discrete
approximation of the Probability Distribution data comes from.
- 4. [Statistics::Running::Tiny](https://metacpan.org/pod/Statistics%3A%3ARunning%3A%3ATiny) This is the exact same module but
without histogram capabilities. That makes it
a bit faster than current module only when data is inserted.
Space-wise, the histogram does not take much
space. It is just an array of bins and the number
of items (not the original data items themselves!) it contains.
Run `make bench` to get a report on the maximum number
of data point insertions per unit time in your system.
[Statistics::Running::Tiny](https://metacpan.org/pod/Statistics%3A%3ARunning%3A%3ATiny) is approximately 25% faster than this module.

# AUTHOR

Andreas Hadjiprocopis, `<bliako at cpan.org>`

# BUGS

Please report any bugs or feature requests to `bug-statistics-running at rt.cpan.org`, or through
the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Statistics-Running](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Statistics-Running).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Statistics::Running

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [http://rt.cpan.org/NoAuth/Bugs.html?Dist=Statistics-Running](http://rt.cpan.org/NoAuth/Bugs.html?Dist=Statistics-Running)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Statistics-Running](http://annocpan.org/dist/Statistics-Running)

- Review this module at PerlMonks

    [https://www.perlmonks.org/?node\_id=21144](https://www.perlmonks.org/?node_id=21144)

- Search CPAN

    [http://search.cpan.org/dist/Statistics-Running/](http://search.cpan.org/dist/Statistics-Running/)

# DEDICATIONS

Almaz

# ACKNOWLEDGEMENTS

B.P.Welford, John Cook.

# LICENSE AND COPYRIGHT

Copyright 2018-2019 Andreas Hadjiprocopis.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
