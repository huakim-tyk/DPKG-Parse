package DPKG::Parse::InfoEntry;
use Params::Validate qw(:all);
use Class::C3;
use base qw(DPKG::Parse::Entry);

use strict;
use warnings;

use Tie::File;
use File::Spec;

our $VERSION = '0.01';

=item new('data' => $data, 'infodir' => $infodir 'debug' => 1)

Creates a new L<DPKG::Parse::Info::Entry> object.  
'infodir' should be a directory that contains the 
path where locates necessary files containing additional info.
'data' should be a scalar that contains the text of a 
dpkg-style Package entry.  If the 'debug' flag is
set, we will Carp about entries we don't have accessors for.

=cut

sub new {
    no warnings 'uninitialized';
    my $pkg = shift;
    my %p = validate(@_,
        {
            'infodir' => { 'type' => SCALAR, 'optional' => 1 },
            'data' => { 'type' => SCALAR, 'optional' => 1 },
            'debug' => { 'type' => SCALAR, 'default' => 0, 'optional' => 1 },
            'line_num' => { type => SCALAR, default => 0, optional => 1 }
        }
    );
    my $ref = $pkg->next::method(
        'data' => $p{'data'}, 
        'debug' => $p{'debug'}, 
        'line_num' => $p{'line_num'}
    );
    $ref->parsedir($p{'infodir'});
    
    return $ref;
}


use Data::Dumper;

sub list{
    my $fine = [];
    my $ref = shift;
    my $ext = shift || 'list';
    tie @$fine, 'Tie::File', $ref->{'infodir'} . $ext, 
    mode => 0, memory => 20;
    return $fine;
}

sub conffiles{
    my $ref = shift;
    return $ref->list('conffiles');
}

sub changedir{
    no warnings 'uninitialized';
    my ($ref, $infodir) = @_;
    if (-d $infodir){
        my $path = $ref->{'id'};
        $ref->{'infodir'} = File::Spec->catfile($infodir, $path) . '.';
    }
}

1;


__END__
=back

=head1 SEE ALSO

L<DPKG::Parse>, L<DPKG::Parse::Entry>

=head1 AUTHOR

huakim-tyk, C<zuhhaga@gmail.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut
