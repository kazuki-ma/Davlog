use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Controller::WebDAV;
use Moose;
use namespace::autoclean;
use URI::Escape;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Davlog::Controller::WebDAV - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

__PACKAGE__->config(
	namespace => 'dav',
	action => { '*' => { Args => 0} },
);


sub auto : Private {
	my ( $self, $c ) = @_;
	$c->stash->{current_view} = "WebDAV";
	$c->authenticate({}) unless $c->user_exists;

	( my $path = $c->request->path ) =~ s|/$||;

	$c->stash(
		protocol => 'http',
		host     => $c->request->header('Host'),
		path     => $path,
	);
	
	
	$c->res->headers->push_header(
		Allow => 'OPTIONS,GET,HEAD,POST,DELETE,TRACE,PROPFIND,PROPPATCH,COPY,MOVE,LOCK,UNLOCK',
		DAV             => "1,2",
		DAV             => '<http://apache.org/dav/propset/fs/1>',
		'MS-Author-Via' => 'DAV',
		pragma          => 'no-cache',
	);

	$c->res->content_type("text/xml; charset=utf-8");
	
	given ( $c->request->method ) {
		when ( /OPTIONS/ ) {
			$c->response->body('');
			$c->response->status(200);
			$c->detach;
		}
	}
	
	return 1;
}

sub dav : Path('') Args(0) ActionClass('REST') {
}

sub dav_PROPFIND : Private {
	my ( $self, $c ) = @_;

	my ( $rs ) = $c->model('DB::ViewEntryMeta')->search(
		{},
		{
			select => [{max => 'create_date'}, {max => 'update_date'}],
			as     => [qw/ctime mtime/],
		}
	)->all;
	

	$c->stash(
		ctime => DateTime->new(year=>2010), # 適当に古い値．本当は $rs->get_column('ctime') のはず……
		mtime => DateTime->new(year=>2010), # 適当に古い値．
		files => [ 
			(map { {
				update_date => $_->update_date,
				create_date => $_->create_date,
				fname       => ( $_->stub . ',' . $_->title . '.md' ),
				size        => $_->length,
			} } $c->model('DB::ViewEntryMeta')->all),
			{ fname => 'tags', type => 'dir'}
		],
	);

	$c->stash( template => 'WebDAV/propfind.xml.tt' );
	$c->res->content_type("text/xml; charset=utf-8");

	$c->response->status(207);
}


=head2 entry
個別のエントリに対するアクセス．メソッドに応じてディスパッチする．
=cut

sub entry : Path('') Args(1) ActionClass('REST') {
	my ( $self, $c, $entry_path ) = (@_);
	utf8::decode($entry_path);

	if ( $entry_path =~ /^\\./ ) {
		$c->response->status(404);
		$c->response->body('');
		return;
	}

	my ( $stub ) = split( /,/, $entry_path, 2);

	unless ( defined $stub ) {
		given ( $c->request->method ) {
			when ('MKCOL') {
				$c->response->status(200);
			}
			when ('PUT') {
				$c->response->status(422);
			}
			default {
				$c->response->status(404);
			}
		}
		$c->response->body("");
		$c->detach;
	}

	my $entry = $c->model("DB::Entry")->find({stub => $stub});
	
	if ( $entry ) {
		unless ( $entry and $entry_path eq ( $entry->stub . ',' . $entry->title . '.md' ) ) {
			$c->error('not found');
			$c->response->status(404);
			$c->detach;
		}
	}
	
	$c->stash->{entry} = $entry;
}

sub entry_PROPFIND : Private {
	my ( $self, $c ) = @_;
	my $entry = $c->stash->{entry};
	
	if ( $entry ) {
		$c->stash(
			ctime    => $entry->create_date,
			mtime    => $entry->update_date,
			template => 'WebDAV/propfind.xml.tt',
			path     => $c->request->path,
		);
	}
	else {
		$c->response->status(404);
		$c->response->body('');
	}
}

sub entry_GET : Private {
	my ( $self, $c, $entry_path ) = @_;
	my $entry = $c->stash->{entry};
	utf8::decode($entry_path);	
	
	if ( $entry && $entry->current_revision ) {
		my $text = $entry->text;
		$c->response->body($text);
		$c->response->header('Content-Type' => 'text/plain; charset=UTF-8');
	}
}

