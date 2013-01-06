package Davlog::View::WebDAV;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    ENCODING   => 'utf8',
    content_type => 'text/xml',
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
