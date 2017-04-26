package HyperMouse::Schema::DefaultResultSet;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends
    'DBIx::Class::ResultSet',
    'HyperMouse::Schema::ValidityCheck',
    'HyperMouse::Schema::PermissionCheck';

use Method::Signatures;
use DateTime;
use DateTime::TimeZone;
use Switch;



__PACKAGE__->load_components('Helper::ResultSet');



method get_schema {
    $self->result_source->schema;
}



method datetime_parser {
    $self->result_source->storage->datetime_parser;
}

method format_datetime(
    DateTime $datetime!
) {
    $self->datetime_parser->format_datetime($datetime);
}



method search_related_deep(
    Str  :$resultset_class!,
    Bool :$union? = 1,
    ...
) {

    my @resultsets  = ();
    my $resultset   = $self;
    my %parameters  = @_;

    foreach my $result ($resultset->all) {
        push(@resultsets, scalar($result->search_related_deep(%parameters)));
    }

    push(@resultsets, scalar($self->result_source->schema->resultset($resultset_class)->search({ id => undef })))
        unless(@resultsets);

    if($union) {
        my $resultset = shift(@resultsets);
        warn($resultset);
        return(
            defined($resultset)
                  ? $resultset->union([ @resultsets ])
                  : $resultset
        )
    } else {
        return(@resultsets);
    }

}



__PACKAGE__->meta->make_immutable;

1;
