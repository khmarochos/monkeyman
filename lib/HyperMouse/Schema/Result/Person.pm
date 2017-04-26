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
  is_nullable: 1

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

=head2 middle_name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 last_name

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
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "middle_name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "last_name",
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

=head2 person_x_corporations

Type: has_many

Related object: L<HyperMouse::Schema::Result::PersonXCorporation>

=cut

__PACKAGE__->has_many(
  "person_x_corporations",
  "HyperMouse::Schema::Result::PersonXCorporation",
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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-26 08:31:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mKZd5uUPH5pzOYu9E2owxw

use Method::Signatures;



__PACKAGE__->many_to_many(
  "corporations" => "person_x_corporations", "corporation",
);

__PACKAGE__->many_to_many(
  "contractors" => "person_x_contractors", "contractor",
);

__PACKAGE__->many_to_many(
  "provisioning_agreements" => "person_x_provisioning_agreements", "provisioning_agreement"
);



method search_related_persons(
    Int     :$mask_permitted?,
    Int     :$mask_validated?,
    HashRef :$permission_checks?            = {},
    HashRef :$validation_checks?            = {},
    HashRef :$related?                      = {}
) {

    my @resultsets;

    $permission_checks->{'mask'} = defined($mask_permitted) ? $mask_permitted : 0b000111;
    $validation_checks->{'mask'} = defined($mask_validated) ? $mask_validated : 0b000111;

    foreach my $corporation (
        $self
            ->search_related('person_x_corporations')
            ->filter_validated(%{ $validation_checks })
            ->filter_permitted(%{ $permission_checks })
            ->search_related('corporation')
            ->filter_validated(%{ $validation_checks })
            ->all
    ) {
        push(@resultsets,
            $corporation
                ->search_related_persons(
                    permission_checks           => $permission_checks,
                    validation_checks           => $validation_checks,
                    related                     => $related->{'corporation'},
                )
        ) if(exists($related->{'corporation'}));
    }

    foreach my $contractor (
        $self
            ->search_related('person_x_contractors')
            ->filter_validated(%{ $validation_checks })
            ->filter_permitted(%{ $permission_checks })
            ->search_related('contractor')
            ->filter_validated(%{ $validation_checks })
            ->all
    ) {
        push(@resultsets,
            $contractor
                ->search_related_persons(
                    permission_checks           => $permission_checks,
                    validation_checks           => $validation_checks,
                    related                     => $related->{'contractor'}
                )
        ) if(exists($related->{'contractor'}));
    }

    my $result_rs = shift(@resultsets); $result_rs ? $result_rs->union([ @resultsets ]) : $result_rs;

}



method search_related_provisioning_agreements(
    Int     :$mask_permitted?,
    Int     :$mask_validated?,
    HashRef :$permission_checks?    = {},
    HashRef :$validation_checks?    = {},
    Bool    :$same_corporation?     = 1,
    Bool    :$same_contractor?      = 1,
) {

    my @resultsets;

    $permission_checks->{'mask'} = defined($mask_permitted) ? $mask_permitted : 0b000111;
    $validation_checks->{'mask'} = defined($mask_validated) ? $mask_validated : 0b000111;

    foreach my $corporation (
        $self
            ->search_related('person_x_corporations')
            ->filter_validated(%{ $validation_checks })
            ->filter_permitted(%{ $permission_checks })
            ->search_related('corporation')
            ->filter_validated(%{ $validation_checks })
            ->all
    ) {
        if($corporation->provider) {
            push(@resultsets,
                $corporation
                    ->search_related('corporation_x_contractors')
                    ->filter_validated(%{ $validation_checks })
                    ->search_related('contractors')
                    ->filter_validated(%{ $validation_checks })
                    ->search_related('provisioning_agreement_provider_contractors')
                    ->filter_validated(%{ $validation_checks })
            ) if($same_corporation);
        } else {
            push(@resultsets,
                $corporation
                    ->search_related('corporation_x_contractors')
                    ->filter_validated(%{ $validation_checks })
                    ->search_related('contractors')
                    ->filter_validated(%{ $validation_checks })
                    ->search_related('provisioning_agreement_client_contractors')
                    ->filter_validated(%{ $validation_checks })
            ) if($same_corporation);
        }
    }

    foreach my $contractor (
        $self
            ->search_related('person_x_contractors')
            ->filter_validated(%{ $validation_checks })
            ->filter_permitted(%{ $permission_checks })
            ->search_related('contractor')
            ->filter_validated(%{ $validation_checks })
            ->all
    ) {
        if($contractor->provider) {
            push(@resultsets,
                $contractor
                    ->search_related('provisioning_agreement_provider_contractors')
                    ->filter_validated(%{ $validation_checks })
            ) if($same_contractor);
        } else {
            push(@resultsets,
                $contractor
                    ->search_related('provisioning_agreement_client_contractors')
                    ->filter_validated(%{ $validation_checks })
            ) if($same_contractor);
        }
    }

    push(@resultsets, $self
        ->search_related('person_x_provisioning_agreements')
        ->filter_validated(%{ $validation_checks })
        ->filter_permitted(%{ $permission_checks })
        ->search_related('provisioning_agreement')
        ->filter_validated(%{ $validation_checks })
    );

    my $result_rs = shift(@resultsets); $result_rs ? $result_rs->union([ @resultsets ]) : $result_rs;

}



# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

1;
