#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Survey;

my $n = 'Cannot run without filename';
my $s = eval { Survey->new };
ok((defined $@ and length $@), "Died: $n");
is($s, undef, "No obj: $n");

$n = 'File not found';
$s = eval { Survey->new('"') };
ok((defined $@ and length $@), "Died: $n");

$n = 'Duplicate id';
$s = eval { Survey->new('t/003-d.txt') };
like($@, qr/Duplicate/, "Died: $n");

$n = 'Question in question';
$s = eval { Survey->new('t/003-q.txt') };
like($@, qr/Cannot start question/, "Died: $n");

$n = 'Answer in answer';
$s = eval { Survey->new('t/003-aa.txt') };
like($@, qr/Cannot start answer/, "Died: $n");

$n = 'Answer without question';
$s = eval { Survey->new('t/003-a.txt') };
like($@, qr/Cannot start answer/, "Died: $n");

$n = 'Answer in none';
$s = eval { Survey->new('t/003-an.txt') };
like($@, qr/Cannot put answers/, "Died: $n");

$n = 'Answer in question';
$s = eval { Survey->new('t/003-aq.txt') };
like($@, qr/Cannot put answers/, "Died: $n");

$n = 'Invalid line';
$s = eval { Survey->new('t/003-i.txt') };
like($@, qr/Invalid line/, "Died: $n");

$n = 'Self incompatibility';
$s = eval { Survey->new('t/003-c.txt') };
like($@, qr/Impossible incompatibility/, "Died: $n");

$s = eval { Survey->new('t/003-cm.txt') };
is(ref $s, 'Survey', 'Example loaded');
is(@{ $s->shake(1) }, 1, 'No incompatibility');
is($s->count, 2, 'Number of questions');
my $x = eval { $s->shake(2) };
like($@, qr/Not enough/, 'Not enough compatible questions');
is($x, undef, 'No questions generated');

$s = Survey->new('t/003-c0.txt');
ok(exists $s->{2}{incompatible}{1}, 'Incompatibilities fixed');

$n = 'No unfold';
$s = eval { Survey->new('t/003-fn.txt') };
like($@, qr/No unfold/, "Died: $n");

$s = eval { Survey->new('t/003-nq.txt') };
like($@, qr/No questions/, 'No questions');

$s = eval { Survey->new('t/003-nqt.txt') };
like($@, qr/No question text in /, 'No text in question');

$s = eval { Survey->new('t/003-na.txt') };
like($@, qr/No answer at /, 'No answer');

$s = eval { Survey->new('t/003-nf.txt') };
like($@, qr/No unfolds at /, 'No unfold');

$s = Survey->new('t/003-fm.txt');
is(ref $s, 'Survey', 'Example loaded');
is(@{ $s->{1}{unfold} }, 2, 'Multiple unfold');

$s = Survey->new('t/003-in.txt');
is(ref $s, 'Survey', 'Example loaded');
is($s->{intro}[0], "Introduction\n", 'Introduction');

# Test real data loading

$s = eval { Survey->new('anketa.txt') };
is(ref $s, 'Survey', 'Real data loaded');

done_testing();
