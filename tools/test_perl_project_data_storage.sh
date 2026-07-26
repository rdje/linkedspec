#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_perl_project_data_storage.sh" "$@"

fail() {
 printf '[perl-project-data-test] ERROR: %s\n' "$*" >&2
 exit 1
}

device_id() {
 local path=$1
 local device

 if device=$(stat -c '%d' -- "$path" 2>/dev/null); then
  printf '%s\n' "$device"
 elif device=$(stat -f '%d' "$path" 2>/dev/null); then
  printf '%s\n' "$device"
 else
  fail "cannot determine filesystem device for $path"
 fi
}

[[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 ]] || fail 'focused proof is not inside a managed run'
[[ -n "${LINKEDSPEC_RUN_DIR:-}" && -d "$LINKEDSPEC_RUN_DIR" ]] || fail 'managed run directory is missing'
[[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]] || fail 'managed temporary directory is missing'

repo_device=$(device_id "$REPO_ROOT")
[[ "$(device_id "$LINKEDSPEC_RUN_DIR")" == "$repo_device" ]] ||
 fail 'managed run is not on the repository filesystem'
[[ "$(device_id "$TMPDIR")" == "$repo_device" ]] ||
 fail 'Perl temporary root is not on the repository filesystem'
case "$(cd -P -- "$TMPDIR" && pwd -P)/" in
 "$LINKEDSPEC_RUN_DIR/tmp/") ;;
 *) fail 'Perl temporary root is not the active managed-run tmp directory' ;;
esac

perl -MFile::Path=remove_tree -MFile::Spec -MFile::Temp=tempdir,tempfile -e '
 my $tmp = $ENV{TMPDIR} // die "TMPDIR is missing\n";
 my $repo = $ENV{LINKEDSPEC_REPO_ROOT} // die "LINKEDSPEC_REPO_ROOT is missing\n";
 my $repo_device = (stat($repo))[0];
 my $default_dir = tempdir(CLEANUP => 0);
 my $named_dir = tempdir("linkedspec-perl-storage-XXXXXX", TMPDIR => 1, CLEANUP => 0);
 my ($default_fh, $default_file) = tempfile(SUFFIX => ".storage", UNLINK => 0);
 my ($named_fh, $named_file) = tempfile(
  "linkedspec-perl-storage-XXXXXX", TMPDIR => 1, SUFFIX => ".storage", UNLINK => 0,
 );
 close($default_fh) or die "cannot close default tempfile: $!\n";
 close($named_fh) or die "cannot close named tempfile: $!\n";
 for my $path ($default_dir, $named_dir, $default_file, $named_file) {
  my $absolute = File::Spec->rel2abs($path);
  index($absolute, "$tmp/") == 0
   or die "File::Temp escaped the managed tmp root: $absolute\n";
  (stat($absolute))[0] == $repo_device
   or die "File::Temp crossed the repository filesystem: $absolute\n";
 }
 unlink($default_file) or die "cannot remove default tempfile: $!\n";
 unlink($named_file) or die "cannot remove named tempfile: $!\n";
 remove_tree($default_dir, $named_dir, {error => \my $errors});
 die "cannot remove File::Temp probe directories\n" if @$errors;
 print "[perl-project-data-test] File::Temp allocation stays in managed SSD scratch\n";
' || fail 'File::Temp allocation proof failed'

perl -I"$REPO_ROOT/perl" -MFile::Spec -MLinkedSpec::Trace -e '
 my $path = File::Spec->catfile($ENV{TMPDIR}, "perl-project-data-trace.log");
 my $repo_device = (stat($ENV{LINKEDSPEC_REPO_ROOT}))[0];
 LinkedSpec::Trace::configure_trace(
  trace_level => "low",
  trace_log_file => $path,
  trace_log_mode => "route",
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );
 LinkedSpec::Trace::trace_decision("project_data:perl:ssd_local", 1, "focused proof", "low");
 LinkedSpec::Trace::configure_trace(
  trace_level => "none", trace_log_file => "", trace_log_mode => "stdout",
 );
 -f $path or die "trace file was not created\n";
 (stat($path))[0] == $repo_device or die "trace file crossed the repository filesystem\n";
 open(my $fh, "<:raw", $path) or die "cannot read trace file: $!\n";
 local $/;
 my $trace = <$fh> // "";
 close($fh) or die "cannot close trace file: $!\n";
 $trace =~ /project_data:perl/ or die "trace file lacks the focused event\n";
 unlink($path) or die "cannot remove trace file: $!\n";
 print "[perl-project-data-test] explicit trace output stays in managed SSD scratch\n";
