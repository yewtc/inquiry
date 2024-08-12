use Test::More;
use strict;
use warnings;

# the order is important
use Inquiry;
use Plack::Test;
use HTTP::Request::Common;
use_ok('Inquiry');

my $app =  Inquiry->to_app;

my $test = Plack::Test->create($app);

my $response = $test->request(GET '/');
ok($response->is_success, "Can get /");
ok($response->code == '200', "Has 200 status");
done_testing;