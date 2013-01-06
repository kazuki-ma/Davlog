use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Controller::Admin::Entry;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 Davlog::Controller::Admin::Entry;

Entry Model の CRUD を受け付ける
=cut

=head2 __PACKAGE__->config
パッケージのネームスペース（URLの先頭）を .admin/entry に設定する．
=cut
__PACKAGE__->config(
	namespace => '.admin/entry',
);

sub auto : Private {
	my ( $self, $c ) = @_;
	$c->stash->{page_title} = '記事管理';
	return 1;
};

=head2 index
/.admin/entry/ で既存の記事一覧を表示する
=cut
sub show_list : Path('') {
	my ( $self, $c ) = @_;
	my $entry_rs = $c->model('DB::Entry')->search_rs;
	
	$c->stash(
		entries    => [$entry_rs->all],
		page_title => '記事一覧',
		template   => 'WWW/admin/entry/show_list.tt'
	);
}

=head2 create
記事を新規作成する
=cut
sub create : Path('create') ActionClass('REST') {
	my ( $self, $c ) = @_;
	$c->stash(
		page_title => '新規作成',
		template => 'WWW/admin/entry/edit.tt',
	);
}

=head2 create_GET
新規アクセス向けに，記事の作成フォーム View を開く．その際，デフォルト値を設定する．
=cut
sub create_GET {
	my ( $self, $c ) = @_;
	
	my $new_entry = $c->model('Request::Entry')->new();
	my $entry_no  = $c->request->params->{entry_no};

	# 新しい記事の作成

	my $now = DateTime->now();
	$new_entry->process(
		params => {
			'entry.date' => $now,
			'entry.stub' => $now->strftime('%Y-%m-%d_%H-%M-%S'),
		}
	);

	$c->stash(
		entry_form => $new_entry,
	);
}

sub create_POST {
	my ( $self, $c ) = @_;
	$self->edit_POST( $c );
}


=head2 update
記事を編集する．
実際には ActionClass('REST') を使って， edit_GET と edit_POST にディスパッチする．
=cut
sub edit : Path('edit') ActionClass('REST') {
	my ( $self, $c ) = @_;
	$c->stash(
		page_title => '記事更新',
		template => 'WWW/admin/entry/edit.tt',
	);
	
	if ($c->request->params->{action} ~~ 'delete') {
		$c->response->redirect( $c->uri_for('/.admin/entry/delete', {entry_no => $c->request->params->{entry_no}}) );
		$c->detach;
	}
}


=head2 edit_GET
編集のためのフォームを作成する．既存の記事があれば，その記事データをフォームに挿入し View に返す．
=cut

sub edit_GET {
	my ( $self, $c ) = @_;
	
	my $new_entry = $c->model('Request::Entry')->new();
	my $entry_no  = $c->request->params->{entry_no};
	my $e = $c->model('DB::Entry')->find($entry_no);
	
	unless ( defined $e ) {
		$c->response->status(404);
		$c->error("記事番号 $entry_no は既に存在しません．");
		$c->detach;
	}
	
	$new_entry->process(
		params=>{
			'entry.title' => $e->title // '',
			'entry.text'  => $e->text // '',
			'entry.stub'  => $e->stub // '',
			'entry.date'  => $e->date,
		}
	);
	$c->stash(
		entry_tags => [ ( map { {stub => $_->stub} } $e->tags ) ],
	);

	$c->stash(
		entry_form => $new_entry,
	);
}

=head2 edit_POST
エントリーを編集する
=cut
sub edit_POST {
	my ( $self, $c ) = @_;
	my $new_entry = $c->model('Request::Entry')->new($c->request);
	my $params    = $c->request->params;
	my $entry_no  = $c->request->params->{entry_no};

	my @tag_stubs = ('ARRAY' eq ref $new_entry->value->{tags}) ? @{$new_entry->value->{tags}} : ($new_entry->value->{tags});
	
	$c->stash(
		entry_form => $new_entry,
		entry_tags => [ map { {stub => $_} } @tag_stubs],
	);

	# Error Check
	my $val = {%{$new_entry->value}};
	$val->{entry_no} = $entry_no if ( defined $entry_no );
	
	my $errors = $self->check_errors($c, {value => $val});
	
	
	if ( @$errors ) {
		$c->stash(error_messages => $errors);
		return;
	}
		
	given ( $params->{action} ) {
		when (/preview/) {
			my $revision = $c->model('DB::Revision')->new({text => $new_entry->value->{text}});
			
			$c->stash(
				preview_text  => $revision->get_html,
				preview => $new_entry,
			)			
		}
		when (/post/) { 
			if ( $new_entry->errors ) {
				$c->stash(error_message => [$new_entry->errors]);
			} else {
				$self->edit_impl($c, $new_entry);			
			}
		}
		default { # 再編集
		}
	}
}

