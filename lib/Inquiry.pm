package Inquiry;

use strict;
use warnings;
use utf8;

use Inquiry::Survey;
use Inquiry::Results;
use Inquiry::Opinion;
use Dancer ':syntax';

use if ('development' eq config->{environment}), qw(Data::Dumper);

our $VERSION = '0.4';

use constant {
    DB_FILE => 'inquiry.db',
};

my $survey = Inquiry::Survey->new('inquiry.txt');

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

    if (param('enough')) {
        forward '/submit_one';
    }

    my $current = session('current');
    my $orignum = session('shaken')->[$current - 1];
    template 'by_one', {current  => $current,
                        question => [$orignum, $survey->question($orignum)],
                        max      => $survey->{PICK},
                        set_features(qw/NEXT AGAIN FINISH TITLE MISSING MINIMUM ENOUGH/),
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
        my %last = params();
        delete @last{qw/finish enough/};
        my %answers = (%last,
                       map { $_ => session($_) }
                           grep /^(?:qa?n|r)[0-9]+-[0-9]+$/,
                           keys %{ session() });
        $survey->check(session('shaken'), %answers);
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
    my $opinion = param('opinion');
    $op->save(session('db_id'), $opinion)
        if defined $opinion and length $opinion;
    session->destroy;
    forward '/thanks';
};


any [qw/post get/] => '/thanks' => sub {
    template 'thanks', { thank => $survey->{THANK},
                         set_features(qw/TITLE/) };
};


get '/table' => sub {
    # This must go first because it might create the Opinions table if it does not yet exists.
    # The creation is not possible after Results are constructed because they lock the DB.
    my $opinions = Inquiry::Opinion->new(DB_FILE);

    my $results  = Inquiry::Results->new(DB_FILE);
    $results->init($survey->count);
    my $ret = $results->retrieve;
    template 'table', { count => $survey->count,
                        results  => [ map +{ $_ => $ret->{$_} },
                                      sort { (split /-/, $a)[1] <=> (split /-/, $b)[1]  }
                                      keys %$ret ],
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
