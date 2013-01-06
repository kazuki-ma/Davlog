use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Davlog::Controller::Admin::Login - ログインコントローラ

=head1 DESCRIPTION

ユーザがログインしていなければログインを強制する

=head1 METHODS

=cut


=head2 __PACKAGE__->config
パッケージのネームスペース（URLの先頭）を .admin/entry に設定する．
=cut
__PACKAGE__->config(
	namespace => '',
);


=head2 
ログインを強制する（実際は無くて可能）
=cut
sub login :Path('/login') Args(0) {
    my ( $self, $c ) = @_;
	$c->authenticate({}, 'Davlog') unless $c->user_exists;
	$c->response->redirect($c->uri_for('/'));
}

__PACKAGE__->meta->make_immutable;

1;
