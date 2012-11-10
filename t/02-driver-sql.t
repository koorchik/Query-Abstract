#!/usr/bin/perl

use Test::More;

BEGIN {
    use_ok( 'Filter::Maker' ) || print "Bail out!\n";
}

my $fm = Filter::Maker->new( driver => ['SQL' => [ table => 'users' ] ] );
isa_ok($fm, 'Filter::Maker', 'Should create Filter::Maker instance');

subtest 'Simplest "eq" filter' => sub {
    my $sql = $fm->make_filter( [ fname => { eq => 'ivan' } ] );
    is($sql, 'SELECT * FROM users WHERE fname = ?', 'Should return valid SQL');
};

subtest 'Simplest "eq" filter with DESC sort ' => sub {
    my $sql = $fm->make_filter( where => [ fname => { eq => 'ivan' } ], sort_by => 'id DESC' );
    is($sql, 'SELECT * FROM users WHERE fname = ? ORDER BY id DESC', 'Should return valid SQL');
};

subtest 'Simplest "like" filter' => sub {
    my $sql = $fm->make_filter( where => [ lname => { like => 'iva%' } ] );
    is($sql, 'SELECT * FROM users WHERE lname LIKE ?', 'Should return valid SQL');
};

subtest 'Complex filter' => sub {
    my $sql = $fm->make_filter( [
        fname => { eq => 'taras' },
        id => {'<' => 5},
        lname => ['Leleka', 'Ivanov']
    ]);

    is($sql, 'SELECT * FROM users WHERE fname = ? AND id > ? AND lname IN (?, ?)', 'Should return valid SQL');
};


done_testing();