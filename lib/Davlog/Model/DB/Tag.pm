use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Model::DB::Tag;
use base qw/Davlog::Model::Validatable/;

=head1 NAME
Davlog::Model::DB::Tag - タグモデルクラス

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
		exception => {tag_no => {'!=' => $self->tag_no}}
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

sub uri{
	return '/tag/' . shift->stub;
}

1;