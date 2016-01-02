# NAME

MonkeyMan - Apache CloudStack Management Framework

# SYNOPSIS

    MonkeyMan->new(
        app_code            => \&MyCoolApplication,
        parse_parameters    => {
            'l|line=s' => 'what_to_say'
        }
    );

    sub MyCoolApplication {

        my $mm = shift;

        $mm->get_logger->debugf("We were asked to say '%s'",
            $mm->get_parameters->what_to_say
        );

    }

# METHODS

- new()

    This method initializes the framework and runs the application.

    There are a few parameters that can (and need to) be defined:

    - app\_code => CodeRef

        MANDATORY. The reference to the subroutine that will do all the job.

    - app\_name => Str

        MANDATORY. The application's full name.

    - app\_description => Str

        MANDATORY. The application's description.

    - app\_version => Str

        MANDATORY. The application's version number.

    - app\_usage\_help => Str

        Optional. The text to be displayed when the user asks for help.

    - parameters\_to\_get => HashRef

        This attribute requires a reference to a hash containing parameters to be
        passed to the `Getopt::Long->GetOptions()` method (on the left
        corresponding names of sub-methods to get values of startup parameters. It
        creates the `parameters` method which returns a reference to the
        `MonkeyMan::Parameters` object containing the information of startup
        parameters accessible via corresponding methods. Thus,

            parameters_to_get => {
                'i|input=s'     => 'file_in',
                'o|output=s'    => 'file_out'
            }

        will create `MonkeyMan::Parameters` object with `file_in` and `file_out`
        methods, so you could address them as

            $monkeyman->get_parameters->file_in,
            $monkeyman->get_parameters->file_out
