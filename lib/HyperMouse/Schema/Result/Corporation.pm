use utf8;
package HyperMouse::Schema::Result::Corporation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::Corporation

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<HyperMouse::Schema::DefaultResult::I18nRelationships>

=item * L<HyperMouse::Schema::DefaultResult::DeepRelationships>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::EncodedColumn>

=back

=cut

__PACKAGE__->load_components(
  "+HyperMouse::Schema::DefaultResult::I18nRelationships",
  "+HyperMouse::Schema::DefaultResult::DeepRelationships",
  "InflateColumn::DateTime",
  "EncodedColumn",
);

=head1 TABLE: C<corporation>

=cut

__PACKAGE__->table("corporation");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 valid_since

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 valid_till

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 removed

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 provider

  data_type: 'tinyint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "valid_since",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "valid_till",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "removed",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "provider",
  { data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 corporation_x_contractors

Type: has_many

Related object: L<HyperMouse::Schema::Result::CorporationXContractor>

=cut

__PACKAGE__->has_many(
  "corporation_x_contractors",
  "HyperMouse::Schema::Result::CorporationXContractor",
  { "foreign.corporation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_x_corporations

Type: has_many

Related object: L<HyperMouse::Schema::Result::PersonXCorporation>

=cut

__PACKAGE__->has_many(
  "person_x_corporations",
  "HyperMouse::Schema::Result::PersonXCorporation",
  { "foreign.corporation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-26 08:31:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Nt1wIk8BGeqHKNfZh2y01w

use Method::Signatures;



__PACKAGE__->many_to_many(
  "contractors" => "corporation_x_contractors", "contractor"
);



method search_related_persons(
    Int     :$mask_permitted?,
    Int     :$mask_validated?,
    HashRef :$permission_checks?            = {},
    HashRef :$validation_checks?            = {},
    Bool    :$same_corporation?             = 1,
    Bool    :$same_corporation_contractor?  = 1
) {

    my @resultsets;

    $permission_checks->{'mask'} = defined($mask_permitted) ? $mask_permitted : 0b000111;
    $validation_checks->{'mask'} = defined($mask_validated) ? $mask_validated : 0b000111;

    foreach my $contractor (
        $self
            ->search_related('corporation_x_contractors')
            ->filter_validated(%{ $validation_checks })
            ->search_related('corporation')
            ->filter_validated(%{ $validation_checks })
            ->all
    ) {
        push(@resultsets,
            $contractor
                ->search_related_persons(
                    permission_checks           => $permission_checks,
                    validation_checks           => $validation_checks
                )
        ) if($same_corporation_contractor);
    }

    push(@resultsets, $self
        ->search_related('person_x_corporations')
        ->filter_validated(%{ $validation_checks })
        ->filter_permitted(%{ $permission_checks })
        ->search_related('person')
        ->filter_validated(%{ $validation_checks })
    );

    my $result_rs = shift(@resultsets); $result_rs ? $result_rs->union([ @resultsets ]) : $result_rs;

}



# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
