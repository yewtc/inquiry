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
        session current => 1 + session('current') if 'Další' eq (param('next') // q());
    } else {
        session current => 1;
    }

    for my $param (grep /^(?:qa?n|r)[0-9]+-[0-9]+$/, params()) {
        session $param => param($param);
    }

    template 'by_one', {current => session('current'),
                        shaken  => session('shaken'),
                        max     => QUESTION_COUNT};
};


get '/again' => sub {
    session->destroy;
    forward '/';
};


post '/submit_one' => sub {
    if (session('current')) {
        my $results = Results->new(DB_FILE, request->address);
        $results->save(params(),
                       map { $_ => session($_) }
                           grep /^(?:qa?n|r)[0-9]+-[0-9]+$/,
                           keys %{ session() });
        session->destroy;
        forward '/thanks';
    }
    send_error 'Cannot submit';
};


get '/all' => sub {
    template 'index', { questions => init()->shake(QUESTION_COUNT) };
};


get '/submit' => sub {
    if (params()) {
        my $results = Results->new(DB_FILE, request->address);
        $results->save(params());
        session->destroy;
        forward '/thanks';
    }
    send_error 'Cannot submit';
};


any [qw/post get/] => '/thanks' => sub {
    template 'thanks';
};


get '/table' => sub {
    template 'table', { results => [ values %{ Results->new(DB_FILE)->retrieve } ] };
};


true;
