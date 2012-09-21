use strict;
use warnings;

use Opinion;
use Test::More;

my $file = 'test_005.db';

unlink $file;
my $o = Opinion->new($file);
like(ref $o, qr/Opinion/, 'object returned');

$o->save('a0', 1);
$o->save('a1', 2);

is_deeply($o->ids,      { a0 => 1, a1 => 1 }, 'ids');
is_deeply($o->retrieve, { a0 => 1, a1 => 2 }, 'ids');

undef $o;

unlink $file;

done_testing();
