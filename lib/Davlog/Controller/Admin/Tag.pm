use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Controller::Admin::Tag;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 Davlog::Controller::Admin::Tag;

Tag を管理する

=head2 __PACKAGE__->config
パッケージのネームスペース（URLの先頭）を .admin/tag に設定する．
=cut
__PACKAGE__->config(
	namespace => '.admin/tag',
);

=head2 auto
Admin->auto に処理を引き継ぐことでログインを強制する．
ページタイトルを設定する
=cut
sub auto : Private {
	my ( $self, $c ) = @_;
	$c->stash->{page_title} = 'タグ管理';
	return 1;
}

=head2 show_list
タグ一覧の要求
=cut
sub show_list : Path('') {
	my ( $self, $c ) = @_;
	
	my $tags = [$c->model('DB::Tag')->search({}, {order_by => 'title'})->all];
	my $request_tag = $c->model('Request::Tag')->new($c->request);

	$c->stash(
		tag_form => $request_tag,
		tags     => $tags,
		template => 'WWW/admin/tag/show_list.tt',
	);
}

=head2 create
タグ作成コントローラ
=cut
sub create : Path('create') ActionClass('REST') {
}

=head2 create_POST
=cut
sub create_POST : Private {
	my ( $self, $c ) = @_;
	my $request_tag = $c->model('Request::Tag')->new($c->request);
	my $tag = $c->model('DB::Tag')->new({
		title => $request_tag->value->{title},
		stub  => $request_tag->value->{stub},
	});
	
	my $errors = $tag->validate;
	if ( @$errors ) {
		$c->error(@$errors);
		$c->detach;
	}

	$tag->insert;
	$c->response->redirect($c->uri_for('/.admin/tag/'));
	$c->detach();	
}

=head2
タグ削除コントローラ
=cut
sub delete : Path('delete') {
	my ( $self, $c ) = @_;
	my $tag_no = $c->request->params->{tag_no};
	my $tag    = $c->model('DB::Tag')->find($tag_no);
	
	unless ($tag) {
		$c->response->status(404);
		$c->error('Not Found');
		$c->detach;
	}
	
	if ($c->request->params->{confirm}) {
		$tag->delete;
		$c->stash(
			tag      => $tag,
			template => 'WWW/admin/tag/delete_complete.tt',
		);
	} else {
		$c->stash(
			tag      => $tag,
			template => 'WWW/admin/tag/delete_confirm.tt',
		)
	}
}

=head2
タグ編集コントローラ
=cut
sub edit : Path('edit') ActionClass('REST') {
	my ( $self, $c ) = @_;
	my $tag_no = $c->request->params->{tag_no};
	my $request_tag = $c->model('Request::Tag')->new($c->request);

	my $tag = $c->model('DB::Tag')->find($tag_no);
	unless ( $tag ) {
		$c->error("指定されたタグ（タグ番号 $tag_no）は存在しません．");
		$c->detach;
	}
	
	$c->stash->{tag} = $tag;
}

=head2 edit_GET
=cut
sub edit_GET : Private {
	my ( $self, $c ) = @_;
	my $request_tag = $c->model('Request::Tag')->new($c->request);
	my $tag = $c->stash->{tag};
	
	$request_tag->process(params=>{
		'tag.title' => $tag->title,
		'tag.stub'  => $tag->stub,
	});

	$c->stash(
		tag_form  => $request_tag,
		template => 'WWW/admin/tag/edit.tt',
	);		
}

=head2 edit_POST
=cut
sub edit_POST : Private {
	my ( $self, $c ) = @_;
	my $request_tag = $c->model('Request::Tag')->new($c->request);
	my $tag_no = $c->request->params->{tag_no};
	my $tag = $c->model('DB::Tag')->find($tag_no);
	
	given ( $c->request->params->{'action'} ) {
		when( /update/ ) {
			$tag->title($request_tag->value->{title});
			$tag->stub($request_tag->value->{stub});
			my $errors = $tag->validate;
			if ( @$errors ) {
				$c->error(@$errors);
				$c->detach;
			} else {
				$tag->update;
			}
		}
		when ( /delete/ ) {
			$c->response->redirect(
				$c->uri_for('/.admin/tag/delete', {tag_no => $tag_no})
			);
			$c->detach;
		}
	}	
	
	$c->stash(
		tag_form  => $request_tag,
		template => 'WWW/admin/tag/edit.tt',
	);	
}

1;
