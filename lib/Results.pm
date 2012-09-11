package Results;

=head1 NAME

Results

=head1 SYNOPSIS

  my $results = Results->new($filename, $ip);
  my $results->init($count_answers);
  my $results->save(%params);

=head1 METHODS

=over 4

=cut

use Data::Dumper;

use warnings;
use strict;

use DBI;


=item new

  my $results = Results->new($filename, $ip);

Returns a new Results object, connects to the database in
$filename. $ip is used to generate unique id.

=cut

sub new {
    my ($class, $filename, $ip) = @_;
    my $self = {};
    $self->{db} = DBI->connect("dbi:SQLite:dbname=$filename", q(), q());
    $self->{id} = _generate_id($ip);
    return bless $self, $class;
}


# Generates id from the IP
sub _generate_id {
    my $ip = shift;
    join '-', $ip // '0.0.0.0', time, rand 1e14;
}

=item init

  $results->init($count_answers);

Conncects to the database. If the table does not exist, it is created
with the given number of columns (one column per question).

=cut

sub init {
    my ($self, $num) = @_;
    unless ($self->{db}->tables(undef, '%', 'answers', 'TABLE')) {
        my $questions = join ',', map "q$_ varchar(20)", 1 .. $num;
                                                          # 45 ip + 15 rand + 15 time
        $self->{db}->do("create table answers (connection varchar(76) primary key, id int, $questions)");
    }
}


=item save

  $results->save(%params);

Saves the results stored in %params into the database. The format of
%params should be the following:

  ('qan1-2' => undef,  # Exclusive question no. 1 has answer 2.
    'qn2-3' => undef,  # Question no. 2 has answer 3
    'qn2-2' => undef,  # and answer 2 as well.
    'qn4-1' => undef,  # Question number 4 has number 1
     'r4-1' => 2)      # which created radio buttons, number 2 was selected.

=cut

sub save {
    my $self = shift;
    my %params = @_;
    my %results;
    for (keys %params) {
        if    (/qa?n([0-9]+)-([0-9]+)/) { push @{ $results{$1} }, $2 }
        elsif (   /r([0-9]+)-([0-9]+)/) { push @{ $results{$1} }, "$2:$params{$_}" }
    }

    # From an answer 4,4:2 only keep 4:2
    for (keys %results) {
        for my $radio (grep /:/, @{ $results{$_} }) {
            my ($radio_question) = ($radio =~ /(.*):/);
            @{ $results{$_} } = grep $_ ne $radio_question, @{ $results{$_} }
        }
    }

    my $insert = $self->{db}->prepare('insert into answers(connection,'
                                      . join(', ', map "q$_", keys %results)
                                      . ') values (?, '
                                      . join(', ', ('?') x keys %results)
                                      . ')');
    $insert->execute($self->{id},
                     map join(',', sort _sort_multiple_answers @$_), values %results);
    $insert->finish;
}


sub _sort_multiple_answers {
    my ($a0, $a1) = $a =~ /(.*):(.*)/;
    $a0 //= $a;
    my ($b0, $b1) = $b =~ /(.*):(.*)/;
    $b0 //= $b;
    $a0 <=> $b0 or $a1 <=> $b1;
}


=item retrieve

  my %results = $results->retrieve;

Returns a hashref populated from the result database. The keys are the
connection id's, the values are arrays of answers.

=cut

sub retrieve {
    my $self = shift;
    my $select = $self->{db}->prepare('select * from answers');
    $select->execute;
    return { map { $_->[0] => [ @{ $_ }[1 .. $#{$_}] ] } @{ $select->fetchall_arrayref } };
}


=back

=head1 AUTHOR

(c) E. Choroba, 2012

=cut

__PACKAGE__
