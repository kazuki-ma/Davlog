use utf8;
use v5.10;
use strict;
use warnings;

package Davlog;
#use open IO => ':utf8';
#use open ':std';
use Moose;
use namespace::autoclean;
use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use lib '/Users/kazuki/catalyst_textxatena/blib/lib';

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    
    StackTrace
    
    Session
    Session::Store::File
    Session::State::Cookie
    
    Authentication
        
    Unicode
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in homeworkblog.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    ENCODING   => 'utf8',
    name => 'Davlog',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
);



 __PACKAGE__->config(
      'View::WebDAV' => {},
  );

# Configure SimpleDB Authentication
#__PACKAGE__->config(
#	'Plugin::Authentication' => {
#		default => {
#			class         => 'SimpleDB',
#			user_model    => 'DB::User',
#			password_type => 'self_check',
#		},
#	},
#);  
__PACKAGE__->config( authentication => {
        default_realm => 'Davlog',
        realms => {
            'Davlog' => {
                credential => {
                    class => 'HTTP',
                    type  => 'basic', # or 'digest' or 'basic'
                    password_type  => 'clear',
                    password_field => 'password'
                },
                store => {
                    class => 'Minimal',
                    users => {
                        user => { password => "pass", },
                    },
                },
            },
        }
});


# Start the application
__PACKAGE__->setup();


=head1 NAME

Davlog - Catalyst based application

=head1 SYNOPSIS

    script/homeworkblog_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Davlog::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Kazuki Matsuda

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
