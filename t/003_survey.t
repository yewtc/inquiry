#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Inquiry::Survey;

my $n = 'Cannot run without filename';
my $s = eval { Inquiry::Survey->new };
ok((defined $@ and length $@), "Died: $n");
is($s, undef, "No obj: $n");

$n = 'File not found';
$s = eval { Inquiry::Survey->new('"') };
ok((defined $@ and length $@), "Died: $n");

$n = 'Duplicate id';
$s = eval { Inquiry::Survey->new('t/003-d.txt') };
like($@, qr/Duplicate/, "Died: $n");

$n = 'Question in question';
$s = eval { Inquiry::Survey->new('t/003-q.txt') };
like($@, qr/Cannot start question/, "Died: $n");

$n = 'Answer in answer';
$s = eval { Inquiry::Survey->new('t/003-aa.txt') };
like($@, qr/Cannot start answer/, "Died: $n");

$n = 'Answer without question';
$s = eval { Inquiry::Survey->new('t/003-a.txt') };
like($@, qr/Cannot start answer/, "Died: $n");

$n = 'Answer in none';
$s = eval { Inquiry::Survey->new('t/003-an.txt') };
like($@, qr/Cannot put answers/, "Died: $n");

$n = 'Answer in question';
$s = eval { Inquiry::Survey->new('t/003-aq.txt') };
like($@, qr/Cannot put answers/, "Died: $n");

$n = 'Invalid line';
$s = eval { Inquiry::Survey->new('t/003-i.txt') };
like($@, qr/Invalid line/, "Died: $n");

$n = 'Self incompatibility';
$s = eval { Inquiry::Survey->new('t/003-c.txt') };
like($@, qr/Impossible incompatibility/, "Died: $n");

$s = eval { Inquiry::Survey->new('t/003-cm.txt') };
is(ref $s, 'Inquiry::Survey', 'Example loaded');
is(@{ $s->shake(1) }, 1, 'No incompatibility');
is($s->count, 2, 'Number of questions');
my $x = eval { $s->shake(2) };
like($@, qr/Not enough/, 'Not enough compatible questions');
is($x, undef, 'No questions generated');

$s = Inquiry::Survey->new('t/003-c0.txt');
ok(exists $s->{questions}{2}{incompatible}{1}, 'Incompatibilities fixed');
ok(! exists $s->{questions}{4}{incompatible}{5}, 'Incompat not transitive');

$n = 'No unfold';
$s = eval { Inquiry::Survey->new('t/003-fn.txt') };
like($@, qr/No unfold/, "Died: $n");

$s = eval { Inquiry::Survey->new('t/003-nq.txt') };
like($@, qr/No questions/, 'No questions');

$s = eval { Inquiry::Survey->new('t/003-nqt.txt') };
like($@, qr/No question text in /, 'No text in question');

$s = eval { Inquiry::Survey->new('t/003-na.txt') };
like($@, qr/No answer at /, 'No answer');

$s = eval { Inquiry::Survey->new('t/003-nf.txt') };
like($@, qr/No unfolds at /, 'No unfold');

$s = Inquiry::Survey->new('t/003-fm.txt');
is(ref $s, 'Inquiry::Survey', 'Example loaded');
is(@{ $s->{questions}{1}{unfold} }, 2, 'Multiple unfold');
is($s->{TITLE},            'Survey',         'Default Title');
is($s->{START},            'Start',          'Default Start');
is($s->{NEXT},             'Next',           'Default Next');
is($s->{AGAIN},            'Start again',    'Default Again');
is($s->{FINISH},           'Finish',         'Default Finish');
is($s->{MISSING},          'Missing answer', 'Default Missing');
is($s->{PICK},             4,                'Default Pick');
is($s->{opinion}{submit},  'Submit',         'Default Opinion Submit');
is_deeply($s->{THANK},     ['Thank you.'],   'Default Thank');

$s = eval { Inquiry::Survey->new('t/003-dt.txt') };
like($@, qr/Duplicate TITLE at /, 'Duplicate title');

$s = eval { Inquiry::Survey->new('t/003-dth.txt') };
like($@, qr/Duplicate THANK at /, 'Duplicate THANK');

$s = eval { Inquiry::Survey->new('t/003-thn.txt') };
like($@, qr/Cannot start THANK at /, 'THANK in NONE');

$s = eval { Inquiry::Survey->new('t/003-thq.txt') };
like($@, qr/Cannot start THANK at /, 'THANK in QUESTION');

$s = eval { Inquiry::Survey->new('t/003-tq.txt') };
like($@, qr/Cannot start question at /, 'Question after THANK');

$s = eval { Inquiry::Survey->new('t/003-do.txt') };
like($@, qr/Duplicate OPINION at /, 'Duplicate OPINION');

