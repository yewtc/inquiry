package Opinion;

=head1 Opinion

=cut

use Data::Dumper;

use warnings;
use strict;

sub new {
    my ($class, $filename) = @_;
    my $db = DBI->connect("dbi:SQLite:dbname=$filename" , q(), q(),
                          {RaiseError => 1,
                           AutoCommit => 0});
    unless ($db->tables(undef, '%', 'opinions', 'TABLE')) {
        $db->do("create table opinions (connection varchar(76) primary key, opinion varchar)");
        $db->commit;
    }
    bless {db => $db}, $class;
}


sub save {
    my ($self, $id, $opinion) = @_;
    my $st = $self->{db}->prepare('insert into opinions values (?, ?)');
    $st->execute($id, $opinion);
    $self->{db}->commit;
    $self->{db}->disconnect;
}


sub ids {
    my $self = shift;
    my $st = $self->{db}->prepare('select connection from opinions');
    $st->execute;
    my $data = { map { $_->[0] => 1 } @{ $st->fetchall_arrayref } };
    $self->{db}->disconnect;
    return $data;
}

sub retrieve {
    my $self = shift;
    my $st = $self->{db}->prepare('select * from  opinions');
    $st->execute;
    my $data = { map {+@$_} @{ $st->fetchall_arrayref } };
    $self->{db}->disconnect;
    return $data;
}

__PACKAGE__
