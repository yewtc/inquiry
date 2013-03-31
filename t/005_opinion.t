use strict;
use warnings;

use Inquiry::Opinion;
use Test::More tests => 3;

my $file = 'test_005.db';

unlink $file;
my $o = Inquiry::Opinion->new($file);
like(ref $o, qr/Opinion/, 'object returned');

$o->save('a0', 1);
$o->save('a1', 2);

is_deeply($o->ids,      { a0 => 1, a1 => 1 }, 'ids');
is_deeply($o->retrieve, { a0 => 1, a1 => 2 }, 'ids');

undef $o;

unlink $file;
