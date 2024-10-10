#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

our $VERSION = 0.14;

plan tests => 1;

BEGIN {
    use_ok( 'Statistics::Running' ) || print "Bail out!\n";
}

diag( "Testing Statistics::Running $Statistics::Running::VERSION, Perl $], $^X" );
