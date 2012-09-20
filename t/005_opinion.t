use strict;
use warnings;

use Opinion;
use Test::More;

my $file = 'test_005.db';

unlink $file;
my $o = Opinion->new($file);
like(ref $o, qr/Opinion/, 'object returned');
$o->save('a0', 1);

$o = Opinion->new($file);
$o->save('a1', 2);

$o = Opinion->new($file);
is_deeply($o->ids, {a0=>1,a1=>1}, 'ids');

$o = Opinion->new($file);
is_deeply($o->retrieve, {a0=>1,a1=>2}, 'ids');


unlink $file;

done_testing();
