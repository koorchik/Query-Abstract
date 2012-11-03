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
    {id => 3, fname => 'Taras', lname => 'Shevchenko'},
);

subtest 'Simplest "eq" filter' => sub {
    my $filter_sub = $fm->make_filter( where => [ fname => { eq => 'ivan' } ] );
    ok(ref($filter_sub) eq 'CODE', 'Filter should be coderef');

    my $filtered = $filter_sub->(\@objects);
    is($filtered->[0]{id}, 1, 'Hash should be with id=1');
    is($filtered->[1]{id}, 2, 'Hash should be with id=2');
};

subtest 'Simplest "ne" filter' => sub {
    my $filter_sub = $fm->make_filter( where => [ fname => { ne => 'ivan' } ] );
    ok(ref($filter_sub) eq 'CODE', 'Filter should be coderef');

    my $filtered = $filter_sub->(\@objects);
    is($filtered->[0]{id}, 3, 'Hash should be with id=3');
};

subtest 'Simplest "like" filter' => sub {
    my $filter_sub = $fm->make_filter( where => [ lname => { like => 'ivan' } ] );
    ok(ref($filter_sub) eq 'CODE', 'Filter should be coderef');

    my $filtered = $filter_sub->(\@objects);
    is($filtered->[0]{id}, 2, 'Hash should be with id=2');
};

done_testing();