sub entry_PUT : Private {
	my ( $self, $c, $entry_path ) = @_;
	my $h = $c->request->body;
	my $entry = $c->stash->{entry};
	
	utf8::decode($entry_path);
	
	unless ( $entry ) {
		my ( $stub, $title ) = split( ',', $entry_path, 2 );
		$title =~ s|\.\w+$||;
		$entry = $c->model('DB::Entry')->new({
			stub  => $stub,
			title => $title,
			date  => DateTime->now,
		});
		
		my $errors = $entry->validate;
		if ( @$errors ) {
			$c->error(@$errors);
			$c->detach;
		}
		$entry->insert;
	}
	
	binmode $h, ":utf8";
	my $text = join '', <$h>;
	$entry->text( $text );
	$entry->update;

	$c->response->status(201);
	$c->response->header('Content-Type' => 'text/plain; charset=UTF-8' );
	$c->response->body('updated');
}

sub entry_DELETE : Private {
	my ( $self, $c ) = @_;
	my $h = $c->request->body;
	my $entry = $c->stash->{entry};

	unless ( $entry ) {
		$c->response->body("not found");
		$c->response->status(404);
		$c->detach;		
	}
	
	$entry->delete;
	
	$c->response->status(202);
	$c->response->body("Accepted");
}

sub entry_OPTIONS : Private {
	my ( $self, $c ) = @_;
	$c->response->body('');
}

sub entry_LOCK : Private {
	my ( $self, $c ) = @_;
	$c->response->status(202);
	$c->response->body("Accepted");
}

sub entry_UNLOCK : Private {
	my ( $self, $c ) = @_;
	$c->response->status(202);
	$c->response->body("Accepted");	
}
sub entry_CHECKOUT : Private {
	my ( $self, $c ) = @_;
	$c->response->status(202);
	$c->response->body("Accepted");
}

sub entry_MOVE : Private {
	my ( $self, $c ) = @_;
	$c->log->info($c->request->headers->as_string);

	my $entry = $c->stash->{entry};	
	
	unless ( $entry ) {
		$c->response->body("not found");
		$c->response->status(404);
		$c->detach;		
	}
	
	my $destination = uri_unescape($c->request->header('Destination'));
	utf8::decode($destination);
	my $fname = ($destination =~ s|.*/||r);
	my $dest_info = split_stub_and_title($fname);
	
	$entry->stub($dest_info->{stub});
	$entry->title($dest_info->{title});
	my $errors = $entry->validate;
	if ( @$errors ) {
		$c->response->status(406); #?
		$c->detach;
	}
	
	$entry->update;
	
	$c->response->status(202);
	$c->response->body("Accepted");	
}


sub split_stub_and_title {
	my $fname = shift;
	
	$fname =~ m|^([^,]+),([^/]+)\.\w+$|;
	
	my $retval = {};
	$retval->{stub} = $1;
	$retval->{title} = $2;
	
	return $retval;
}

sub tags : Path('tags') Args(0) ActionClass('REST') {
	
}

sub tags_PROPFIND {
	my ( $self, $c ) = @_;
	my $tags = $c->model('DB::Tag')->search_rs;
	
	$c->stash(
		ctime => DateTime->new(year=>2010), # 適当に古い値．
		mtime => DateTime->new(year=>2010), # 適当に古い値．
		
	);

	$c->stash(
		template => 'WebDAV/propfind.xml.tt',
		ctime    => DateTime->new(year=>2010), # 適当に古い値．本当は $rs->get_column('ctime') のはず……
		mtime    => DateTime->new(year=>2010), # 適当に古い値．
		path     => '/dav/tags',
		files    => [ 
			(map { {
				fname => ( $_->stub . ','. $_->title ),
				type  => 'dir',  
			} } $c->model('DB::Tag')->all),
		],
	 );
	$c->res->content_type("text/xml; charset=utf-8");

	$c->response->status(207);
}

sub tag : Path('tags') Args(1) ActionClass('REST') {
	my ( $self, $c, $tag_path ) = @_;
	my ( $tag_stub ) = split( ',', $tag_path, 2 );
	my $tag = $c->model('DB::Tag')->find({stub => $tag_stub});	
	$c->stash->{tag} = $tag;
}

