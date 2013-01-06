use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Model::Request::Entry;
use Moose;
use HTML::FormHandler::Moose;
extends qw'HTML::FormHandler';
use Moose::Util::TypeConstraints;

has_field( 'title' => (type => 'Text'));
has_field( 'text'  => (type => 'TextArea'));
has_field( 'tags'  => (type => 'Checkbox'));
has_field( 'stub'  => (type => 'Text'));
has_field( 'date'  => (type => 'Text'));


has '+name' => ( default => 'entry' );
has '+html_prefix' => ( default => 1 );


sub new {
	my ( $class, $request ) = ( shift, @_ );
	my $self = $class->next::method( @_ );
	
	return $self unless defined $request;

	$self->process( params => $request->params );
	return $self;
}

1;