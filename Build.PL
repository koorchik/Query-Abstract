use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Filter::Maker',
    dist_abstract            => 'Create filters in Perlish way and transform them into coderefs or SQL',
    license             => 'perl',
    dist_author         => q{Viktor Turskyi <koorchik@gmail.com>},
    dist_version_from   => 'lib/Filter/Maker.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Filter-Maker-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
