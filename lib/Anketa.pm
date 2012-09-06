package Anketa;

use Survey;
use Dancer ':syntax';

use Data::Dumper;

our $VERSION = '0.1';

use constant {
    QUESTION_COUNT => 4,
};

get '/' => sub {
    my $string;
    my $ank = Survey->new('anketa.txt');

    template 'index', { questions => $ank->shake(QUESTION_COUNT) };
};

get '/submit' => sub {
    return '<pre>' . Dumper({params()}) . '</pre>';
};

true;
