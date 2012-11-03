#!/usr/bin/perl

use Test::More;

BEGIN {
    use_ok( 'Filter::Maker' ) || print "Bail out!\n";
}

my $fm = Filter::Maker->new( driver => ['ArrayOfHashes'] );
isa_ok($fm, 'Filter::Maker', 'Should create Filter::Maker instance');

my @objects = (
    {id => 1, fname => 'Ivan',  lname => 'Pupkin'},
    {id => 2, fname => 'Ivan',  lname => 'Ivanov'},
    {id => 3, fname => 'Taras', lname => 'Shevchenko'},
    {id => 4, fname => 'Taras', lname => 'Leleka'},
    {id => 5, fname => 'Taras', lname => 'Leleka'},
);

subtest 'Simplest "eq" filter' => sub {
    my $filter_sub = $fm->make_filter( [ fname => { eq => 'ivan' } ] );
    ok(ref($filter_sub) eq 'CODE', 'Filter should be a coderef');

    my $filtered = $filter_sub->(\@objects);
    is(scalar(@$filtered), 2, 'Should return 2 hashes with fname eq "ivan"' );
    is($filtered->[0]{id}, 1, 'Hash should be with id=1');
    is($filtered->[1]{id}, 2, 'Hash should be with id=2');
};

subtest 'Simplest "eq" filter with DESC sort ' => sub {
    my $filter_sub = $fm->make_filter( where => [ fname => { eq => 'ivan' } ], sort_by => 'id DESC' );
    ok(ref($filter_sub) eq 'CODE', 'Filter should be a coderef');

    my $filtered = $filter_sub->(\@objects);
    is(scalar(@$filtered), 2, 'Should return 2 hashes with fname eq "ivan"' );
    is($filtered->[0]{id}, 2, 'Hash should be with id=2');
    is($filtered->[1]{id}, 1, 'Hash should be with id=1');
};

subtest 'Simplest "like" filter' => sub {
    my $filter_sub = $fm->make_filter( where => [ lname => { like => 'iva%' } ] );
    ok(ref($filter_sub) eq 'CODE', 'Filter should be coderef');

    my $filtered = $filter_sub->(\@objects);
    is(scalar(@$filtered), 1, 'Should return only one hash with lname like "iva%"' );
    is( $filtered->[0]{id}, 2, 'Hash should be with id=2' );
};


subtest 'Complex filter' => sub {
    my $filter_sub = $fm->make_filter( [
        fname => { eq => 'taras' },
        id => {'<' => 5},
        lname => ['Leleka', 'Ivanov']
    ]);

    ok(ref($filter_sub) eq 'CODE', 'Filter should be coderef');

    my $filtered = $filter_sub->(\@objects);
    is(scalar(@$filtered), 1, 'Should return only one hash' );
    is( $filtered->[0]{id}, 4, 'Hash should be with id=4' );
};

done_testing();