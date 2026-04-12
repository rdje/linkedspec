#------------------------------------------------------------------------------
# Package: HTTP::FileAccess
# Purpose: HTTP-domain owner for signed file-access URLs plus the small local
#          HTTP daemon actions that migrated out of legacy `.plg` files.
#------------------------------------------------------------------------------
package HTTP::FileAccess;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: url_for_path
# Purpose : Build the historical signed `getfile.cgi` URL for one filesystem
#           path using the existing Global CGI/http settings.
# Args    : ($path)
# Returns : fully-qualified HTTP URL
#------------------------------------------------------------------------------
sub url_for_path {
 my ($path) = @_;

 require Digest::MD5;
 require File::Spec;
 require Global;

 my $file_desc = "file=" . File::Spec->rel2abs($path);
 my $id = "id=" . Digest::MD5::md5_hex(
  $file_desc,
  Global->set('cgi', 'sepc'),
  Global->md5_encode,
 );

 return "http://" . Global->http_hostport . "/cgi-bin/getfile.cgi?$file_desc&$id";
}

#------------------------------------------------------------------------------
# Function: set_hostport
# Purpose : Preserve the historical helper that sets the active
#           `Global->http_hostport` value from an optional host and port.
# Args    : ($host, $port)
# Returns : assigned "<host>:<port>" value
#------------------------------------------------------------------------------
sub set_hostport : lvalue {
 my ($host, $port) = @_;

 require Global;
 require Sys::Hostname;

 Global->set('http_hostport') =
  ($host || Sys::Hostname::hostname() . Global->http_hostail) . ":" . ($port || Global->http_default_port)
}

#------------------------------------------------------------------------------
# Function: set_localhost
# Purpose : Preserve the historical helper that sets `http_hostport` using the
#           default host logic and one optional explicit port.
# Args    : ($port)
# Returns : assigned "<host>:<port>" value
#------------------------------------------------------------------------------
sub set_localhost : lvalue {
 set_hostport(undef, $_[0])
}

#------------------------------------------------------------------------------
# Function: print_file_links_for_conf
# Purpose : Preserve the historical `http` plugin action as an explicit package
#           function: configure CGI/http state, then print signed links for
#           existing files listed in the supplied action config.
# Args    : ($conf_hashref) with optional `_host`, `_port`, and `_argv`
# Returns : undef after writing the historical link listing to STDOUT
#------------------------------------------------------------------------------
sub print_file_links_for_conf {
 my ($conf) = @_;
 $conf //= {};

 require Global;
 require HUtils;
 require PathSearch;
 require Sys::Hostname;

 Global->set('cgi') = HUtils::Conf(PathSearch->go('cgi'));
 set_hostport(($conf->{_host} || Sys::Hostname::hostname()) . Global->http_hostail, $conf->{_port});

 print "\n";
 foreach my $path (@{$conf->{_argv} || []}) {
  next unless -f $path;
  print " ", url_for_path($path), "\n";
 }
 print "\n";

 return
}

#------------------------------------------------------------------------------
# Function: run_lighttpd_for_conf
# Purpose : Preserve the historical `lighttpd` plugin action as an explicit
#           package function: render the configured lighttpd template with the
#           active host/port and start lighttpd against the generated file.
# Args    : ($conf_hashref) with optional `_notail` and `_port`
# Returns : `system(...)` exit status from the lighttpd invocation
#------------------------------------------------------------------------------
sub run_lighttpd_for_conf {
 my ($conf) = @_;
 $conf //= {};

 require File::Temp;
 require Global;

 my ($host, $port) = _daemon_host_port($conf, 'lighttpd');
 my $lighttpd_conf = _read_text_file(Global->lighttpd_conf);

 $lighttpd_conf =~ s/<server_name>/$host/o;
 $lighttpd_conf =~ s/<server_port>/$port/o;

 my $template_port = $port;
 $template_port =~ s/[^A-Za-z0-9_.-]/_/g;
 my ($fh, $filename) = File::Temp::tempfile("lighttpd_${template_port}_XXXXX", TMPDIR => 1, UNLINK => 1);

 print {$fh} $lighttpd_conf;
 close($fh) or die "Unable to close generated lighttpd config '$filename': $!";

 return system('lighttpd', '-f', $filename);
}

#------------------------------------------------------------------------------
# Function: run_httpd_for_conf
# Purpose : Preserve the historical `httpd` plugin action as an explicit
#           package function: render the configured Apache httpd template with
#           the active host/port/email and run apachectl against the file.
# Args    : ($conf_hashref) with optional `_notail`, `_port`, and `_argv->[0]`
# Returns : `system(...)` exit status from the apachectl invocation
#------------------------------------------------------------------------------
sub run_httpd_for_conf {
 my ($conf) = @_;
 $conf //= {};

 require File::Spec;
 require File::Temp;
 require Global;

 my ($host, $port) = _daemon_host_port($conf, 'httpd');
 my $action = $conf->{_argv} && @{$conf->{_argv}} ? $conf->{_argv}[0] : 'start';
 die "Invalid apachectl action '$action'" unless defined($action) && $action =~ /\A[A-Za-z0-9_.-]+\z/;
 my $httpd_conf = _read_text_file(Global->httpd_conf);
 my $email = Global->author_email_address;

 $httpd_conf =~ s/<server_name>/$host/g;
 $httpd_conf =~ s/<server_port>/$port/g;
 $httpd_conf =~ s/<author_email_address>/$email/o;

 my $template_port = $port;
 $template_port =~ s/[^A-Za-z0-9_.-]/_/g;
 my ($fh, $filename) = File::Temp::tempfile("httpd_${template_port}_XXXXX", TMPDIR => 1, UNLINK => 1);
 my $abs_filename = File::Spec->rel2abs($filename);

 print {$fh} $httpd_conf;
 close($fh) or die "Unable to close generated httpd config '$abs_filename': $!";

 return system('apachectl', '-k', $action, '-f', $abs_filename);
}

sub _daemon_host_port {
 my ($conf, $daemon_name) = @_;

 require Global;
 require Sys::Hostname;

 my $host = Sys::Hostname::hostname() . ($conf->{_notail} ? '' : Global->http_hostail);
 my $port = $conf->{_port} || Global->http_default_port;
 die "Invalid $daemon_name port '$port'" unless defined($port) && $port =~ /\A\d+\z/;

 return ($host, $port);
}

sub _read_text_file {
 my ($path) = @_;

 open(my $fh, '<', $path) or die "Unable to read '$path': $!";
 local $/;
 return <$fh>;
}

1;
