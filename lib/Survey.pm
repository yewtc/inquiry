package Survey;

use Data::Dumper;

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
