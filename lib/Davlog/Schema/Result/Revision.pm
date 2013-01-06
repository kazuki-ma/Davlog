use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Schema::Result::Revision;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Davlog::Schema::Result::Revision

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

=head1 TABLE: C<revision>

=cut

__PACKAGE__->table("revision");

=head1 ACCESSORS

=head2 entry_no

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 revision_no

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 text

  data_type: 'text'
  is_nullable: 1

=head2 meta

  accessor: 'column_meta'
  data_type: 'text'
  is_nullable: 1

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
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "entry_no",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "revision_no",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "text",
  { data_type => "text", is_nullable => 1 },
  "meta",
  { accessor => "column_meta", data_type => "text", is_nullable => 1 },
  "create_date",
  { data_type => "datetime", is_nullable => 1 },
  "create_function",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "update_date",
  { data_type => "timestamp", is_nullable => 1 },
  "update_function",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "update_count",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</revision_no>

=back

=cut

__PACKAGE__->set_primary_key("revision_no");

=head1 UNIQUE CONSTRAINTS

=head2 C<entry_no_revision_no_unique>

=over 4

=item * L</entry_no>

=item * L</revision_no>

=back

=cut

__PACKAGE__->add_unique_constraint("entry_no_revision_no_unique", ["entry_no", "revision_no"]);

=head1 RELATIONS

=head2 entry_no

Type: belongs_to

Related object: L<Davlog::Schema::Result::Entry>

=cut

__PACKAGE__->belongs_to(
  "entry_no",
  "Davlog::Schema::Result::Entry",
  { entry_no => "entry_no" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-06 09:39:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wwG+Shq6tQDS6B+xOZkqbg

use DateTime;


__PACKAGE__->add_columns (
'create_date' => {data_type => 'datetime', timezone => 'Asia/Tokyo'},
'update_date' => {data_type => 'datetime', timezone => 'Asia/Tokyo'},
);

before insert => sub {
	my $self = shift;
	my $args = shift;
	my $now = DateTime->now;
	$self->create_date($now);
	$self->update_date($now);
	$self->update_count(1);
	
	if ( $self->is_column_changed("text") ) {
		$self->text( $self->text );
	}
};

before update => sub {
	my $self = shift;
	$self->update_count($self->update_count + 1);
	$self->update_date(DateTime->now);
};

# text を都合のよいように編集する．
# ここでは，追加する情報について
# 1)BOMが付いていれば取り除く
# 2)改行コードを CR LF （DOS）にあわせる

around text => sub {
	my ( $orig, $self ) = ( shift, shift );
	
	if ( @_ ) {
		my $text = shift;
		$text = text_normalize( $text );
		return $self->$orig($text, @_);
	} else {
		return $self->$orig();
	}
};

sub text_normalize {
	my $text = shift;
	
	$text =~ s/^\x{feff}//m; # BOM 除去
	$text =~ s/\x0D\x0A|\x0D|\x0A/\x0D\x0A/g; # 改行コード統一
	return $text;
}

use Text::Xatena;
use Text::Markdown;
use HTML::Escape qw/escape_html/;

our $tx = Text::Xatena->new;
our $md = Text::Markdown->new;

sub format {
	my $self = shift;
	my ( $formatbang, $text ) = split( /\x0D\x0A|\x0D|\x0A/, (shift), 2 );
	
	$formatbang =~ m/^#!\s*([\w\/]+)/
	or $formatbang =~ m|^\s*//\s*(?:format\s*)?(\w+)|i
	or $formatbang =~ m|^\s*/\*\s*(?:format\s*)?(\w+)\s*\*/|i;
	
	given ( $1 ) {
		when ( /[hx]atena/i ) {
			return $tx->format( $text )
		}
		when ( /markdown|md/i ) {
			return $md->markdown( $text );
		}
		when ( /pre/i ) {
			return ( "<pre>" . escape_html( $text ) . "</pre>" );
		}
		when ( /x?html/i ) {
			return ( $text );
		}
		when ( m/(ActionScript3|Basic|Text|actionscript3|as3|bash|c|c-sharp|cf|coldfusion|cpp|csharp|css|delphi|diff|erl|erlang|groovy|html|java|javafx|javascript|jfx|pas|pascal|patch|perl|php|pl|plain|powershell|ps|py|python|rails|ror|ruby|scala|shell|sql|text|vb|vbnet|xhtml|xml|xslt)/i ) {
			return ( qq|<pre class="brush: $1; class-name: 'class_name_demo';">| . escape_html( $formatbang . "\x0D\x0A" . $text ) . "</pre>" );
		}
		default {
			return $tx->format( $formatbang . "\x0D\x0A" . $text );
		}
	}
	
	return $tx->format(shift // '');
}

sub get_html{
	my $self = shift;
	return $self->text ? $self->format($self->text) : '';
}


__PACKAGE__->meta->make_immutable;
1;
