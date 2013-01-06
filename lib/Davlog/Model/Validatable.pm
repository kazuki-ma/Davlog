use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Model::Validatable;

=head1 NAME
Davlog::Model::Validatable - Validatable 基底クラス

=head1 DESCRIPTION

=head1 METHODS
=cut

=head2 unique_constraint(cols => \@columns, exception => \%exception)
=cut
sub unique_constraint {
	my $self = shift;
	my $args = {@_};
	
	for my $col ( @{$args->{cols}} ) {
		my $count_duplicate = $self->result_source->resultset->search(
			{$col => $self->$col, %{$args->{exception}}}
		)->count;
		if ( $count_duplicate ) {
			push $self->{errors}, "$col が重複しています．別の値を設定してください．\n";
		}
	}
}

=head2 notnull_constraint(cols => \@column_names)
=cut
sub notnull_constraint {
	my $self = shift;
	my $args = {@_};
	foreach my $col (@{$args->{cols}}) {
		if ( ! defined $self->$col ) {
			push $self->{errors}, "$col に値が含まれていません．値を入力して下さい．\n";
		}
	}
}

1;