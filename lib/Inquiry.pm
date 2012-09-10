package Inquiry;

use strict;
use warnings;

use Survey;
use Results;
use Dancer ':syntax';

use Data::Dumper;

our $VERSION = '0.1';

use constant {
    QUESTION_COUNT => 4,
};

get '/' => sub {
    my $survey = Survey->new('anketa.txt');
    Results->new->init(scalar keys %{$survey});
    template 'index', { questions => $survey->shake(QUESTION_COUNT) };
};

get '/submit' => sub {
    my $results = Results->new;
    $results->save(params());
};

true;
