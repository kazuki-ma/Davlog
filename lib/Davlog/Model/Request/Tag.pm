use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Model::Request::Tag;
use Moose;
use HTML::FormHandler::Moose;
extends qw'HTML::FormHandler';
use Moose::Util::TypeConstraints;

has_field( 'stub'      => (type => 'Text'));
has_field( 'title'     => (type => 'Text'));
has_field( 'edit'      => (type => 'Submit'));


has '+name' => ( default => 'tag' );
has '+html_prefix' => ( default => 1 );

sub new {
	my ( $class, $request ) = ( shift, @_ );
	my $self = $class->next::method( @_ );
	
	return $self unless defined $request;

	$self->process( params => $request->params );
	return $self;
}

1;