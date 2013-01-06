use utf8;
package Davlog::View::WWW;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    content_type => 'text/html',
    WRAPPER => 'WWW/grand-template.tt',
    ENCODING   => 'utf8',
);

=head1 NAME

Davlog::View::HTML - TT View for Davlog

=head1 DESCRIPTION

TT View for Davlog.

=head1 SEE ALSO

L<Davlog>

=head1 AUTHOR

Kazuki Matsuda

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
