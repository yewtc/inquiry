use strict;
use warnings;

use Results;
use Test::More;

unlink 'test.db';
my $r = Results->new('test.db');
like(ref $r, qr/Results/, 'object returned');
$r->init(4);
$r->save(qw/qan1-2 on
            qn4-3  on
            qn2-2  on
            qn2-3  on
            qan3-1 on
            r3-1    2
            qn4-1  on
             r4-1   1
            qn4-2  on
             r4-2   2
           /);

is_deeply($r->retrieve,
          { $r->{id} => [2, '2,3', '1:2', '1:1,2:2,3']},
          'all values stored');

unlink 'test.db';

done_testing();
