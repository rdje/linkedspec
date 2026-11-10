use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use IO::Compress::Gzip qw(gzip $GzipError);
use Digest::SHA qw(sha256_hex);
use LinkedSpec ();
my $json=JSON::PP->new->canonical->ascii->allow_nonref;
use Test::More;
my $output = $ENV{LINKEDSPEC_ARRAY_PIPELINE_SOURCE_CAPTURE};
die 'unsafe source capture' if defined($output) &&
 ($output !~ m{\Adocs/checkpoints/array-pipeline-source-perl-2026-11-10/[a-z_]+\z} || !-d $output || -l $output);
sub plain_error_value {
 my ($value)=@_;
 return $value unless ref($value);
 return $value if JSON::PP::is_bool($value);
 my $kind=reftype($value)//'';
 return [map {plain_error_value($_)} @$value] if $kind eq 'ARRAY';
 if ($kind eq 'HASH') {
  my %copy=map {$_=>plain_error_value($value->{$_})} keys %$value;
  $copy{class}=ref($value) if ref($value) ne 'HASH';
  return \%copy;
 }
 return "$value";
}
sub error_value {
 my ($error)=@_;
 return undef unless defined($error) && (ref($error) || length($error));
 return plain_error_value($error);
}
sub persist {
 my ($id,$suffix,$body)=@_;
 return undef unless defined $body;
 return undef unless defined $output;
 my $path="$output/$id.$suffix.gz";die 'one shot artifact already exists' if -e $path;
 gzip \$body => $path or die $GzipError;
 return {path=>$path,sha256=>sha256_hex($body),bytes=>length($body)};
}
sub observe {
 my ($case)=@_;
 my $id=$case->{id};die 'unsafe authored id' unless $id =~ /\A[a-z][a-z0-9_]*\z/;
 my $source=$case->{source};my (%row,%ctx,@warnings,$handler);
 local $SIG{__WARN__}=sub{push @warnings,@_};
 $row{substitution}=eval{LinkedSpec::call_spec_handler_subst($case->{rule},$case->{body})};
 $row{substitution_error}=error_value($@);
 my $descriptor=eval{LinkedSpec::Get(\$source,return_descriptor=>1)};
 $row{descriptor_error}=error_value($@);
 my $meta=$descriptor->{spec}{$case->{rule}}{meta}{action_rewriter}//{};
 $row{metadata}={map {$_=>$meta->{$_}} qw(language_agnostic_action_ir_ready raw_perl_dependency_count canonical_action_ir_fallback_count unresolved_helper_count unresolved_helpers)};
 my $emitted=eval{LinkedSpec::emit_generated_source(\$source,source_identity=>'array-pipeline-selection.spec')};
 $row{emission_error}=error_value($@);$row{module_input}=persist($id,'pm',$emitted);
 my $native=eval{LinkedSpec::Get(\$source,dump_parser_source=>1,parser_source_ref=>\$handler,runtime_ctx_ref=>\%ctx)};
 $row{build_error}=error_value($@);$row{native_callable}=ref($native) eq 'CODE'?1:0;
 $row{handler_input}=persist($id,'handler.pl',$handler);
 print STDERR 'ARRAY_PIPELINE_SOURCE_INPUT '.$id.' '.$json->encode({source=>$source,emitted=>$emitted,handler=>$handler}),"\n" if defined $output;
 my $package='LinkedSpec::ArrayPipelineSelectionProbe::'.$id;
 no strict 'refs';
 my $seed=$case->{seed}//'empty';
 local @{'main::3'} = $seed eq 'main' ? ('MAIN','TAIL','END') : ();
 local @{$package.'::3'} = $seed eq 'outer' ? ('OUTER','TAIL','END') : ();
 $row{host_before}={main=>[@{'main::3'}],outer=>[@{$package.'::3'}]};
 $row{build_context_error}=error_value($ctx{last_error}) if exists $ctx{last_error};
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
 $row{host_after}={main=>[@{'main::3'}],outer=>[@{$package.'::3'}]};
 $row{warnings}=\@warnings;
 return \%row;
}

sub normalize_serials {
 my ($value)=@_;
 return $value if JSON::PP::is_bool($value);
 return [map { normalize_serials($_) } @$value] if ref($value) eq 'ARRAY';
 return {map {$_=>normalize_serials($value->{$_})} keys %$value} if ref($value) eq 'HASH';
 return $value if !defined($value) || ref($value);
 $value =~ s/\(eval \d+\)/(eval SERIAL)/g;
 return $value;
}
sub projection {
 my ($row)=@_;
 return normalize_serials({map {$_=>$row->{$_}}
   grep {$_ ne 'substitution' && $_ ne 'module_input' && $_ ne 'handler_input'} keys %$row});
}
open my $file,'<:raw','tests/fixtures/array_pipeline_source_isolation_perl_cases.json' or die $!;
my $profiles=$json->decode(do{local $/;<$file>}); close $file or die $!;
for my $profile (@$profiles) {
 my $case=$profile->{case};
 subtest $case->{id} => sub {
  my $row=observe($case);
  diag('ARRAY_PIPELINE_SOURCE_PERL '.$case->{id}.' '.$json->encode($row));
  is($json->encode(projection($row)), $json->encode(normalize_serials($profile->{expected_observation})),
     $profile->{role} eq 'source-repair' ? 'Number source ignores unrelated host Array' : 'acquired source policy preserved');
 };
}
done_testing();
