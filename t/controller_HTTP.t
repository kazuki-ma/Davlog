use strict;
use warnings;
use Test::More;


use Catalyst::Test 'HomeworkBlog';
use HomeworkBlog::Controller::HTTP;

ok( request('/http')->is_success, 'Request should succeed' );
done_testing();
