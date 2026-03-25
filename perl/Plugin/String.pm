#------------------------------------------------------------------------------
# Package: Plugin::String
# Purpose: Package-backed owner for lightweight string-substitution plugin
#          behavior that is being migrated out of legacy `.plg` files.
#------------------------------------------------------------------------------
package Plugin::String;

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
#           its plugin calls through explicit LinkedSpec dispatch.
# Args    : ($conf_hashref)
# Returns : undef after printing test output
#------------------------------------------------------------------------------
sub var_subst_test {
 require Global;
 require HUtils;
 require LinkedSpec;
 require PathSearch;

 open(my $f, $_[0]{_argv}[0]);
 local $/;
 my $file = <$f>;

 Global->set('cgi') = HUtils::Conf(PathSearch->go('cgi'));
 LinkedSpec::run_plugin('set_http_localhost');
 my $fo = LinkedSpec::run_plugin('file_list_path2http', $file);

 print "var_subst_test: ($fo)\n";
 return
}

1;
