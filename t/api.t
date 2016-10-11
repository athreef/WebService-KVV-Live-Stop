use Test::More;
use utf8;

BEGIN {
    use_ok 'WebService::KVV::Live::Stop';
}

use Data::Dumper;
my $stop = WebService::KVV::Live::Stop->new('Siemensallee');
ok $stop->departures > 0;

done_testing;


