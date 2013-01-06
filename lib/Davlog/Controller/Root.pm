use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config( namespace => '' );

=head1 NAME

Davlog::Controller::Root - Root Controller for Davlog

=head1 DESCRIPTION

URL 構成は以下の通り
  / => エントリ一覧，最初の10件
  /?page=2 => 11件〜21件目

  /tag/tag_name  => タグに該当する記事一覧
  /tag/tag_name?page=2

  /dav => WebDAV 用アクセスパス．エントリ一覧
  /dav/first,title.md エントリ
  
  
  /2012/01/01/first => entry_stub = first のエントリ
  /2012/01/01/first/revisions => first の更新履歴
  /2012/01/01/first/revisions/01 => first のリビジョンの01版
  
  
  
  /.admin/entry/edit?entry_no=01 => 01 番目のエントリーを編集する
  /.admin/entry/create => 新しいエントリーを作成する
  /.admin/login ログインする
  
=cut

sub default : Private {
	my ( $self, $c ) = @_;
	
	$c->response->status(404);
	$c->error("Not Found");
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
	my ( $self, $c ) = @_;
	
	my @pans = ({uri => '', text => ''});
	for my $stub (split qr'/', $c->request->path) {
		push @pans, {uri => ($pans[-1]->{uri} . "/$stub"), text => "$stub"}
	}
	$pans[0]->{uri}  = '/';
	$pans[0]->{text} = 'localhost:3000';
	
	$c->stash(
		pans => \@pans,
		tags => [$c->model('DB::Tag')->all]
	);
	
	if ( scalar @{$c->error} ) {
		$c->response->status(400) if 200 eq $c->response->status;

		$c->stash({
			template => 'WWW/error.tt',
			page_title => 'Error',
			fatail_error_messages => $c->error,
			status_code => $c->response->status
		});
		
		$c->clear_errors;
	}
}

__PACKAGE__->meta->make_immutable;

1;
