use utf8;
use v5.10;
use strict;
use warnings;
package Davlog::Model::DB::Entry;
use base qw/Davlog::Model::Validatable/;

=head1 NAME
Davlog::Model::DB::Entry - エントリモデルクラス

=head1 DESCRIPTION

=head1 METHODS
=cut

=head2 validate
=cut
sub validate {
	my $self = shift;
	$self->{errors} = [];
	
	# stub, title が unique であることを確認する．
	$self->unique_constraint(
		cols => [ qw/stub title/ ],
		exception => {entry_no => {'!=' => $self->entry_no}}
	);
	
	# stub, title に値が入っていることを確認する．
	$self->notnull_constraint(
		cols => [ qw/stub title/ ]
	);
	
	unless ( $self->stub =~ m|^[a-zA-Z0-9][a-zA-Z0-9()_.-]*$| ) {
		push $self->{errors}, "stub は アルファベットまたは数字で始まる必要があり，使用可能な文字は以下の通りです <br />"
		. "a-z, A-Z, 0-9, (), _ -";
	}
	
	return $self->{errors};
}

=head2 get_html
=cut
sub get_html {
	my $self = shift;
	return $self->current_revision ? $self->current_revision->get_html : '';
}

=head2 uri
=cut
sub uri {
	my $self = shift;
	my $date = $self->date;
	return $date->strftime('/%Y/%m/%d/') . $self->stub;
}

=head2 text
=cut
sub text {
	my $self = shift;
	my $text = shift;
	if ( defined $text ) {
		my $new_revision = $self->revisions->create( { text => $text, } );
		$self->revision_no( $new_revision->revision_no );
		$self->update();
		return 1;
	}
	else {
		return $self->current_revision ? $self->current_revision->text : '';
	}
}


1;