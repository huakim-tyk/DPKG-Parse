package DPKG::Parse::Info;
use DPKG::Parse::InfoEntry;
use Params::Validate qw(:all);
use Class::C3;
use base qw(DPKG::Parse::Status);
use File::Spec;
use strict;
use warnings;
use Set::Scalar;

DPKG::Parse::Info->mk_accessors(qw(infopath));

our $VERSION = '0.01';

=head1 NAME

DPKG::Parse::Info - scan $dpkgfolder/info/*.list for files/patterns

=head1 SYNOPSIS
    my $dpkg_info_list = DPKG::Info::List->new('/var/lib/dpkg'); 
    my @packages = $dpkg_info_list->scan_full_path('/full/file/path');
    my @packages = $dpkg_info_list->scan_partial_path('file/path');
    my @packages = $dpkg_info_list->scan_pattern(qr{freedom$});
    
=head1 DESCRIPTION

B<DPKG::Parse::Info> is a module for easy searching of L<dpkg(1)>'s package
file lists. These are located in F</var/lib/dpkg/info/*.list> and contain a
simple list of full file names (including the leading slash).

There are a couple of different class methods for searching by full or partial
path, a regular expression or a Perl module name.

=cut

sub new {
    my $pkg = shift;
    my %p = validate(@_,
        {
            'filename' => { 'type' => SCALAR, 'default' => undef, 'optional' => 1 },
            'infopath' => { 'type' => SCALAR, 'default' => undef, 'optional' => 1 },
            'path' => { 'type' => SCALAR, 'default' => '/var/lib/dpkg/', 'optional' => 1 },
            'debug' => { 'type' => SCALAR, 'default' => 0, 'optional' => 1 }
        }
    );
    my $path = $p{'path'};
    my $infopath = $p{'infopath'};
    my $filename = $p{'filename'};
    if (! defined $infopath){
        $infopath = File::Spec->catfile($path, 'info');
    }
    if (! defined $filename){
        $filename = File::Spec->catfile($path, 'status');
    }
    my $ref = $pkg->next::method( 
        'filename' => $filename,
        debug => $p{debug},
        );
    $ref->{'infopath'} = $infopath;
    return $ref;
}


=head1 CLASS-METHODS

=over


=item new ( I<options> )


=item scan_full_path ( I<path> )

Scans dpkg file lists for files, whose full path is equal to I<path>. Use when
you have the full path of the file you want, like C</usr/bin/perl>.

Returns a (possibly empty) list of packages containing I<path>.

=cut


sub _cat_lists
{
    my ( $self, $callback ) = @_;
    for ( @{$self->entryarray()} ) {
        my $pkg = $_;
        my $list = $_->list;
    #    print (Dumper($list));
        for my $l ( @{$list} ) {
            &$callback( $pkg, $l );
        }
    }
}


sub scan_full_paths
{
    my ( $class, $path ) = @_;

    if (! $path->isa('Set::Scalar')){
        if (ref($path) eq 'ARRAY'){
            my $path = Set::Scalar->new(@$path);
        } else {
            my $path = Set::Scalar->new($path);
        }
    }

    my %found;
    $class->_cat_lists(
        sub {
            $found{ $_[0] } = 1 if $path->has($_[1]);
        }
    );

    return sort keys %found;
}


=item parse

Calls DPKG::Parse::Status::parse, and reblessed all entries to order to 
add additional information.

=cut
sub parse {
    my $pkg = shift;
    $pkg->next::method;
    $pkg->bless_to_info_entry;
}

sub bless_to_info_entry{
    my $pkg = shift;
    my $info = $pkg->{'infopath'};
    foreach my $entry (@{$pkg->entryarray}) {
        bless ($entry, 'DPKG::Parse::InfoEntry');
        $entry->changedir($info);
    }
}

sub parse_package_format {
    my $pkg = shift;
    $pkg->next::method;
    $pkg->bless_to_info_entry;
}

=back

=head1 AUTHOR

=over 4

=item bunnylo1 <bunnylo12@yahoo.com>

=back

=head1 COPYRIGHT & LICENSE

=over 4

=item Copyright (C) 2021 bunnylo1 <bunnylo12@yahoo.com>

=back

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License version 2 as published by the Free
Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA 02110-1301 USA.

=cut

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

 
