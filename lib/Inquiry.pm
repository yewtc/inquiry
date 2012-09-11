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
    DB_FILE => 'inquiry.db',
};

get '/' => sub {
    my $survey = Survey->new('anketa.txt');

    # Now we know the number of questions:
    Results->new(DB_FILE)->init(scalar keys %{$survey});

    template 'index', { questions => $survey->shake(QUESTION_COUNT) };
};

get '/submit' => sub {
    my $results = Results->new(DB_FILE, request->address);
    $results->save(params());
};

true;
