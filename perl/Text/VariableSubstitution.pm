#------------------------------------------------------------------------------
# Package: Text::VariableSubstitution
# Purpose: Text-domain owner for lightweight variable substitution behavior
#          that migrated out of legacy `.plg` files and no longer belongs
#          under plugin-branded scaffolding.
#------------------------------------------------------------------------------
package Text::VariableSubstitution;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: var_subst
# Purpose : Expand one string with regex-driven substitutions using the same
#           low-ceremony behavior historically exposed through `string.plg`.
# Args    : ($string, $subst_re, %subst_data)
# Returns : expanded string
#------------------------------------------------------------------------------
sub var_subst {
 my ($string, $subst_re, %subst_data) = @_;

 return sub {
  local $_ = shift;
  my %h = map { !ref($_) ? $_ : (ref($_) eq 'HASH' ? %$_ : @$_) } @_;
  s{$subst_re}{$h{$1} || $1}ge;
  s/"/\\"/go;
  return eval(qq("$_"))
 }->($string, %subst_data)
}

#------------------------------------------------------------------------------
# Function: var_subst_test
# Purpose : Preserve the historical string-plugin smoke helper while routing
#           its helper calls through normal package owners.
# Args    : ($conf_hashref)
# Returns : undef after printing test output
#------------------------------------------------------------------------------
sub var_subst_test {
 require Global;
 require HUtils;
 require HTML::PathLinks;
 require PathSearch;
 require Plugin::HTTP;

 open(my $f, $_[0]{_argv}[0]);
 local $/;
 my $file = <$f>;

 Global->set('cgi') = HUtils::Conf(PathSearch->go('cgi'));
 Plugin::HTTP::set_http_localhost();
 my $fo = HTML::PathLinks::link_path_tokens($file);

 print "var_subst_test: ($fo)\n";
 return
}

1;
