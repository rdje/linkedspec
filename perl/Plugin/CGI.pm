#------------------------------------------------------------------------------
# Package: Plugin::CGI
# Purpose: Package-backed owner for lightweight CGI/link-formatting plugin
#          behavior being migrated out of legacy `.plg` files.
#------------------------------------------------------------------------------
package Plugin::CGI;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: file_list_path2http
# Purpose : Convert path-like tokens in one string into HTML links using the
#           package-backed HTTP owner for URL generation.
# Args    : ($text)
# Returns : linked HTML text
#------------------------------------------------------------------------------
sub file_list_path2http {
 require Global;
 require Plugin::HTTP;
 require Text::VariableSubstitution;

 return join "", map {
  !/#/o ? join("", map {
   m/\//o ? do {
    my $subst = Text::VariableSubstitution::var_subst($_, qr/\$(\w+)/o, %ENV, 'VOB_ROOT' => Global->VOB_ROOT);
    my $http = Plugin::HTTP::httplink($subst);
    qq{<A HREF="$http">$_</A>};
   } : $_
  } split /(\S*\/\S+)/o, $_) : $_
 } split /(#.*)/o, $_[0]
}

1;
