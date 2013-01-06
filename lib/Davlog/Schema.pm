use utf8;
use v5.10;
use strict;
use warnings;

package Davlog::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-10-29 18:33:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X06WohWGcW6JH3WzBRp+OQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
