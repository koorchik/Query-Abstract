package Filter::Maker;

use v5.10;
use strict;
use warnings;

use Class::Load qw/load_class/;
use Carp qw/croak/;
use Data::Dumper;

our $VERSION = '0.01';

sub new {
    my $class  = shift;
    my %args   = @_;
    my $driver = $args{driver};
    croak "Wrong driver" unless ref $driver;

    my $self = bless {}, $class;

    if ( ref $driver eq 'ARRAY' ) {
        my $driver_class = 'Filter::Maker::Driver::' . $driver->[0];
        load_class($driver_class);

        $self->{driver} = $driver_class->new( @{ $driver->[1] || [] } );
    } elsif ( $driver->isa('Filter::Maker::Driver::Base') ) {
        $self->{driver} = $driver;
    } else {
        croak "Wrong driver [$driver]";
    }

    $self->init();

    return $self;
}

sub init {
    my $self = shift;
    $self->{driver}->init(@_);
}


sub make_filter {
    my ($self, @args) = @_;
    my %query = $self->_normalize_query(@args);
    return $self->{driver}->make_filter(%query);
}

sub _normalize_query {
    my $self = shift;
    my %query;

    if ( ref($_[0]) eq 'ARRAY' ) {
        $query{where} = $_[0];
    } else {
        %query = @_;
    }

    my $where   = $self->_normalize_where($query{where});
    my $sort_by = $self->_normalize_sort_by($query{sort_by});

    return (
        where   => $where,
        sort_by => $sort_by
    );
}

sub _normalize_where {
    my ($self, $where) = @_;
    return [] unless $where;

    my @norm_where;

    for (my $i = 0; $i < @$where; $i+=2) {
        my $field = $where->[$i];
        my ($oper, $restriction);
        if ( ref($where->[$i+1]) eq 'HASH' ) {
            my $condition = $where->[$i+1];
            ($oper, $restriction) = %$condition;
        } else {
            $oper = ref($where->[$i+1]) eq 'ARRAY' ? 'in' : 'eq';
            $restriction = $where->[$i+1];
        }

        die "UNSUPPORTED OPERATOR [$oper]" unless $oper ~~ [qw/eq in ne gt lt le gt ge like < > <= >=/];

        push @norm_where, $field => {$oper => $restriction} ;

    }

    return \@norm_where;
}

sub _normalize_sort_by {
    my ($self, $sort_by) = @_;
    return [] unless $sort_by;
    return [ split(/\s*,\s*/, $sort_by, 2) ];
}

1; # End of Filter::Maker
