use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Schema::Result::ViewEntryMeta;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Davlog::Schema::Result::ViewEntryMeta

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

=head1 TABLE: C<view_entry_meta>

=cut

__PACKAGE__->table("view_entry_meta");

=head1 ACCESSORS

=head2 entry_no

  data_type: 'integer'
  is_nullable: 1

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 stub

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date

  data_type: 'datetime'
  is_nullable: 1

=head2 revision_no

  data_type: 'integer'
  is_nullable: 1

=head2 entry_status

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 create_date

  data_type: 'datetime'
  is_nullable: 1

=head2 create_function

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 update_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 update_function

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 update_count

  data_type: 'integer'
  is_nullable: 1

=head2 length

  data_type: (empty string)
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "entry_no",
  { data_type => "integer", is_nullable => 1 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "stub",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date",
  { data_type => "datetime", is_nullable => 1 },
  "revision_no",
  { data_type => "integer", is_nullable => 1 },
  "entry_status",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "create_date",
  { data_type => "datetime", is_nullable => 1 },
  "create_function",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "update_date",
  { data_type => "timestamp", is_nullable => 1 },
  "update_function",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "update_count",
  { data_type => "integer", is_nullable => 1 },
  "length",
  { data_type => "", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-11 00:15:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RneNKsOXFnU1eBvy0O1/0g

__PACKAGE__->add_columns(
  "date"        => { data_type => "datetime", is_nullable => 1, timezone => 'Asia/Tokyo' },
  "create_date" => { data_type => "datetime", is_nullable => 1, timezone => 'Asia/Tokyo' },
  "update_date" => { data_type => "datetime", is_nullable => 1, timezone => 'Asia/Tokyo' },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
