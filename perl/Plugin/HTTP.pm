#------------------------------------------------------------------------------
# Package: Plugin::HTTP
# Purpose: Package-backed owner for lightweight URL-building behavior being
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

1;
