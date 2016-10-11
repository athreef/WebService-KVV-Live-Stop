use strict;
use warnings;
package WebService::KVV::Live::Stop;

# ABSTRACT: Arrival times for Trams/Buses in the Karlsruhe metropolitan area
# VERSION

use Carp;
use utf8;
use Data::Dumper;
use Net::HTTP::Spore::Middleware::Format::JSON;
use Net::HTTP::Spore 0.07;
use Net::HTTP::Spore::Middleware::DefaultParams;
use File::ShareDir 'dist_file';

=pod

=encoding utf8

=head1 NAME

WebService::KVV::Live::Stop - Arrival times for Trams/Buses in the Karlsruhe metropolitan area


=head1 SYNOPSIS

    use WebService::KVV::Live:Stop;

    my $stop = WebService::KVV::Live::Stop->new("Siemensallee");
    print "Arrival time: $_{time} $_{what}\n" for $stop->departures;


=head1 DESCRIPTION

API for searching for bus/tram stops in the Karlsruhe Metropolitan Area (Karlsruhe Verkehrsvertriebe network to be exact) and for listing departure times at said stops.

=cut

my $client = Net::HTTP::Spore->new_from_spec(dist_file 'WebService-KVV-Live-Stop', 'kvvlive.json');
$client->enable('Format::JSON');
$client->enable('DefaultParams', default_params => { key => '377d840e54b59adbe53608ba1aad70e8' });
{ no strict 'vars'; $client->enable('UserAgent', useragent => __PACKAGE__ ." $VERSION"); }

=head1 IMPLEMENTATION

Not really an API, just a client for L<http://live.kvv.de>. See L<kvvlive.json|https://github.com/athreef/WebService-KVV-Live-Stop/blob/master/share/kvvlive.json> for details.

=head1 METHODS AND ARGUMENTS

=over 4

=item new($latitude, $langitude), new($name), new($id)

Search for matching local transport stops. C<$id> are identifiers starting with C<"de:">. C<$name> need not be an exact match.

Returns a list of C<WebService::KVV::Live::Stop>s in list context. In scalar context returns the best match.

=cut

#FIXME: timeout
sub new {
	my $class = shift;
    
    my @self;
    @_ or croak "No stop specified";
    my $response = 
        @_ == 2          ? $client->stop_by_latlon(LAT => shift, LON => shift)
      : $_[0] =~ /^de:$/ ? $client->stop_by_id(ID => shift)
                         : $client->stop_by_name(NAME => shift)
                         ;
    @{$response->{body}{stops}} or croak "No stops match arguments";
    $response->{body}{stops} = [$response->{body}{stops}[0]] unless wantarray;
    for my $stop (@{$response->{body}{stops}}) {
        my $obj = $stop;
		bless $obj, $class;
        push @self, $obj;
    }

	return wantarray ? @self : $self[0];
}


=item departures([$route])

Returns a list of departures for a WebService::KVV::Live::Stop. Results can be restricted to a particular route (Linie) by the optional argument.

=cut

sub departures {
    my $self = shift;
    my $route = shift;

    my $response =
        defined $route ? $client->departures_by_route(ID => $self->{id}, ROUTE => $route)
                       : $client->departures_by_stop( ID => $self->{id});
    return $response->{body}

}

1;
__END__

=back

=head1 GIT REPOSITORY

L<http://github.com/athreef/WebService-KVV-Live-Stop>

=head1 SEE ALSO

L<http://live.kvv.de>

=head1 AUTHOR

Ahmad Fatoum C<< <athreef@cpan.org> >>, L<http://a3f.at>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 Ahmad Fatoum

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
