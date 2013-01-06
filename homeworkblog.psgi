use strict;
use warnings;

use Davlog;

my $app = Davlog->apply_default_middlewares(Davlog->psgi_app);
$app;

