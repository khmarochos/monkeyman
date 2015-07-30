package WebMug;

use FindBin qw($Bin);

use DBIx::Connector;
use Mojo::Base 'Mojolicious';

use MonkeyMan;
use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::HyperMouse::Schema;



# This method will run once at server start

sub startup {

    my $self = shift;

    # Initializing MonkeyMan as a helper
    my $mm = eval { MonkeyMan->new(
        config_file => MMRootDirectory . '/etc/monkeyman.conf',
        verbosity   => 7
        # ^^^ Actually I should get all these parameters from the command line (FIXME)
    ); };
    die(mm_sprintf("Can't MonkeyMan->new(): %s", $@))
        if($@);
    $self->helper(mm => sub { return($mm) });

    # Setting the logging interface as a helper
    my $log = eval { Log::Log4perl::get_logger("MonkeyMan") };
    die(mm_sprintf("The logger hasn't been initialized: %s", $@))
        if($@);
    $self->helper(logger => sub { $log; });

    my $hm_schema = MonkeyMan::HyperMouse::Schema->connect(
        sub { DBIx::Connector->connect("dbi:mysql:host=localhost;db=hypermouse", "hypermouse", "cL33Q2ioy91LIUTwj4f5"); }
        # ^^^ Actually I should get DBI login crerentials from the configuration file (FIXME)
    );
    $self->helper(hm_db => sub { $hm_schema });
    $self->hm_db->storage->debug(1);
    # Consider to make our own profiler for debugging purpouses as it's described there:
    # http://search.cpan.org/~frew/DBIx-Class-0.08121/lib/DBIx/Class/Manual/Cookbook.pod#Profiling (FIXME)

    my $r = $self->routes;
       $r->any('/login')->to('user#login');

    my $r_authenticated = $r->bridge('/')->to('user#auth');
       $r_authenticated->get('/')->to('dashboard#welcome');
       $r_authenticated->get('/logout')->to('user#logout');

    $self->logger->debug("The WebMug application has been initialized");

}



1;
