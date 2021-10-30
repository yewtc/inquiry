use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Inquiry',
    AUTHOR              => q{E. Choroba <choroba@email.cz>},
    VERSION_FROM        => 'lib/Inquiry.pm',
    ABSTRACT            => 'Tool to create online surveys.',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? (LICENSE => 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'  => 0,
        'YAML'        => 0,
        'Dancer'      => 1.3097,
        'DBD::SQLite' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Inquiry-*' },
);
