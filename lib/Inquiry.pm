package Inquiry;

use strict;
use warnings;
use utf8;

use Survey;
use Results;
use Dancer ':syntax';

use Data::Dumper;

our $VERSION = '0.1';

use constant {
    QUESTION_COUNT => 4,
    DB_FILE => 'inquiry.db',
};

sub init {
    my $survey = Survey->new('anketa.txt');

    # Now we know the number of questions:
    Results->new(DB_FILE)->init(scalar keys %{$survey});
    return $survey;
}


any [qw/get post/] => '/' => sub {
    unless (session('shaken')) {
        session shaken => init()->shake(QUESTION_COUNT);
    }
    if (session('current')) {
#        die Dumper {params()};
        session current => 1 + session('current') if 'Další' eq (param('next') // q());
    } else {
        session current => 1;
    }
    template 'by_one', {current => session('current'),
                        shaken  => session('shaken'),
                        max     => QUESTION_COUNT};
};


post '/submit_one' => sub {
};


get '/all' => sub {
    template 'index', { questions => init()->shake(QUESTION_COUNT) };
};


get '/submit' => sub {
    my $results = Results->new(DB_FILE, request->address);
    $results->save(params());
};

true;
