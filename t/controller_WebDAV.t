use strict;
use warnings;
use Test::More;


use Catalyst::Test 'HomeworkBlog';
use HomeworkBlog::Controller::WebDAV;

ok( request('/webdav')->is_success, 'Request should succeed' );
done_testing();
