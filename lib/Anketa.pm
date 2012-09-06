package Anketa;

use Survey;
use Dancer ':syntax';
use List::Util qw/shuffle/;

use Data::Dumper;

our $VERSION = '0.1';

use constant {
    QUESTION_COUNT => 4,
};

get '/' => sub {
    my $string;
    my $ank = Survey->new('anketa.txt');
    my @questions = map { [$_, $ank->{$_}] } shuffle keys %$ank;

    template 'index', { questions => [@questions[0 .. QUESTION_COUNT - 1]] };
};

get '/submit' => sub {
    return '<pre>' . Dumper({params()}) . '</pre>';
};

true;
