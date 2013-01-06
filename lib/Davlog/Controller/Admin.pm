use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Controller::Admin;
use Moose;
use namespace::autoclean;
use Text::Xatena;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(
	namespace => '.admin',
);

=head1 Davlog::Controller::Admin
=cut

=head2 auto
認証を強制する
=cut
sub auto : Private{
	my ( $self, $c ) = @_;
	$c->log->info($c->request->headers->as_string);
	
	$c->authenticate({}) unless $c->user_exists;
	$c->stash({
		current_view => 'WWW',
		page_title   => '管理画面',
	});
	return 1;
}

=head2 admin
アドミン用ページの一覧を作成する．
=cut
sub admin : Path('') Args(0) {
	my ( $self, $c ) = @_;
	$c->stash(
		template => 'WWW/admin/index.tt'
	);
}


1;
