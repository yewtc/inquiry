package Inquiry;

use strict;
use warnings;
use utf8;

use Survey;
use Results;
use Dancer ':syntax';

use Data::Dumper;

our $VERSION = '0.2';

use constant {
    QUESTION_COUNT => 4,
    DB_FILE => 'inquiry.db',
};

my $survey = Survey->new('anketa.txt');

any [qw/get post/] => '/' => sub {
    unless (session('shaken')) {
        session shaken => $survey->shake(QUESTION_COUNT);
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
    template 'index', { questions => $survey->shake(QUESTION_COUNT) };
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
    my $results = Results->new(DB_FILE);
    $results->init($survey->count);
    template 'table', { results => [ values %{ $results->retrieve } ] };
};


true;
