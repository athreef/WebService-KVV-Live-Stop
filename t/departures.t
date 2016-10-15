use Test::More;
use utf8;

BEGIN {
    use_ok 'WebService::KVV::Live::Stop';
}

my $stop = WebService::KVV::Live::Stop->new('Siemensallee');
for ($stop->departures) {
    $has_wolfartsweier = 1, last if $_->{destination} =~ /^Wolfartsweier/;
}
ok $has_wolfartsweier;

for ($stop->departures) {
    $has_siemensallee = 1, last if $_->{destination} =~ /^Siemensallee/;
}
ok $has_siemensallee;

done_testing
