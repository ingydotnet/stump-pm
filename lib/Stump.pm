##
# name:      Stump
# abstract:  Larry Wall's Slideshow Software
# author:    Larry Wall via Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

use 5.010;
package Stump;

our $VERSION = '0.01';

#-----------------------------------------------------------------------------#
package Stump::Command;
use App::Cmd::Setup -command;
use Mouse;
extends qw[MouseX::App::Cmd::Command];

sub validate_args {
}

# Semi-brutal hack to suppress extra options I don't care about.
around usage => sub {
    my $orig = shift;
    my $self = shift;
    my $opts = $self->{usage}->{options};
    @$opts = grep { $_->{name} ne 'help' } @$opts;
    return $self->$orig(@_);
};

#-----------------------------------------------------------------------------#
package Stump;
use App::Cmd::Setup -app;
use Mouse;
extends 'MouseX::App::Cmd';

use Module::Pluggable
  require     => 1,
  search_path => [ 'Stump' ];
Stump->plugins;

# App::Cmd help helpers
use constant usage => 'Stump';
use constant text => "stump command [<options>] [<arguments>]\n";

#-----------------------------------------------------------------------------#
package Stump::Command::init;
Stump->import( -command );
use Mouse;
extends qw[Stump::Command];

use constant abstract => 'Initialize a new Stump presentation';
use constant usage_desc => 'stump init [--force]';

has force => (
    is => 'ro',
    isa => 'Bool',
    documentation => 'Force an init operation',
);

sub execute {
    my ($self, $opt, $args) = @_;
}

#-----------------------------------------------------------------------------#
package Stump::Command::make;
Stump->import( -command );
use Mouse;
extends qw[Stump::Command];

use constant abstract => 'Make a Stump ODP Presentation';
use constant usage_desc => 'stump make';

sub execute {
    my ($self, $opt, $args) = @_;
    require Stump::Heavy;
    Stump::Heavy::para2odp('Sample');
}

#-----------------------------------------------------------------------------#
package Stump::Command::speech;
Stump->import( -command );
use Mouse;
extends qw[Stump::Command];

use constant abstract => 'Start your Stump speech';
use constant usage_desc => 'stump speech';

sub execute {
    my ($self, $opt, $args) = @_;
    exec 'ooimpress Sample.odp';
}

1;

=head1 SYNOPSIS

    > stump init
    > stump make
    > stump speech

=head1 DESCRIPTION

Stump is Larry Wall's slideshow presentation hacks, packaged up for CPAN.

It takes a simple input format and some pictures and whatnot, and compiles
them into a OpenDocument (.odp) file that you view with your favorite
slideshow software.

=head1 STATUS

WARNING: THIS IS A VERY EARLY RELEASE. PLEASE GO AWAY NOW. WAIT FOR 0.10
BEFORE YOU USE THIS.

