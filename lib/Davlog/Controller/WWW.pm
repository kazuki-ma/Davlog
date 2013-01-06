use utf8;
use v5.10;
use strict;
use warnings;
package Davlog::Controller::WWW;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME
Davlog::Controller::WWW - ウェブコントローラ

=head1 DESCRIPTION
通常の画面アクセスを引き受ける

=head1 METHODS
=cut

__PACKAGE__->config(
	namespace => '',
);


=head2 auto
=cut
sub auto : Private {
	my ( $self, $c ) = @_;
	$c->stash->{current_view}   = 'WWW';
	$c->stash->{user_exists}    = $c->user_exists;
	$c->stash->{error_messages} = [];
	return 1;
}

=head2 index
デフォルトの一覧を表示する
=cut
sub index : Path('/') Args(0) {	
	my ( $self, $c ) = @_;
	
	my $all_rs = $c->model('DB::Entry');
	$c->stash(
		entry_result_set => $all_rs,
		page_title       => 'Welcome',
		);
	
	$c->detach('paged_entries')	
}



=head2 paged_entries
エントリの ResultSet を元に，パラメータに応じてそのページの一部を表示する．
=cut
sub paged_entries :Private{
	my ( $self, $c ) = @_;
	
	my $all_rs = $c->stash->{entry_result_set}->search_rs({},{order_by => 'date DESC'});
	my $request_page = $c->request->params->{page} || 1;
	
	my $count  = $all_rs->count;
	my $paged_entries = $all_rs;
	
	my $paged    = $count > 10;
	my $has_next = $count > (10 * $request_page);
	my $has_prev = $paged && ($request_page > 1);
	
	$c->stash(
		page     => $request_page,
		entries  => $paged_entries,
		template => 'WWW/paged_entry_list.tt'
	);	
}

=head2 show_entry
エントリを表示する
=cut
sub entry : Regex('^(\d{4})/(\d{2})/(\d{2})/([^/]+)$') {
	my ( $self, $c ) = @_;
	my ( $yyyy, $mm, $dd, $entry_stub ) = @{$c->request->captures};
	my $entry = $c->model('DB::Entry')->find({stub => $entry_stub});
	
	if (! defined $entry) {
		$c->response->status(404);
		$c->error('not found');
		$c->detach;
	}

	$c->stash(entry => $entry);

	if ( $entry->date->strftime('%Y-%m-%d') ne "$yyyy-$mm-$dd" ) {
		my $uri = $entry->uri;
		$c->response->redirect($c->uri_for($uri));
	}

	$c->stash(
		page_title => $entry->title,
		template   => 'WWW/entry.tt',
	 );
}

=head2 entries_date_index
日別，月別，年別でエントリーのタイトル一覧を表示する
=cut
#sub entries_by_day : Regex('\d{4}') Path('/') Args(3)  {
sub entries_date_index : Regex('^(\d{4})(?:/(\d{2}))?(?:/(\d{2}))?$') {
	my ( $self, $c ) = @_;
	my ( $yyyy, $mm, $dd ) = @{$c->request->captures};

	my ( $from, $to, $title );
	
	
	unless ( $c->request->path ~~ m|\d{4}(?:/\d{2}(?:/\d{2})?)?| ) {
		$c->error('Bad Request');
		$c->detach;
	}
	
	if ($dd) {
		$from = DateTime->new(year => $yyyy, month => $mm, day => $dd); 
		$to   = $from->clone->add(days => 1);		
		$title = sprintf('%s年%s月%s日の記事一覧', $yyyy, $mm, $dd);		
	} elsif($mm) {
		$from = DateTime->new(year => $yyyy, month => $mm); 
		$to   = $from->clone->add(months => 1);
		$title = sprintf('%s年%s月の記事一覧', $yyyy, $mm);		
	} else {
		$from = DateTime->new(year => $yyyy); 
		$to   = $from->clone->add(years => 1);
		$title = sprintf('%s年の記事一覧', $yyyy);
	}
	
	my $entry = $c->model('DB::Entry')->search_rs({
	}, {
		where => {
			'date(date)' => {
				'between' => [
					$from->strftime('%Y-%m-%d'),
				 	$to->strftime('%Y-%m-%d')
				 ],
			}
		}
	});
	
	$c->stash(
		entry_result_set => $entry,
		page_title       => $title
	);
	
	$c->forward('paged_entries');
}


#=head2 revision
#エントリーの過去の版一覧を表示する．
#=cut
#sub revision_list : Private {
#	my ( $self, $c ) = @_;
#	
#	$c->stash(
#		{
#			revisions  => [ $c->stash->{entry}->revisions->all ],
#			template   => 'WWW/revision_list.tt',
#			page_title => 'Revision Log',
#		}
#	);
#}
#
#
#sub revision : Private {
#	my ( $self, $c, $revision_no ) = @_;
#	$c->stash(
#		{
#			revisions  => [ $c->stash->{entry}->revisions->find($revision_no) ],
#			page_title => 'Revision Log',
#		}
#	);
#}



__PACKAGE__->meta->make_immutable;

1;