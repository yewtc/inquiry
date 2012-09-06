package Survey;

use Data::Dumper;
use List::Util qw/shuffle/;

=head1 Survey

=cut

use warnings;
use strict;
use utf8;

sub new {
    my ($class, $filename) = @_;
    my $self = {};
    bless $self, $class;
    $self->_load($filename);
    return $self;
}

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

        if (/^([0-9]+)\*([\s0-9]*)/) {
            ($current, my $incompatible) = ($1, $2);
            die "Duplicate $current at $.\n" if exists $self->{$current};
            die "Cannot start question at $.\n" if QUESTION == $mode;
            if ($incompatible =~ /[0-9]/) {
                undef $self->{$current}{incompatible}{$_} for split ' ', $incompatible;
                die "Impossible incompatibility at $.\n"
                  if exists $self->{$current}{incompatible}{$current};
            }
            $mode = QUESTION;

        } elsif (/^\*\*/) {
            die "Cannot start answer at $.\n" if QUESTION != $mode;
            $mode = ANSWER;

        } elsif (/^(!?)(\+?)([0-9]+)\./) {
            my ($alone, $unfold, $num) = ($1, $2, $3);
            die "Cannot put answers at $.\n"
                if NONE == $mode
                   || QUESTION == $mode
                   and $alone || $unfold;
            s/^[!+]+//;
            push @{ $self->{$current}{answer}{text}{normal} },
                [$_, $alone, $unfold ? 1 : 0];
            if ('+' eq $unfold) {
                $mode = UNFOLD;
                while (<$IN>) {
                    redo LINE unless /^-[0-9]+\.(.*)/;
                    push @{ $self->{$current}{answer}{text}{unfold} }, $1;
                }
            }

        } elsif (QUESTION == $mode) {
            $_ = "<br>$_" if /^\s/;
            s/„/<i>/g;
            s|“|</i>|g;
            push @{ $self->{$current}{question} }, $_;

        } else {
            die "Invalid line $.\n";
        }
    }
}

sub debug_dump {
    return Dumper shift;
}


__PACKAGE__
