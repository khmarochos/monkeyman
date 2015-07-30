package WebMug::Controller::User;

use MonkeyMan::Constants;
use MonkeyMan::Utils;
use MonkeyMan::HyperMouse::User;

use Mojo::Base 'Mojolicious::Controller';



sub auth {

    my $c = shift;

    my $user_email = $c->session('user_email');

    if(defined($user_email)) {
        return(1);
    } else {
        $c->redirect_to('/login');
        return(0);
    }

}



sub login {

    my $c = shift;

    if($c->param('username')) {

        if(my @users = $c->hm_db->resultset('User')->search({
            email       => $c->param('username'),
            password    => { '=' => \[ 'PASSWORD(?)', $c->param('password') ] }
        })) {
            my $user_email = $users[0]->get_column('email');
            $c->session(user_email => $user_email);
            $c->flash(message => mm_sprintf("Access granted to %s", $user_email));
            $c->logger->debug(mm_sprintf("The %s user has logged in", $user_email));
            $c->redirect_to('/');
        } else {
            $c->flash(message => "Access denied");
            $c->redirect_to('/login');
        }

    }

    if($c->session('user_email')) {
        $c->render(user => $c->session('user_email'));
    } else {
        $c->render(user => undef);
    }

}



sub logout {

    my $c = shift;

    $c->flash(message => "You've logged out, have a nice time!");
    $c->session(user_email => undef);
    $c->redirect_to('/login');
}



1;
