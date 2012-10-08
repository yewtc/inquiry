package Inquiry;

use strict;
use warnings;
use utf8;

use Inquiry::Survey;
use Inquiry::Results;
use Inquiry::Opinion;
use Dancer ':syntax';

use Data::Dumper;

our $VERSION = '0.4';

use constant {
    DB_FILE => 'inquiry.db',
};

my $survey = Inquiry::Survey->new('anketa.txt');

any [qw/get post/] => '/' => sub {
    if (not session('intro')) {
        my $address = request()->address // 'UNKNOWN';
        info 'Connection from ' . $address;
        session intro => 1;
        return template 'intro', {intro => $survey->{intro},
                                  set_features(qw/START TITLE/)
                                 } if exists $survey->{intro};
    }

    if (not session('shaken')) {
        session shaken => $survey->shake;
    }

    if (session('current')) {
        session current => 1 + session('current') if $survey->{NEXT} eq (param('next') // q());

    } else {
        session current => 1;
    }

    for my $param (grep /^(?:qa?n|r)[0-9]+-[0-9]+$/, params()) {
        session $param => param($param);
    }

    template 'by_one', {current => session('current'),
                        shaken  => session('shaken'),
                        max     => $survey->{PICK},
                        set_features(qw/NEXT AGAIN FINISH TITLE MISSING/),
                       };
};


get '/again' => sub {
    session->destroy;
    forward '/';
};


post '/submit_one' => sub {
    if (session('current')) {
        my $results = Inquiry::Results->new(DB_FILE, request->address);
        $results->init($survey->count);
        my %answers = (params(),
                       map { $_ => session($_) }
                           grep /^(?:qa?n|r)[0-9]+-[0-9]+$/,
                           keys %{ session() });
        $survey->check([ map $_->[0], @{ session('shaken') } ], %answers);
        $results->save(%answers);
        session 'db_id' => $results->{id};
        forward '/opinion' if exists $survey->{opinion};
        session->destroy;
        forward '/thanks';
    }
    send_error 'Cannot submit';
};


get '/all' => sub {
    template 'index', { questions => $survey->shake,
                        intro => $survey->{intro},
                        set_features(qw/AGAIN FINISH TITLE MISSING/)};
};


get '/submit' => sub {
    if (params()) {
        my $results = Inquiry::Results->new(DB_FILE, request->address);
        $results->init($survey->count);
        $survey->check([ map $_->[0], @{ session('shaken') } ], params());
        $results->save(params());
        session 'db_id' => $results->{id};
        forward '/opinion' if exists $survey->{opinion};
        session->destroy;
        forward '/thanks';
    }
    send_error 'Cannot submit';
};


any [qw/post get/] => '/opinion' => sub {
    template 'opinion', { opinion => $survey->{opinion},
                          set_features(qw/TITLE/)};
};


post '/opinion/done' => sub {
    my $op = Inquiry::Opinion->new(DB_FILE);
    $op->save(session('db_id'), param('opinion'));
    session->destroy;
    forward '/thanks';
};


any [qw/post get/] => '/thanks' => sub {
    template 'thanks', { thank => $survey->{THANK},
                         set_features(qw/TITLE/) };
};


get '/table' => sub {
    my $results = Inquiry::Results->new(DB_FILE);
    $results->init($survey->count);
    my $opinions = Inquiry::Opinion->new(DB_FILE);
    template 'table', { count => $survey->count,
                        results  => [ $results->retrieve ],
                        opinions => $opinions->ids,
                      };
};

get '/opinion/show' => sub {
    my $opinion = Inquiry::Opinion->new(DB_FILE);
    my $opinions = $opinion->retrieve;
    my $show = $opinions->{param('o')};
    $show =~ s/&/\&amp;/g;
    $show =~ s/</\&lt;/g;
    $show =~ s/\n/<br>/g;
    return $show;
};


sub set_features {
    return map { 'v' . $_ => $survey->{$_} } @_;
}

true;
