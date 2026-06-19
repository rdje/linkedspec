#------------------------------------------------------------------------------
# Package: HTML::PathLinks
# Purpose: HTML-domain owner for path-token link rendering that migrated out
#          of legacy `.plg` files and no longer belongs under plugin or CGI
#          migration scaffolding.
#------------------------------------------------------------------------------
package HTML::PathLinks;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: link_path_tokens
# Purpose : Convert path-like tokens in one string into HTML links using the
#           package-backed HTTP owner for URL generation.
# Args    : ($text)
# Returns : linked HTML text
#------------------------------------------------------------------------------
sub link_path_tokens {
 require Global;
 require HTTP::FileAccess;
 require Text::VariableSubstitution;

 return join "", map {
  !/#/o ? join("", map {
   m/\//o ? do {
    my $subst = Text::VariableSubstitution::var_subst($_, qr/\$(\w+)/o, %ENV, 'VOB_ROOT' => Global->VOB_ROOT);
    my $http = HTTP::FileAccess::url_for_path($subst);
    qq{<A HREF="$http">$_</A>};
   } : $_
  } split /(\S*\/\S+)/o, $_) : $_
 } split /(#.*)/o, $_[0]
}

1;
