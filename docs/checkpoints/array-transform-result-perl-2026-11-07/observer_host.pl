use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use IO::Compress::Gzip qw(gzip $GzipError);
use Digest::SHA qw(sha256_hex);
use LinkedSpec ();
my $json=JSON::PP->new->canonical->ascii->allow_nonref;
my ($fixture,$output)=@ARGV;
die 'one fixture and owned output path required' unless @ARGV == 2;
die 'unsafe fixture path' unless $fixture eq 'docs/checkpoints/array-transform-result-perl-2026-11-07/host_cases.json';
die 'unsafe output path' unless $output =~ m{\Adocs/checkpoints/array-transform-result-perl-2026-11-07/[a-z_]+\z} && -d $output && !-l $output;

open my $fh,'<:raw',$fixture or die $!;
my $cases=$json->decode(do{local $/;<$fh>});close $fh or die $!;
sub error_value {
 my ($error)=@_;
 return undef unless defined($error) && (ref($error) || length($error));
 if ((reftype($error)//'') eq 'HASH') {
  my %value=map {$_=>ref($error->{$_}) ? error_value($error->{$_}) : $error->{$_}}
   grep {exists $error->{$_}} qw(type code stage detail summary helper_name name phase rule_label actual_arity expected_arity arguments_evaluated);
  $value{class}=ref($error) if ref($error) ne 'HASH';return \%value;
 }
 return "$error";
}
sub persist {
 my ($id,$suffix,$body)=@_;
 return undef unless defined $body;
 my $path="$output/$id.$suffix.gz";die 'one shot artifact already exists' if -e $path;
 gzip \$body => $path or die $GzipError;
 return {path=>$path,sha256=>sha256_hex($body),bytes=>length($body)};
}
for my $case (@$cases) {
 my $id=$case->{id};die 'unsafe authored id' unless $id =~ /\A[a-z][a-z0-9_]*\z/;
 my $source=$case->{source};my (%row,%ctx,@warnings,$handler);
 local $SIG{__WARN__}=sub{push @warnings,@_};
 $row{substitution}=eval{LinkedSpec::call_spec_handler_subst($case->{rule},$case->{body})};
 $row{substitution_error}=error_value($@);
 my $descriptor=eval{LinkedSpec::Get(\$source,return_descriptor=>1)};
 $row{descriptor_error}=error_value($@);
 my $meta=$descriptor->{spec}{$case->{rule}}{meta}{action_rewriter}//{};
 $row{metadata}={map {$_=>$meta->{$_}} qw(language_agnostic_action_ir_ready raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count unresolved_helpers)};
 my $emitted=eval{LinkedSpec::emit_generated_source(\$source,source_identity=>'array-transform-selection.spec')};
 $row{emission_error}=error_value($@);$row{module_input}=persist($id,'pm',$emitted);
 my $native=eval{LinkedSpec::Get(\$source,dump_parser_source=>1,parser_source_ref=>\$handler,runtime_ctx_ref=>\%ctx)};
 $row{build_error}=error_value($@);$row{native_callable}=ref($native) eq 'CODE'?1:0;
 $row{handler_input}=persist($id,'handler.pl',$handler);
 print 'ARRAY_TRANSFORM_INPUT '.$id.' '.$json->encode({source=>$source,emitted=>$emitted,handler=>$handler}),"\n";
 my $package='LinkedSpec::ArrayTransformSelectionProbe::'.$id;
 no strict 'refs';
 local @{'main::3'} = $case->{seed} eq 'main' ? ('MAIN','TAIL','END') : ();
 local @{$package.'::3'} = $case->{seed} eq 'outer' ? ('OUTER','TAIL','END') : ();
 $row{host_before} = {main=>[@{'main::3'}],outer=>[@{$package.'::3'}]};
 if ($row{native_callable}) {
  my $text=$case->{input};$row{native}=eval{$native->(\$text)};
  $row{native_error}=error_value($@ || $ctx{last_error});$row{native_cursor}=pos($text);
 }
 my $loaded=defined($emitted) && eval "package $package; $emitted; 1";
 $row{loaded}=$loaded?1:0;$row{load_error}=error_value($@);
 if ($loaded) {
  my $text=$case->{input};$row{fresh}=eval{$package->can('Execute')->(\$text)};
  $row{fresh_error}=error_value($@);$row{fresh_cursor}=pos($text);
 }
 $row{host_after} = {main=>[@{'main::3'}],outer=>[@{$package.'::3'}]};
 $row{warnings}=\@warnings;
 print 'ARRAY_TRANSFORM_PERL '.$id.' '.$json->encode(\%row),"\n";
}
