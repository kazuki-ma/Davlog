use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Controller::Tag;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head2 tag
タグ毎の記事一覧を表示する
=cut
sub tag : Path('/tag/') Args(1) {
	my ( $self, $c, $tag_stub ) = @_;
	$c->log->debug("Tag = ${tag_stub}");

	my $tag = $c->model('DB::Tag')->find({ stub => $tag_stub });
	unless ( defined $tag ) {
		$c->error("指定されたタグは存在しません");
		$c->detach;
	}
	
	$c->stash(
		entry_result_set => $tag->entries->search_rs,
		page_title       => sprintf('Tag : %s の記事一覧', $tag->title),
		template         => 'WWW/list.tt',
	);
	$c->forward('WWW', 'paged_entries');
}

=head2 tag_list
タグの一覧を表示
=cut
sub tag_list : Path('/tag') : Args(0) {
	my ( $self, $c ) = @_;
	my $tags = $c->model('DB::Tag')->all;
	$c->stash(
		{
			page_title => 'タグ一覧',
			tags       => $tags,
			template   => 'WWW/tag_list.tt',
		}
	);
}

1;