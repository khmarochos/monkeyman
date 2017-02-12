use utf8;
package HyperMouse::Schema::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HyperMouse::Schema::Result::Person

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::I18nRelationships>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::EncodedColumn>

=back

=cut

__PACKAGE__->load_components(
  "I18nRelationships",
  "InflateColumn::DateTime",
  "EncodedColumn",
);

=head1 TABLE: C<person>

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 valid_since

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 valid_till

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 removed

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 last_name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 middle_name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 language_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 timezone

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 datetime_format_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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
    is_nullable => 0,
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
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "middle_name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "language_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "timezone",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "datetime_format_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 datetime_format

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::DatetimeFormat>

=cut

__PACKAGE__->belongs_to(
  "datetime_format",
  "HyperMouse::Schema::Result::DatetimeFormat",
  { id => "datetime_format_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 language

Type: belongs_to

Related object: L<HyperMouse::Schema::Result::Language>

=cut

__PACKAGE__->belongs_to(
  "language",
  "HyperMouse::Schema::Result::Language",
  { id => "language_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 person_emails

Type: has_many

Related object: L<HyperMouse::Schema::Result::PersonEmail>

=cut

__PACKAGE__->has_many(
  "person_emails",
  "HyperMouse::Schema::Result::PersonEmail",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_passwords

Type: has_many

Related object: L<HyperMouse::Schema::Result::PersonPassword>

=cut

__PACKAGE__->has_many(
  "person_passwords",
  "HyperMouse::Schema::Result::PersonPassword",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_phones

Type: has_many

Related object: L<HyperMouse::Schema::Result::PersonPhone>

=cut

__PACKAGE__->has_many(
  "person_phones",
  "HyperMouse::Schema::Result::PersonPhone",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_x_contractors

Type: has_many

Related object: L<HyperMouse::Schema::Result::PersonXContractor>

=cut

__PACKAGE__->has_many(
  "person_x_contractors",
  "HyperMouse::Schema::Result::PersonXContractor",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_x_provisioning_agreements

Type: has_many

Related object: L<HyperMouse::Schema::Result::PersonXProvisioningAgreement>

=cut

__PACKAGE__->has_many(
  "person_x_provisioning_agreements",
  "HyperMouse::Schema::Result::PersonXProvisioningAgreement",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-02-12 04:38:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cqYMBIjMGtjFZ5n/CywXhA

use Method::Signatures;



__PACKAGE__->many_to_many(
  "contractors" => "person_x_contractors", "contractor",
);

__PACKAGE__->many_to_many(
  "provisioning_agreements" => "person_x_provisioning_agreements", "provisioning_agreement"
);



method find_provisioning_agreements (
    Int :$mask_permitted?   = 0b000111,
    Int :$mask_valid?       = 0b000111
) {
    my @result;

    foreach my $contractor (
        $self
            ->contractors
                ->filter_valid(source_alias => 'me')
                    ->filter_permitted(source_alias => 'me', mask => $mask_permitted)
                        ->filter_valid(source_alias => 'contractor')
    ) {
        if($contractor->provider) {
            push(@result,
                $contractor
                    ->provisioning_agreement_provider_contractors
                        ->filter_valid(mask => $mask_valid)
            );
        } else {
            push(@result,
                $contractor
                    ->provisioning_agreement_client_contractors
                        ->filter_valid(mask => $mask_valid)
            );
        }
    }

    foreach my $provisioning_agreement (
        $self
            ->provisioning_agreements
                ->filter_valid(source_alias => 'me')
                    ->filter_permitted(source_alias => 'me', mask => $mask_permitted)
                        ->filter_valid(source_alias => 'provisioning_agreement', mask => $mask_valid)
        ) {
            push(@result, $provisioning_agreement);
    }

    @result;

}



# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
