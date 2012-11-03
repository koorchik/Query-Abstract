#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Filter::Maker' ) || print "Bail out!\n";
}

diag( "Testing Filter::Maker $Filter::Maker::VERSION, Perl $], $^X" );