$s = eval { Inquiry::Survey->new('t/003-on.txt') };
like($@, qr/Cannot start OPINION at /, 'OPINION in NONE');

$s = eval { Inquiry::Survey->new('t/003-oq.txt') };
like($@, qr/Cannot start OPINION at /, 'OPINION in QUESTION');

$s = eval { Inquiry::Survey->new('t/003-oq2.txt') };
like($@, qr/Cannot start question at /, 'Question after OPINION');

$s = eval { Inquiry::Survey->new('t/003-to.txt') };
like($@, qr/Cannot start OPINION at /, 'OPINION after THANK');

$s = eval { Inquiry::Survey->new('t/003-p.txt') };
like($@, qr/PICK can only take a positive integer as its argument at /,
     'PICK is PosInt');

$s = Inquiry::Survey->new('t/003-p2.txt');
is(ref $s, 'Inquiry::Survey', 'Example loaded');
my @q = @{ $s->shake };
is(scalar @q, 2, 'PICK works');

$s = Inquiry::Survey->new('t/003-in.txt');
is(ref $s,                       'Inquiry::Survey',       'Example loaded');
is($s->{intro}[0],               "Introduction\n",        'Introduction');
is($s->{TITLE},                  'Title-t',               'Title');
is($s->{START},                  'Start-t',               'Start');
is($s->{NEXT},                   'Next-t',                'Next');
is($s->{AGAIN},                  'Start over-t',          'Again');
is($s->{FINISH},                 'Finish-t',              'Finish');
is($s->{MISSING},                'missing-t',             'Missing');
is($s->{PICK},                   1,                       'Pick');
is_deeply($s->{THANK},           ["Thank-t\n"],           'Thank');
is_deeply($s->{opinion}{text},   ["Whadda you think?\n"], 'Opinion');
is_deeply($s->{opinion}{submit}, "stumbit",               'Opinion Submit');

# Test real data loading plus sanity checks

$s = eval { Inquiry::Survey->new('anketa.txt') };
is(ref $s, 'Inquiry::Survey', 'Real data loaded');
eval { $s->check([], 'qn02-4' => 'on') };
like($@, qr/Invalid answer /, 'Invalid answer');
eval { $s->check([], 'qn0-1' => 'on') };
like($@, qr/Invalid answer/, 'Q number 0');
eval { $s->check([], 'qn7-1' => 'on') };
like($@, qr/Invalid question number 7/, 'Q number over max');
eval { $s->check([], 'qn1-1' => 1) };
like($@, qr/Invalid value/, 'on');

eval { $s->check([], 'rn3-2' => 1) };
like($@, qr/r with n/, 'rn');
eval { $s->check([], 'ra3-2' => 1) };
like($@, qr/r with a/, 'ra');
eval { $s->check([], 'qa3-2' => 'on') };
like($@, qr/q without n/, 'q-n');

eval { $s->check([], 'qn1-1' => 'on') };
like($@, qr/Invalid number of answers/, 'pick');
eval { $s->check([], 'qan1-1' => 'on') };
like($@, qr/Wrong incompatibility/, 'incompat');
eval { $s->check([], 'qn3-1' => 'on') };
like($@, qr/Wrong incompatibility/, '!incompat');
eval { $s->check([], 'qn1-1' => 'on', 'r1-1' => 2) };
like($@, qr/Radio unexpected at 1/, 'Wrong radio');
eval { $s->check([], 'r4-3' => 1) };
like($@, qr/Missing option for radio at/, 'Missing opt for r');
eval { $s->check([], 'qan4-3' => 'on') };
like($@, qr/Missing radio for /, 'Missing r for opt');
eval { $s->check([], 'qn1-7' => 'on') };
like($@, qr/Invalid option /, 'Extra');

eval { $s->check([], 'qn6-4' => 'on', 'r6-4' => 0) };
like($@, qr/Invalid radio value/, 'radio 0');
eval { $s->check([], 'qn6-4' => 'on', 'r6-4' => 3) };
like($@, qr/Invalid radio value/, 'radio over max');
eval { $s->check([], 'qn5-3' => 'on', 'qan5-4' => 'on') };
like($@, qr/Incompatibility not followed/, 'alone + more');

eval { $s->check([qw/6 3 5 4/],
                 'qan3-1' => 'on',
                 'qan4-1' => 'on',
                 'qn6-1'  => 'on') };
like($@, qr/Missing answer for/, 'shaken ~ results');

ok(eval { $s->check([qw/6 3 5 4/],
                    'qan3-1' => 'on',
                    'qan4-1' => 'on',
                    'qn5-1'  => 'on',
                    'qn6-1'  => 'on');
          1;
      }, 'checked');

done_testing();
