package Filter::Maker;

use v5.10;
use strict;
use warnings;

use Class::Load qw/load_class/;
use Carp qw/croak/;

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

        $self->{driver} = $driver_class->new( %{ $driver->[1] || {} } );
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
    my ($self, @filter) = @_;
    @filter = $self->_normalize_filter(@filter);
    return $self->{driver}->make_filter(@filter);
}

sub _normalize_filter {
    my ($self, @filter) = @_;
    return @filter;
}

1; # End of Filter::Maker
