package Filter::Maker::Driver::ArrayOfHashes;

use v5.10;
use strict;
use warnings;

use Data::Dumper;

use base 'Filter::Maker::Driver::Base';

my %CHECKERS = (
    eq   => sub { lc($_[0]) eq lc($_[1]) },
    ne   => sub { lc($_[0]) ne lc($_[1]) },
    in   => sub { scalar( grep { lc($_[0]) eq lc($_)} @{$_[1]} ) },
    like => sub {
        my ($value, $pattern) = @_;
        $pattern = quotemeta($pattern);
        $pattern =~ s/\%/.*/;
        return $value =~ m/$pattern/i;
    }
);

sub make_filter {
    my ($self, %filter) = @_;

    my $where = $filter{where};

    my @checkers;
    for ( my $i = 0; $i < @$where; $i+=2 ) {
        my $field = $where->[$i];
        my $condition = $where->[$i+1];
        my ($oper, $restriction) = %$condition;
        my $checker = $CHECKERS{oper};

        push @checkers, $self->_make_checker( $field, $oper, $restriction );
    }

    return sub {
        my $array = shift;
        my @filtered;
        foreach my $h ( @$array ) {
            my $count = grep { $_->($h) } @checkers;
            next if $count != @checkers;
            push @filtered, $h;
        }

         return \@filtered;
    }
}

sub _make_checker {
    my ($self, $field, $oper, $restriction) = @_;
    return sub {  $CHECKERS{$oper}->( $_[0]->{$field}, $restriction ) };
}


1;