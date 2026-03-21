package LinkedSpec::RuntimeContext;

use 5.010;

sub clear_runtime_ctx_last_error {
 my ($runtime_ctx) = @_;
 return unless ref($runtime_ctx) eq 'HASH';
 delete $runtime_ctx->{last_error};
 return
}

sub set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 my $type = defined($args{type}) ? $args{type} : 'runtime_owner';
 my $stage = defined($args{stage}) ? $args{stage} : '';
 my $error = {
  type    => $type,
  stage   => $stage,
  owner_stage => length($stage) ? "$type:$stage" : $type,
  summary => defined($args{summary}) ? $args{summary} : '',
  detail  => defined($args{detail}) ? $args{detail} : '',
  spec_name => defined($runtime_ctx->{spec_name}) ? $runtime_ctx->{spec_name} : '',
  spec_path => defined($runtime_ctx->{spec_path}) ? $runtime_ctx->{spec_path} : '',
 };
 $error->{rule_label} = $args{rule_label} if defined $args{rule_label};
 $error->{handler_variant} = $args{handler_variant} if defined $args{handler_variant};
 $runtime_ctx->{last_error} = $error;
 return $error
}

1;
