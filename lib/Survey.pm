package Survey;

use Data::Dumper;
use List::Util qw/shuffle/;

use warnings;
use strict;
use utf8;

=encoding utf8

=head1 NAME

Survey

=head1 SYNOPSIS

  my $sur       = Survey->($filename);
  my $max_num   = $sur->count;
  my $questions = $sur->shake($number);
  print STDERR $sur->debug_dump;

=head1 METHODS

=over

=item new

  my $sur = Survey->new($filename);

Creates a new Survery object, populated from the given file. See L</Syntax> for
the format of the file.

=cut

sub new {
    my ($class, $filename) = @_;
    die "No filename\n" unless defined $filename;
    my $self = {};
    bless $self, $class;
    $self->_load($filename);
    return $self;
}


=item count

  my $max_num = $sur->count;

Returns the number of questions in the full survery.

=cut

sub count {
    return scalar keys %{+shift};
}


=item shake

  my $questions = $sur->shake($number);

Shuffles the questions and returns the first $number of them. Incompatible
questions will be skipped.

=cut

sub shake {
    my ($self, $max) = @_;
    my @all_questions = map { [$_, $self->{$_}] } shuffle keys %$self;

    my @questions;
    my $used = 0;
    while ($used < $max and @all_questions) {
        my $question = shift @all_questions;
        my $ok = 1;
        my $inc = $question->[1]{incompatible};
        for my $q (@questions) {
            undef $ok if exists $inc->{$q->[0]};
        }
        if ($ok) {
            $used++;
            push @questions, $question;
        }
    }

    die "Not enough questions (" . join(',', map $_->[0], @questions) . ")\n" if $used < $max;
    return \@questions;
}


use constant {
    NONE     => 0,
    QUESTION => 1,
    ANSWER   => 2,
    UNFOLD   => 3,
};

sub _load {
    my ($self, $filename) = @_;
    open my $IN, '<:utf8', $filename or die $!;
    my $current;
    my $mode = NONE;
  LINE:
    while (<$IN>) {
        next if /^\s*$/ or /^%/;
        s/„/<i>/g;
        s|“|</i>|g;

        if (/^([0-9]+)\*([\s0-9]*)$/) {
            ($mode, $current) = $self->_question_header($1, $2, $mode);

        } elsif (/^[0-9]*\*\*/) {
            die "Cannot start answer at $.\n" if QUESTION != $mode;
            $mode = ANSWER;

        } elsif (/^\s*(!?)(\+?)([0-9]+)\./) {
            ($mode, my $redo) = $self->_answer($1, $2, $3, $current, $mode, $IN);
            redo LINE if $redo;

        } elsif (QUESTION == $mode) {
            $_ = "<br>$_" if /^\s/;
            push @{ $self->{$current}{question} }, $_;

        } elsif (NONE == $mode) {
            $_ = "<p>$_" if /^\s/;
            push @{ $self->{intro} }, $_;

        } else {
            die "Invalid line $.\n";
        }
    }
    $self->_check_completness;
    $self->_fix_incompatibility;
}


sub _answer {
    my ($self, $alone, $unfold, $num, $current, $mode, $IN) = @_;
    die "Cannot put answers at $.\n"
        if NONE == $mode
           || QUESTION == $mode
           and $alone || $unfold;
    s/^\s*[!+]+//;
    push @{ $self->{$current}{normal} },
        [$_, $alone, $unfold ? 1 : 0];
    if ('+' eq $unfold) {
        $mode = UNFOLD;
        push @{ $self->{$current}{unfold} }, [];
        my $first = 1;
        while (<$IN>) {
            if (not /^\s*!?-(?:[0-9]+\.)?(.*)/) {
                die "No unfold at $.\n" if $first;
                return $mode, 1;
            }
            push @{ $self->{$current}{unfold}[-1] }, $1;
            undef $first;
        }
    }
    return $mode, 0;
}


sub _question_header {
    my ($self, $current, $incompatible, $mode) = @_;
    die "Duplicate $current at $.\n" if exists $self->{$current};
    die "Cannot start question at $.\n" if QUESTION == $mode;
    if ($incompatible =~ /[0-9]/) {
        undef $self->{$current}{incompatible}{$_} for split ' ', $incompatible;
        die "Impossible incompatibility at $.\n"
            if exists $self->{$current}{incompatible}{$current};
    }
    return QUESTION, $current;
}

sub _check_completness {
    my $self = shift;
    my @questions = grep /^[0-9]+$/, keys %$self;
    die "No questions\n" unless @questions;

    for my $q_num (@questions) {
        my $question = $self->{$q_num};
        die "No question text in $q_num\n" unless @{ $question->{question} // [] };
        die "No answer at $q_num\n"        unless @{ $question->{normal}   // [] };

        for my $unfold (@{ $question->{unfold} // []}) {
            die "No unfolds at $q_num\n" unless @$unfold;
        }
    }
}


sub _fix_incompatibility {
    my $self = shift;
    my %incompatible;
    for my $question (grep exists $self->{$_}{incompatible}, grep /^[0-9]+$/, keys %$self) {
        undef $incompatible{$question}{$_} for keys %{ $self->{$question}{incompatible} };
    }
    for my $q1 (keys %incompatible) {
        for my $q2 (keys %{ $incompatible{$q1} })  {
            undef $self->{$q2}{incompatible}{$q1};
        }
    }
}


=item debug_dump

  print STDERR $sur->debug_dump;

Returns a dump (see Data::Dumper) of the given Survey object.

=cut

sub debug_dump {
    return Dumper shift;
}


=back

=head1 SYNTAX

  TITLE* Optional title of the survey, to be shown as a header. Default: Survey.

  Introductory text. Will be shown before the inquiry starts.
    Indent a line to start a new paragraph.

  START*  Text to be shown on the "Start" button under the introduction. Default: Start.
  NEXT*   Text to be shown on the "Next" button. Default: Next.
  AGAIN*  Text to be shown on the "Start again" button. Default: Start again.
  FINISH* Text to be shown on the last submit button. Default: Finish.

  1* 2
  This is the first question. It is incompatible with question number 2.
    An indented line starts a new paragraph.
  **
  1. The first answer. (Answers can be indented).
  2. The second answer. It can be selected together with the first one.
  !3. The third answer. The exclamation mark means it cannot be combined with any other answer.
  +4. The fourth answer. If selected, it displays a set of radio buttons.
  -1. The first radio button. Shown only when the fourth answer is selected. The numbering is optional.
  -2. The second radio button. Shown only when the fourth answer is selected.

  % A comment. Comments and emtpy lines are ignored.

  2*
  The second question. Its incompatibility with question number 1 does not have to be repeated.
  Text in „Czech quotes“ will be set in italics.
  **
    !+1. This answer is incompatible with the others (!). When checked, it displays a set of radio buttons (+).
  ...

  OPINION* Submit

  If specified, text area prompting for opinions and remarks will be
  shown after the survery has finished. The "Submit" parameter is used
  on the submit button.

  THANK* (Optional)

  The text to be shown on the last page. Defaults to "Thank you."

=head1 AUTHOR

(c) E. Choroba, 2012

=cut

__PACKAGE__
