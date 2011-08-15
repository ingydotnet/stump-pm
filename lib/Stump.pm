##
# name:      Stump
# abstract:  Larry Wall's Slideshow Software
# author:    Larry Wall via Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

use 5.010;
package Stump;

our $VERSION = '0.02';

use File::Share 0.01 ();
use IO::All 0.43 ();
# use Template::Toolkit::Simple 0.13 ();
use YAML::XS 0.35 ();

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

    if ($self->empty_directory or $self->force) {
        my $share = $self->share;
        $self->copy_file("$share/stump.input", "./stump.input");
        $self->copy_file("$share/conf.yaml", "./conf.yaml");
        $self->copy_files("$share/image", "./image");
    }
    else {
        $self->error__wont_init;
    }
}

#-----------------------------------------------------------------------------#
package Stump::Command::make;
Stump->import( -command );
use Mouse;
extends qw[Stump::Command];

use IO::All;

use constant abstract => 'Make a Stump ODP Presentation';
use constant usage_desc => 'stump make';

sub execute {
    require Stump::Heavy;
    my ($self, $opt, $args) = @_;
    my $share = $self->share;
    $self->copy_file("$share/stump.odp", "./stump.odp");
    Stump::Heavy::para2odp();
    io('stump')->rmtree;
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
    exec $self->conf->{start_command};
}

#-----------------------------------------------------------------------------#
package Stump::Command::clean;
Stump->import( -command );
use Mouse;
extends qw[Stump::Command];

use constant abstract => 'Cleanup generated files';
use constant usage_desc => 'stump clean';

sub execute {
    my ($self, $opt, $args) = @_;
    system('rm -fr stump stump.odp');
}

#-----------------------------------------------------------------------------#
# Helper methods
#-----------------------------------------------------------------------------#
package Stump::Command;
use File::Share;
use IO::All;
use Cwd qw[cwd abs_path];
use YAML::XS;

has conf => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        my $self = shift;
        YAML::XS::LoadFile('conf.yaml');
    },
);

sub share {
    File::Share::dist_dir('Stump');
}

sub empty_directory {
    io('.')->empty;
}

sub copy_file {
    my ($self, $source, $target) = @_;
    my $file = io($source);
    io("$target")->assert->print($file->all);
}

sub copy_files {
    my ($self, $source, $target) = @_;
    for my $file (io($source)->All_Files) {
        my $short = $file->name;
        $short =~ s!^\Q$source\E/?!! or die $short;
        next if $short =~ /^\./;
        io("$target/$short")->assert->print($file->all);
    }
}

sub error {
    my ($self, $msg) = splice(@_, 0, 2);
    chomp $msg;
    $msg .= $/;
    die sprintf($msg, @_);
}

sub error__wont_init {
    my ($self) = @_;
    $self->error(
        "Won't 'init' in a non empty directory, unless you use --force"
    );
}

1;

=head1 SYNOPSIS

    > stump init
    > edit stump.input
    > stump make
    > stump speech

=head1 DESCRIPTION

Stump is Larry Wall's slideshow presentation hacks, packaged up for CPAN.

Stump takes a simple input format and some pictures and whatnot, and compiles
them into a OpenDocument (.odp) file that you view with your favorite
slideshow software.

=head1 STATUS

WARNING: THIS IS A VERY EARLY RELEASE. PLEASE GO AWAY NOW. WAIT FOR 0.10
BEFORE YOU USE THIS.

