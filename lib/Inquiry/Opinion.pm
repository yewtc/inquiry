package Inquiry::Opinion;

=head1 NAME

Opinion

=head1 SYNOPSIS

  my $op = 'Inquiry::Opinion'->new($filename);
  $op->save($id, $opinion);
  my $keys = $op->ids;
  my $opinions = $op->retrieve;

=head1 METHODS

=over 4

=cut

use Data::Dumper;

use warnings;
use strict;

use DBI;
use Inquiry::DB_Repeat qw{ _repeat_until_ok };

=item new

  my $op = 'Inqiury::Opinion'->new($filename);

Returns an Opinion object connected to a database.

=cut

sub new {
    my ($class, $filename) = @_;
    my $db = 'DBI'->connect("dbi:SQLite:dbname=$filename" , q(), q(),
                            {RaiseError => 1,
                             AutoCommit => 0});
    $db->{sqlite_unicode} = 1;
    $db->do("create table if not exists opinions (connection varchar(76) primary key, opinion varchar)");
    $db->commit;
    bless {db => $db}, $class
}


=item save

  $op->save($id, $opinion);

Saves the given $opinion under the $id.

=cut

sub save {
    my ($self, $id, $opinion) = @_;
    my $st = _repeat_until_ok( sub {
        $self->{db}->prepare('insert into opinions values (?, ?)');
    } );
    _repeat_until_ok( sub { $st->execute($id, $opinion); } );
    $self->{db}->commit;
}

=item ids

  my $keys = $op->ids;

Returns a hashref of identifiers in the following form:

  { id1 => 1,
    id2 => 1,
    ...
  }

=cut

sub ids {
    my $self = shift;
    my $st = $self->{db}->prepare('select connection from opinions');
    $st->execute;
    my $data = { map { $_->[0] => 1 } @{ $st->fetchall_arrayref } };
    $self->{db}->commit;
    return $data
}

=item retrieve

  my $opinions = $op->retrieve;

Returns a hashref of opinions in the following form:

  { id1 => "opinion 1",
    id2 => "opinion 2",
    ...
  }

=cut

sub retrieve {
    my $self = shift;
    my $st = $self->{db}->prepare('select * from  opinions');
    $st->execute;
    my $data = { map {+@$_} @{ $st->fetchall_arrayref } };
    $self->{db}->commit;
    return $data
}


sub DESTROY {
    shift->{db}->disconnect;
}


=back

=head1 AUTHOR

(c) E. Choroba, 2012 - 2013

=cut

__PACKAGE__
