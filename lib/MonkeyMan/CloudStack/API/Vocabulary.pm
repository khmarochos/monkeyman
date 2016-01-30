package MonkeyMan::CloudStack::API::Vocabulary;

use strict;
use warnings;

# Use Moose and be happy :)
use Moose;
use MooseX::Singleton;
use namespace::autoclean;

with 'MonkeyMan::CloudStack::API::Essentials';

use MonkeyMan::Exception qw(
    VocabularyIsMissing
    VocabularyIsIncomplete
    WordIsMissing
    MacrosIsUndefined
);

use Method::Signatures;



has 'type' => (
    is          => 'ro',
    isa         => 'MonkeyMan::CloudStack::Types::ElementType',
    reader      =>  'get_type',
    writer      => '_set_type',
    required    => 1
);



has 'global_macros' => (
    isa         => 'HashRef',
    is          => 'ro',
    reader      =>    'get_global_macros',
    writer      =>   '_set_global_macros',
    builder     => '_build_global_macros',
    lazy        => 1
);

method _build_global_macros {
    return({
        OUR_NAME    => $self->vocabulary_lookup(
            word    => 'name',
            fatal   => 1,
            resolve => 0
        )
    });
}



method resolve_macros(
    Str             :$str!,
    Maybe[HashRef]  :$macros,
    Bool            :$fatal = 1
) {

    my @result;

    my %macros_all = %{ $self->get_global_macros };
    if(defined($macros)) {
        while(my($macros_name, $macros_value) = each(%{ $macros })) {
            $macros_all{$macros_name} = $macros_value;
        }
    }

    while ($str =~ /^(.*)<%(.+)%>(.*)$/) {
        my($left, $middle, $right) = ($1, $2, $3);
        if(defined($left)) {
            push(@result, $left);
        }
        if(defined(my $new_value = $macros_all{$middle})) {
            push(@result, $new_value);
        } elsif($fatal) {
            (__PACKAGE__ . 'Exception::MacrosIsUndefined')->throwf(
                "Can't resolve the %s macros", $middle
            )
        }
        $str = $right;
    }

    return(join('', @result, $str));

}



has 'vocabulary_data' => (
    is          => 'ro',
    isa         => 'HashRef',
    reader      =>    'get_vocabulary_data',
    writer      =>   '_set_vocabulary_data',
    predicate   =>   '_has_vocabulary_data',
    builder     => '_build_vocabulary_data',
    lazy        => 1
);

method _build_vocabulary_data {

    my $type        = $self->get_type;
    my $class_name  = $self->get_api->load_element_package($type);

    no strict 'refs';
    my $vocabulary_data = \%{'::' . $class_name . '::vocabulary_data'};

    unless(defined($vocabulary_data)) {
        (__PACKAGE__ . '::Exception::VocabularyIsMissing')->throwf(
            "The %s class' vocabulary data is missing. " .
            "Sorry, but I can not use this class.",
            $class_name
        );
    }

    $self->check_vocabulary(vocabulary_data => $vocabulary_data, fatal => 1);

    return($vocabulary_data);

}



method check_vocabulary(
    HashRef :$vocabulary_data?   = $self->get_vocabulary_data,
    Bool    :$fatal?             = 1
) {

    foreach my $word (qw(
        name
        actions
        actions:list
        actions:list:request
        actions:list:response
    )) {
        unless(defined($self->vocabulary_lookup(
            word        => $word,
            delimiter   => ':',
            ref         => $vocabulary_data,
            fatal       => 0,
            resolve     => 0
        ))) {
            if($fatal) {
                (__PACKAGE__ . '::Exception::VocabularyIsIncomplete')->throwf(
                    "The %s class' vocabulary data is missing the %s word." ,
                    $self->get_type, $word
                );
            } else {
                return(0)
            }
        }
    }

    return(1);

}



method vocabulary_lookup(
    Str|ArrayRef[Str]   :$word!,
    Str                 :$delimiter     = ':',
    HashRef             :$ref           = $self->get_vocabulary_data,
    Maybe[Bool]         :$fatal         = 0,
    Maybe[HashRef]      :$macros,
    Bool                :$resolve       = 1
) {

    $word = join($delimiter, @{ $word })
        if(ref($word) eq 'ARRAY');

    my $result;

    if((my @words = split($delimiter, $word)) > 1) {
        my $word0 = shift(@words);
        if(defined($ref->{$word0})) {
            $result = $self->vocabulary_lookup(
                word        => join($delimiter, @words),
                delimiter   => $delimiter,
                ref         => $ref->{$word0},
                fatal       => 0
            );
        }
    } else {
        $result = $ref->{$word};
    }

    if($fatal && !defined($result)) {
        (__PACKAGE__ . '::Exception::WordIsMissing')->throwf(
            "The %s class' vocabulary data is missing the %s word." ,
            $self->get_type, $word
        )
    }

    if($resolve && !ref($result)) {
        $result = $self->resolve_macros(
            str     => $result,
            macros  => $macros,
            fatal   => 1
        );
    }

    return($result);

}



method compose_command(
    Str             :$action!,
    HashRef         :$parameters
) {

    my $result;

    my $action_data = $self->vocabulary_lookup(
        word    => [ 'actions', $action ],
        fatal   => 1
    );

    my %command_parameters = (
        command => $self->vocabulary_lookup(
            word    => [ qw(request command) ],
            fatal   => 1,
            ref     => $action_data
        )
    );

    foreach my $parameter (keys(%{ $parameters })) {

        my $parameter_data = $self->vocabulary_lookup(
            word    => [ 'request', 'parameters', $parameter ],
            fatal   => 1,
            ref     => $action_data
        );
        
        my $command_parameter_name = $self->vocabulary_lookup(
            word    => 'parameter_name',
            fatal   => 0,
            ref     => $parameter_data
        );
        $command_parameter_name = $parameter
            unless(defined($command_parameter_name));

        my $command_parameter_value = $self->vocabulary_lookup(
            word    => 'parameter_value',
            fatal   => 0,
            ref     => $parameter_data,
            macros  => { VALUE => $parameters->{$parameter} }
        );
        $command_parameter_value = $parameters->{$parameter}
            unless(defined($command_parameter_value));

        my $command_parameter_isa = $self->vocabulary_lookup(
            word    => 'isa',
            fatal   => 0,
            ref     => $parameter_data,
        );

        $command_parameters{$command_parameter_name} = $command_parameter_value;

    }

#        my $command_parameter_required = $self->vocabulary_lookup(
#            word    => 'required',
#            fatal   => 0,
#            ref     => $parameter_data,
#        );
#        $command_parameter_required = 0
#            unless(defined($command_parameter_required));
#        if($command_parameter_required && !defined($command_parameter_value)) {
#            (__PACKAGE__ . '::Exception::RequiredParameterIsUnset') {
#            }
#        }

    $result = join("\t", (%command_parameters));

    return($result);

}



__PACKAGE__->meta->make_immutable;

1;
