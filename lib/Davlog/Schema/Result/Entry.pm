use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Schema::Result::Entry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Davlog::Schema::Result::Entry

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

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

=head1 TABLE: C<entry>

=cut

__PACKAGE__->table("entry");

=head1 ACCESSORS

=head2 entry_no

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 stub

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 date

  data_type: 'datetime'
  is_nullable: 0

=head2 revision_no

  data_type: 'integer'
  is_nullable: 1

=head2 entry_status

  data_type: 'varchar'
  default_value: 'valid'
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
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
	"entry_no",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"title",
	{ data_type => "varchar", is_nullable => 0, size => 255 },
	"stub",
	{ data_type => "varchar", is_nullable => 0, size => 255 },
	"date",
	{ data_type => "datetime", is_nullable => 0 },
	"revision_no",
	{ data_type => "integer", is_nullable => 1 },
	"entry_status",
	{
		data_type     => "varchar",
		default_value => "valid",
		is_nullable   => 1,
		size          => 255,
	},
	"create_date",
	{ data_type => "datetime", is_nullable => 1 },
	"create_function",
	{ data_type => "varchar", is_nullable => 1, size => 64 },
	"update_date",
	{ data_type => "timestamp", is_nullable => 1 },
	"update_function",
	{ data_type => "varchar", is_nullable => 1, size => 64 },
	"update_count",
	{ data_type => "integer", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</entry_no>

=back

=cut

__PACKAGE__->set_primary_key("entry_no");

=head1 UNIQUE CONSTRAINTS

=head2 C<stub_unique>

=over 4

=item * L</stub>

=back

=cut

__PACKAGE__->add_unique_constraint( "stub_unique", ["stub"] );

=head1 RELATIONS

=head2 entry_tags

Type: has_many

Related object: L<Davlog::Schema::Result::EntryTag>

=cut

__PACKAGE__->has_many(
	"entry_tags",
	"Davlog::Schema::Result::EntryTag",
	{ "foreign.entry_no" => "self.entry_no" },
	{ cascade_copy       => 0, cascade_delete => 1 },
);

=head2 revisions

Type: has_many

Related object: L<Davlog::Schema::Result::Revision>

=cut

__PACKAGE__->has_many(
	"revisions",
	"Davlog::Schema::Result::Revision",
	{ "foreign.entry_no" => "self.entry_no" },
	{ cascade_copy       => 0, cascade_delete => 1 },
);

=head2 tags_no

Type: many_to_many

Composing rels: L</entry_tags> -> tag_no

=cut

__PACKAGE__->many_to_many( "tags_no", "entry_tags", "tag_no" );

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-06 09:39:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EWq06bsk2wZySZjJ8FTRTw

__PACKAGE__->many_to_many( "tags", "entry_tags", "tags" );

=head2 current_revision

Type: belongs_to

Related object: L<Davlog::Schema::Result::Revision>

=cut

__PACKAGE__->belongs_to(
	"current_revision",
	"Davlog::Schema::Result::Revision",
	{ 'foreign.revision_no' => 'self.revision_no' },
	{ is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

__PACKAGE__->add_columns(
	'create_date' => { data_type => 'datetime', timezone => 'Asia/Tokyo' },
	'update_date' => { data_type => 'datetime', timezone => 'Asia/Tokyo' },
	'date'        => { data_type => 'datetime', timezone => 'Asia/Tokyo' },
);
# タイムゾーンを上書きしておく


before insert => sub {
	my $self = shift;

	my $now  = DateTime->now;
	$self->create_date($now);
	$self->update_date($now);
	$self->update_count(1);
};

before update => sub {
	my $self = shift;
	my $now  = DateTime->now;
	$self->update_date($now);
	$self->update_count( $self->update_count + 1 );
};

before delete => sub {
	my $self = shift;
	$self->entry_tags->delete;
	$self->revisions->delete;
};

before insert => sub {
	my $errors = shift->validate;
	die @$errors if @$errors;
};

before update => sub {
	my $errors = shift->validate;
	die @$errors if @$errors;
};


__PACKAGE__->meta->make_immutable;
1;
