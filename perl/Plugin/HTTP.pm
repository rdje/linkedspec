#------------------------------------------------------------------------------
# Package: Plugin::HTTP
# Purpose: Package-backed owner for lightweight HTTP/file-link behavior being
#          migrated out of legacy `.plg` files.
#------------------------------------------------------------------------------
package Plugin::HTTP;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: httplink
# Purpose : Build the historical signed `getfile.cgi` URL for one filesystem
#           path using the existing Global CGI/http settings.
# Args    : ($path)
# Returns : fully-qualified HTTP URL
#------------------------------------------------------------------------------
sub httplink {
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
# Function: set_http_hostport
# Purpose : Preserve the historical helper that sets the active
#           `Global->http_hostport` value from an optional host and port.
# Args    : ($host, $port)
# Returns : assigned "<host>:<port>" value
#------------------------------------------------------------------------------
sub set_http_hostport : lvalue {
 my ($host, $port) = @_;

 require Global;
 require Sys::Hostname;

 Global->set('http_hostport') =
  ($host || Sys::Hostname::hostname() . Global->http_hostail) . ":" . ($port || Global->http_default_port)
}

#------------------------------------------------------------------------------
# Function: set_http_localhost
# Purpose : Preserve the historical helper that sets `http_hostport` using the
#           default host logic and one optional explicit port.
# Args    : ($port)
# Returns : assigned "<host>:<port>" value
#------------------------------------------------------------------------------
sub set_http_localhost : lvalue {
 set_http_hostport(undef, $_[0])
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
 set_http_hostport(($conf->{_host} || Sys::Hostname::hostname()) . Global->http_hostail, $conf->{_port});

 print "\n";
 foreach my $path (@{$conf->{_argv} || []}) {
  next unless -f $path;
  print " ", httplink($path), "\n";
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
 require Sys::Hostname;

 my $host = Sys::Hostname::hostname() . ($conf->{_notail} ? '' : Global->http_hostail);
 my $port = $conf->{_port} || Global->http_default_port;
 die "Invalid lighttpd port '$port'" unless defined($port) && $port =~ /\A\d+\z/;
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

sub _read_text_file {
 my ($path) = @_;

 open(my $fh, '<', $path) or die "Unable to read '$path': $!";
 local $/;
 return <$fh>;
}

1;