' || fail 'explicit trace-file proof failed'

manifest_path="$LINKEDSPEC_RUN_DIR/perl-project-data-cli-manifest.json"
perl -MJSON::PP -e '
 my $path = shift @ARGV;
 my $manifest = {
  schema_version => 1,
  suite => "perl-project-data-storage",
  cases => [{
   id => "project_data_workspace",
   family => "storage",
   args => ["{{WORKSPACE}}"],
   files => [],
   expect => {
    exit => 0,
    stdout => {text => "ssd-local\n"},
    stderr => {text => ""},
    files => [{
     path => "storage.trace",
     content => {text => "ssd-local trace\n"},
    }],
   },
  }],
 };
 open(my $fh, ">:raw", $path) or die "cannot create focused manifest: $!\n";
 print {$fh} JSON::PP->new->canonical(1)->pretty(1)->encode($manifest);
 close($fh) or die "cannot close focused manifest: $!\n";
' "$manifest_path" || fail 'cannot create focused CLI manifest'

PERL5LIB= perl "$REPO_ROOT/tools/run_cli_conformance.pl" \
 --manifest "$manifest_path" \
 --display-command 'Perl storage child' \
 -- perl -MCwd=getcwd -MFile::Spec -e '
  my $expected = shift @ARGV;
  my $cwd = getcwd();
  my $run = $ENV{LINKEDSPEC_RUN_DIR} // "";
  my $prefix = File::Spec->catdir($run, "tmp")."/linkedspec-cli-";
  exit 71 unless $cwd eq $expected;
  exit 72 unless length($run) && index($cwd, $prefix) == 0;
  exit 73 unless (stat($cwd))[0] == (stat($ENV{LINKEDSPEC_REPO_ROOT}))[0];
  open(my $fh, ">:raw", "storage.trace") or exit 74;
  print {$fh} "ssd-local trace\n";
  close($fh) or exit 75;
  print "ssd-local\n";
 ' || fail 'CLI subprocess-workspace proof failed'

shopt -s nullglob
cli_residue=("$TMPDIR"/linkedspec-cli-project_data_workspace-*)
shopt -u nullglob
(( ${#cli_residue[@]} == 0 )) || fail 'CLI runner retained a completed focused workspace'

mapfile -t perl_temp_owners < <(
 while IFS= read -r relative; do
  if rg -q 'File::Temp|tempdir\(|tempfile\(' "$REPO_ROOT/$relative"; then
   printf '%s\n' "$relative"
  fi
 done < <(git -C "$REPO_ROOT" ls-files 't/*.t' 't/**/*.pm' 'tools/*.pl' 'perl/**/*.pm')
)
(( ${#perl_temp_owners[@]} == 24 )) ||
 fail "tracked Perl temporary-allocation inventory drifted from 24 to ${#perl_temp_owners[@]}"
printf '%s\n' "${perl_temp_owners[@]}" | rg -qx 'tools/run_cli_conformance\.pl' ||
 fail 'CLI workspace owner is absent from the Perl allocation inventory'
printf '%s\n' "${perl_temp_owners[@]}" | rg -qx 'tools/gen_oracle_corpus\.pl' ||
 fail 'oracle subprocess owner is absent from the Perl allocation inventory'
rg -q 'TMPDIR[[:space:]]*=>[[:space:]]*1' "$REPO_ROOT/tools/run_cli_conformance.pl" ||
 fail 'CLI workspace no longer selects the initialized temporary root'
[[ "$(rg -c 'TMPDIR[[:space:]]*=>[[:space:]]*1' "$REPO_ROOT/tools/gen_oracle_corpus.pl")" == 2 ]] ||
 fail 'oracle stdout/stderr capture no longer selects the initialized temporary root twice'

rg -q "logical_name.*'/tmp/private\.spec'" "$REPO_ROOT/t/semantic_index_perl_static_projection.t" ||
 fail 'inert private-path projection fixture was unexpectedly rewritten'
rg -q "logical_name.*'/tmp/leak\.spec'" "$REPO_ROOT/t/semantic_index_perl_foundation.t" ||
 fail 'inert private-path leak fixture was unexpectedly rewritten'

printf '%s\n' \
 '[perl-project-data-test] PASS: 24 Perl allocators, traces, and CLI workspaces stay on repository storage'
