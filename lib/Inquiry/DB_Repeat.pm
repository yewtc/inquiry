package Inquiry::DB_Repeat;

=head1 Inquiry::DB_Repeat

Helper function to repeat db prepare or execute to avoid failures on
locked db.

=cut

use warnings;
use strict;

use Time::HiRes qw{ usleep };

use Exporter 'import';
our @EXPORT = qw{ _repeat_until_ok };


sub _repeat_until_ok {
    my $code  = shift;
    my $count = 1;
    my $val;
    while ($count < 1_000) {
        last if $val = $code->();
        $count++;
        usleep 10;
    }
    print STDERR "_repeated: $count\n" if 1 < $count;
    return $val
}


=head1 AUTHOR

(c) E. Choroba, 2012 - 2013

=cut

__PACKAGE__
