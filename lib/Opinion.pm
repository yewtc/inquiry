package Opinion;

=head1 NAME

Opinion

=head1 SYNOPSIS

  my $op = Opinion->new($filename);
  $op->save($id, $opinion);
  my $keys = $op->ids;
  my $opinions = $op->retrieve;

=head1 CAUTION

The C<save>, C<ids> and C<retrieve> methods disconnect from the
database immediately. You have to create a new object for a next
operation.

=head1 METHODS

=over 4

=cut

use Data::Dumper;

use warnings;
use strict;

use DBI;


=item new

  my $op = Opinion->new($filename);

Returns an Opinion object connected to a database.

=cut

sub new {
    my ($class, $filename) = @_;
    my $db = DBI->connect("dbi:SQLite:dbname=$filename" , q(), q(),
                          {RaiseError => 1,
                           AutoCommit => 0});
    $db->{sqlite_unicode} = 1;
    unless ($db->tables(undef, '%', 'opinions', 'TABLE')) {
        $db->do("create table opinions (connection varchar(76) primary key, opinion varchar)");
        $db->commit;
    }
    bless {db => $db}, $class;
}


=item save

  $op->save($id, $opinion);

Saves the given $opinion under the $id. The object then disconnects
from the database.

=cut

sub save {
    my ($self, $id, $opinion) = @_;
    my $st = $self->{db}->prepare('insert into opinions values (?, ?)');
    $st->execute($id, $opinion);
    $self->{db}->commit;
    $self->{db}->disconnect;
}

=item ids

  my $keys = $op->ids;

Returns a hashref of identifiers in the following form:

  { id1 => 1,
    id2 => 1,
    ...
  }

The object then disconnects from the database.

=cut

sub ids {
    my $self = shift;
    my $st = $self->{db}->prepare('select connection from opinions');
    $st->execute;
    my $data = { map { $_->[0] => 1 } @{ $st->fetchall_arrayref } };
    $self->{db}->disconnect;
    return $data;
}

=item retrieve

  my $opinions = $op->retrieve;

Returns a hashref of opinions in the following form:

  { id1 => "opinion 1",
    id2 => "opinion 2",
    ...
  }

The object then disconnects from the database.

=cut

sub retrieve {
    my $self = shift;
    my $st = $self->{db}->prepare('select * from  opinions');
    $st->execute;
    my $data = { map {+@$_} @{ $st->fetchall_arrayref } };
    $self->{db}->disconnect;
    return $data;
}


=back

=head1 AUTHOR

(c) E. Choroba, 2012

=cut

__PACKAGE__
