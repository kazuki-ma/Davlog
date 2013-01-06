use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Schema::Result::EntryTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Davlog::Schema::Result::EntryTag

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<entry_tag>

=cut

__PACKAGE__->table("entry_tag");

=head1 ACCESSORS

=head2 entry_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "entry_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "tag_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</entry_no>

=item * L</tag_no>

=back

=cut

__PACKAGE__->set_primary_key("entry_no", "tag_no");

=head1 RELATIONS

=head2 entry_no

Type: belongs_to

Related object: L<Davlog::Schema::Result::Entry>

=cut

__PACKAGE__->belongs_to(
  "entries",
  "Davlog::Schema::Result::Entry",
  { entry_no => "entry_no" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 tag_no

Type: belongs_to

Related object: L<Davlog::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tags",
  "Davlog::Schema::Result::Tag",
  { tag_no => "tag_no" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-10-30 20:03:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NaKqBFxfnDX7rxX03w5vQQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
