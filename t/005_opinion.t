use strict;
use warnings;

use Opinion;
use Test::More;

unlink 'test.db';
my $o = Opinion->new('test.db');
like(ref $o, qr/Opinion/, 'object returned');
$o->save('a0', 1);

$o = Opinion->new('test.db');
$o->save('a1', 2);

$o = Opinion->new('test.db');
is_deeply($o->ids, {a0=>1,a1=>1}, 'ids');

$o = Opinion->new('test.db');
is_deeply($o->retrieve, {a0=>1,a1=>2}, 'ids');


unlink 'test.db';

done_testing();
