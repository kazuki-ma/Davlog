use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Davlog::Schema::Result::Tag

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

=head1 TABLE: C<tag>

=cut

__PACKAGE__->table("tag");

=head1 ACCESSORS

=head2 tag_no

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 stub

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 color

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 meta

  accessor: 'column_meta'
  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "tag_no",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "stub",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "color",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "meta",
  { accessor => "column_meta", data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tag_no>

=back

=cut

__PACKAGE__->set_primary_key("tag_no");

=head1 UNIQUE CONSTRAINTS

=head2 C<stub_unique>

=over 4

=item * L</stub>

=back

=cut

__PACKAGE__->add_unique_constraint("stub_unique", ["stub"]);

=head2 C<title_unique>

=over 4

=item * L</title>

=back

=cut

__PACKAGE__->add_unique_constraint("title_unique", ["title"]);

=head1 RELATIONS

=head2 entry_tags

Type: has_many

Related object: L<Davlog::Schema::Result::EntryTag>

=cut

__PACKAGE__->has_many(
  "entry_tags",
  "Davlog::Schema::Result::EntryTag",
  { "foreign.tag_no" => "self.tag_no" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 entries_no

Type: many_to_many

Composing rels: L</entry_tags> -> entry_no

=cut

__PACKAGE__->many_to_many("entries_no", "entry_tags", "entry_no");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-06 09:39:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fh+EAlhlpEKsvvlLbSMlLQ

__PACKAGE__->many_to_many("entries", "entry_tags", "entries");

before delete => sub {
	my $self = shift;
	$self->entry_tags->delete;
};

__PACKAGE__->meta->make_immutable;
1;