sub tag_PROPFIND : Private {
	my ( $self, $c ) = @_;
	my $tag = $c->stash->{tag};
	
	unless ($tag) {
		$c->error('Not Found');
		$c->detach;
	}
	
	$c->stash(
		template => 'WebDAV/propfind.xml.tt',
		ctime    => DateTime->new(year=>2010), # 適当に古い値．本当は $rs->get_column('ctime') のはず……
		mtime    => DateTime->new(year=>2010), # 適当に古い値．
		path     => '/' . $c->request->path,
		files    => [ 
			(map { {
				fname => ( $_->stub . ','. $_->title . '.md' ),
				type  => 'file',
				update_date => $_->update_date,
				create_date => $_->create_date,
				size        => 0
			} } $tag->entries->all )
		],
	);
}

sub tag_MKCOL : Private {
	my ( $self, $c, $tag_path ) = @_;
	utf8::decode($tag_path);
	my ( $tag_stub, $tag_title ) = split( /,/, $tag_path );
	
	my $tag = $c->model('DB::Tag')->new({
		stub  => $tag_stub,
		title => $tag_title
	});
	
	my $errors = $tag->validate;
	if ( @$errors ) {
		$c->errors(@$errors);
		$c->detach;
	}
	
	$tag->insert;
	$c->response->status(200);
	$c->response->body('');
}

sub tag_DELETE : Private {
	my ( $self, $c ) = @_;
	my $tag = $c->stash->{tag};
	
	$tag->delete;
	
	$c->response->status(200);
	$c->response->body('');
}

sub tag_entry : Path('tags') Args(2) ActionClass('REST') {
	my ( $self, $c, $tag_path, $entry_path ) = @_;
	utf8::decode($tag_path);
	utf8::decode($entry_path);
	
	my ( $tag_stub ) = split( /,/, $tag_path, 2 );
	my ( $entry_stub ) = split( /,/, $entry_path, 2 );
	
	$c->stash->{tag}   = $c->model('DB::Tag')->find({ stub => $tag_stub });
	$c->stash->{entry} = $c->model('DB::Entry')->find({ stub => $entry_stub });
}

sub tag_entry_PUT : Private {
	my ( $self, $c ) = @_;
	my $tag   = $c->stash->{tag};
	my $entry = $c->stash->{entry};
	
	if ( ! $tag and ! $entry ) {
		$c->error('Not Found');
		$c->detach;
	}
	
	my $entry_tag = $c->model('DB::EntryTag')->new({
		tag_no   => $tag->tag_no,
		entry_no => $entry->entry_no,
	});
	
	$entry_tag->insert;
	
	$c->response->status(200);
	$c->response->body('');
}

sub tag_entry_DELETE : Private {
	my ( $self, $c ) = @_;
	my $tag   = $c->stash->{tag};
	my $entry = $c->stash->{entry};
	
	if ( ! $tag and ! $entry ) {
		$c->error('Not Found');
		$c->detach;
	}

	my $tag_entry = $c->model('DB::EntryTag')->find({
		tag_no   => $tag->tag_no,
		entry_no => $entry->entry_no,
	});
	
	unless ( $tag_entry ) {
		$c->error('Not Found');
		$c->detach;		
	}
	
	$tag_entry->delete;
	
	$c->response->status(200);
	$c->response->body('');
}

sub tag_entry_PROPFIND : Private {
	my ( $self, $c ) = @_;
	$c->stash(
		template => 'WebDAV/propfind.xml.tt',
		ctime    => DateTime->new(year=>2010), # 適当に古い値．本当は $rs->get_column('ctime') のはず……
		mtime    => DateTime->new(year=>2010), # 適当に古い値．
		path     => $c->request->path,
	);
}

sub tag_entry_LOCK : Private {
	my ( $self, $c ) = @_;
	$c->response->status(200);
	$c->response->body('');
}

sub tag_entry_GET : Private {
	my ( $self, $c ) = @_;
	my $tag   = $c->stash->{tag};
	my $entry = $c->stash->{entry};
	
	unless ( $tag and $entry ) {
		$c->response->status(404);
		$c->detach;
	}
	
	$self->entry_GET($c);
}

sub default : Private {
	
}

__PACKAGE__->meta->make_immutable;

1;
