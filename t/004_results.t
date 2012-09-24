use strict;
use warnings;

use Inquiry::Results;
use Test::More;

my $file = 'test_004.db';

unlink $file;
my $r = Inquiry::Results->new($file);
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

unlink $file;

done_testing();
