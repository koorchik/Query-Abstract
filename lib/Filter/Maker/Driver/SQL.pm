package Filter::Maker::Driver::SQL;

use v5.10;
use strict;
use warnings;

use Data::Dumper;
use Carp;

use base 'Filter::Maker::Driver::Base';

my %COND_MAKERS = (
    'eq'   => sub {"$_[0] = ?" },
    'ne'   => sub {"$_[0] != ?" },
    'lt'   => sub {"$_[0] < ?" },
    'le'   => sub {"$_[0] <= ?" },
    'gt'   => sub {"$_[0] > ?" },
    'ge'   => sub {"$_[0] >= ?" },
    '<'    => sub {"$_[0] > ?" },
    '>'    => sub {"$_[0] < ?" },
    '<='   => sub {"$_[0] <= ?" },
    '>='   => sub {"$_[0] >= ?" },
    'in'   => sub {"$_[0] IN (" . join(', ', ('?') x @{$_[1]} ) . ")"},
    'like' => sub {"$_[0] LIKE ?" },
);

sub  new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new(%args);
    croak "Table name is required!" unless $self->{table};

    return $self;
}

sub make_filter {
    my ($self, %query) = @_;

    my $select_sql = "SELECT * FROM $self->{table}";

    my $where_sql = $self->make_tester( $query{where} );
    $select_sql .= " $where_sql" if $where_sql;

    my $sort_sql   = $self->make_sorter( $query{sort_by} );
    $select_sql .= " $sort_sql" if $sort_sql;
    
    return $select_sql;
}


sub make_tester {
    my ( $self, $where ) = @_;

    my @rules;
    my @bind;
    for ( my $i = 0; $i < @$where; $i += 2 ) {
        my $field = $where->[$i];
        my $condition = $where->[$i+1];
        my ($oper, $values) = %$condition;
        push @rules, $COND_MAKERS{$oper}->($field, $values);
    }

    if (@rules) {
        return 'WHERE ' . join(' AND ', @rules);
    } else {
        return '';
    }
}

sub make_sorter {
    my ( $self, $sort_by ) = @_;
    my @rules;

    foreach my $sort_rule ( @$sort_by ) {
        my ($field, $order) = split(/\s+/, $sort_rule, 2);
        $order ||='ASC';

        push @rules, "$field \U$order";
    }

    if (@rules) {
        return @rules ? 'ORDER BY ' . join(' ,', @rules) : ''; 
    } else {
        return '';
    }
}

1;