=head2 delete
エントリを削除する
=cut

sub delete : Path('delete') ActionClass('REST') {
	my ( $self, $c ) = @_;
	my $entry_no  = $c->request->params->{entry_no};
	my $entry     = $c->model("DB::Entry")->find($entry_no);
	
	unless ( $entry ) {
		$c->error("記事番号 $entry_no を持つ記事は既に存在しません");
		$c->response->status(404);
		$c->detach();
	}
	
	$c->stash->{entry} = $entry;
}

=head2 delete_GET
削除確認フォームを表示する
=cut
sub delete_GET :Private {
	my ( $self, $c ) = @_;
	$c->stash->{template} = 'WWW/admin/entry/delete_confirm.tt';	
}

=head delete_POST
確認がすんだら実際の削除を行う
=cut
sub delete_POST :Private {
	my ( $self, $c ) = @_;
	my $entry = $c->stash->{entry};
	
	given ( $c->request->params->{"entry.delete.confirmed"} ) {
		when (/confirmed/) {
			$entry->delete;
			$c->stash->{template} = "WWW/admin/entry/delete_complete.tt";
		}
		default {
			$c->stash->{template} = 'WWW/admin/entry/delete_confirm.tt';
		}
	}
}

sub check_errors :Private {
	my ( $self, $c, $args ) = @_;
	my $value = $args->{value};
	my $val = {};
	for (qw/title stub date entry_no/) {
		$val->{$_} = ($value->{$_} || '') if defined $value->{$_};
	}
	
	my $entry = $c->model('DB::Entry')->new($val);
	my $errors = $entry->validate;
	
	return $errors;
}

use Try::Tiny;
sub edit_impl :Private {
	my ( $self, $c, $new_entry ) = @_;
	
	my $new_value = $new_entry->value;
	my $entry_no = $c->request->params->{entry_no};
	my $entry;

	my $val = {};
	for (qw/title stub date/) {
		$val->{$_} = $new_value->{$_};
	}
	$val->{entry_no} = $entry_no if ( defined $entry_no );

	my $errors = $self->check_errors( $c, {value => $val} );
	if ( @$errors ) {
		$c->error(@$errors);
		$c->detach;
	}
	
	try {
		
		# Update or Create
		if ( defined $entry_no ) {
			$entry = $c->model('DB::Entry')->find($entry_no);
			$entry->set_columns($val);
		} else {
			$entry = $c->model('DB::Entry')->new($val);
		}
		
		$entry->result_source->schema->txn_do( sub{
			$entry->update_or_insert($val);
			$entry->text($new_value->{text});
		});

	} catch {
		# エラーがあれば表示
		my $e = shift;
		$c->error("$e");
		$c->detach;
	};
	
	my $tags = $new_value->{tags};
	$self->set_tags($c, $entry, $tags);

	$c->stash({
		template   => 'WWW/admin/entry/edit_complete.tt',
		page_title => '投稿完了',
		entry => $entry,
	});
}

sub set_tags :Private {
	my ( $self, $c, $entry, $tags ) = @_;

	$entry->entry_tags->delete;
	
	my @tag_stubs;
	if ('ARRAY' eq ref( $tags ) ) {
		@tag_stubs = @{$tags};
	} else {
		@tag_stubs = (split /,/, $tags);
	}

	# エントリにタグを付ける
	foreach my $tag_stub ( @tag_stubs ) {
		next unless $tag_stub;
		my $tag = $c->model('DB::Tag')->find({
			stub => $tag_stub,
		});
		$entry->add_to_tags($tag);
	}
}


1;