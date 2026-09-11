---
id: perl-mcp-validation-error-order-drift
title: "Perl MCP error precedence differs from the documented metadata-first order"
answers:
  - "which error wins when an unknown MCP method lacks required metadata"
  - "does an old MCP protocol version bypass missing clientCapabilities validation"
  - "do Perl MCP decoded and stdio dispatch use the documented validation order"
  - "which task owns competing MCP validation error precedence"
  - "does Rust MCP also check method and version before complete metadata"
  - "does Julia MCP preserve the documented competing metadata error order"
date: 2026-09-07
status: confirmed-open
tags: [perl, rust, julia, mcp, validation, metadata, protocol, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.2.38: six public decoded controls, repeated across decoded and in-memory stdio routes; MCPServer.pm 186–230 and ADR 0055 section 6. Existing three MCP suites pass 31 top-level tests."
reverify: "Run the managed public decoded/stdio probe below and compare the result table with ADR 0055 section 6."
---

# Competing validation errors

ADR 0055 section 6 orders envelope/id, special legacy initialization, required metadata, protocol version,
then method parameters and later dispatch checks. Its section 2 assigns missing/malformed required metadata
to `-32602`. Current Perl `MCPServer::_dispatch` instead rejects unsupported methods before inspecting protocol
metadata, then selects an unsupported protocol error before validating the complete named request schema.

On 2026-09-06, all six cases below produce identical full responses through public decoded `dispatch` and
`serve_stdio`. Requests have valid numeric ids and JSON-RPC 2.0 envelopes. The wire probe uses caller-owned
in-memory handles, returns zero on EOF, and produces exactly six response frames.

| Case | Decoded / stdio error |
| --- | --- |
| Known tools/list, metadata missing | `-32602` |
| Unknown resources/list, metadata missing | `-32601` |
| Known tools/list, old version, clientCapabilities missing | `-32022` |
| Known tools/list, current version, clientCapabilities missing | `-32602` |
| Unknown resources/list, old version, clientCapabilities present | `-32601` |
| Known tools/list, old version, clientCapabilities present | `-32022` |

The controls isolate method/version checks taking precedence over missing metadata. This is a demonstrated
code/decision discrepancy; these Perl results alone do not establish current behavior on other runtimes or justify
rewriting the neutral expected results to match Perl.

The decoded suite's static-dispatch section consumes separate canonical unsupported-version, missing-metadata,
and unknown-method fixtures. Those single-failure cases do not demonstrate their combined precedence. The
combined dispatch/stdio/admission suites pass 31 top-level tests in this checkpoint; no existing suite failure
or runtime repair is claimed.

[[SESSION-STARTUP-READING]] `.36.1` owns authoritative ordering and six-runtime competing-failure census;
`.36.2` owns bounded repair decomposition and independently justified regression evidence; `.36.3` owns public
decision/book/Knowledge and recurring closeout. All follow required reading and policy review. Preserve the
special legacy diagnostic, validated-id and notification rules, cancellation/flush cleanup, and native authority.
This is separate from the already-repaired explicit policy-component boundary in [[mcp-all-twenty-transport-blocker]].

## September 7 Rust source reconciliation

`SESSION-STARTUP-READING.3.3.25` reads `mcp_server.rs` through line 769. Its
`dispatch_with_preparation` likewise selects unknown-method `-32601` before inspecting protocol
metadata, then unsupported-version `-32022` before complete named-request validation. Known
discovery/list/tool calls validate their complete schemas afterward. ADR 0058 section 4 points
back to ADR 0055's required order; it does not independently authorize this precedence.
This is source evidence for the existing `.36.1` census, not a fresh execution of the six
combined Rust cases or other runtimes. Existing single-failure fixtures do not prove mixed-failure
ordering. Preserve the dated Perl observations above until the owned cross-runtime repair runs.

## Reverify

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec::MCPServer -MJSON::PP - <<'PERL'
use strict;use warnings;my $json=JSON::PP->new->canonical;
my @cases=(
 ['known_missing_metadata',{id=>1,jsonrpc=>'2.0',method=>'tools/list',params=>{}}],
 ['unknown_missing_metadata',{id=>2,jsonrpc=>'2.0',method=>'resources/list',params=>{}}],
 ['known_old_version_missing_caps',{id=>3,jsonrpc=>'2.0',method=>'tools/list',params=>{_meta=>{'io.modelcontextprotocol/protocolVersion'=>'2025-11-25'}}}],
 ['known_current_version_missing_caps',{id=>4,jsonrpc=>'2.0',method=>'tools/list',params=>{_meta=>{'io.modelcontextprotocol/protocolVersion'=>'2026-07-28'}}}],
 ['unknown_old_version',{id=>5,jsonrpc=>'2.0',method=>'resources/list',params=>{_meta=>{'io.modelcontextprotocol/protocolVersion'=>'2025-11-25','io.modelcontextprotocol/clientCapabilities'=>{}}}}],
 ['known_old_version',{id=>6,jsonrpc=>'2.0',method=>'tools/list',params=>{_meta=>{'io.modelcontextprotocol/protocolVersion'=>'2025-11-25','io.modelcontextprotocol/clientCapabilities'=>{}}}}]
);
my $s=LinkedSpec::MCPServer->new;my @direct;
for my $case (@cases){push @direct,$s->dispatch($case->[1],authorization_context=>'reading-check')}
$s->shutdown;
my $input=join('',map {$json->encode($_->[1])."\n"} @cases);my $output='';
open my $in,'<',\$input or die $!;open my $out,'>',\$output or die $!;
my $wire=LinkedSpec::MCPServer->new;my $status=$wire->serve_stdio(input=>$in,output=>$out,authorization_context=>'reading-check');die 'wire failure' if $status;
my @wire=map {$json->decode($_)} split /\n/,$output;die 'response count drift' unless @wire==@cases;
for my $i (0..$#cases){die 'decoded/wire drift' unless $json->encode($direct[$i]) eq $json->encode($wire[$i]);print $json->encode({case=>$cases[$i][0],decoded_code=>$direct[$i]{error}{code},stdio_code=>$wire[$i]{error}{code}}),"\n"}
PERL
```

## September 11 Julia executable reconciliation

`JULIA-STARTUP-READING.1.10` reads the complete decoded server. Six equivalent public
controls produce exactly the same error-code sequence as the table above:
`-32602, -32601, -32022, -32602, -32601, -32022`. All six complete responses agree
between decoded dispatch and caller-owned in-memory stdio (12 assertions). The
method/version checks precede complete schema validation at `julia/src/mcp/McpServer.jl:281-300`.
This is fresh Julia evidence for the existing `.36.1` census, not a repair or an
inferred other-runtime result. Pattern matching has a separate Julia `.2.4` owner.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_MCP_ORDER'
using LinkedSpecJulia,JSON3,Test
meta(version;caps=true)=caps ? Dict{String,Any}("io.modelcontextprotocol/protocolVersion"=>version,"io.modelcontextprotocol/clientCapabilities"=>Dict{String,Any}()) : Dict{String,Any}("io.modelcontextprotocol/protocolVersion"=>version)
cases=[("known_missing","tools/list",Dict{String,Any}(),-32602), ("unknown_missing","resources/list",Dict{String,Any}(),-32601), ("old_missing_caps","tools/list",Dict("_meta"=>meta("2025-11-25";caps=false)),-32022), ("current_missing_caps","tools/list",Dict("_meta"=>meta("2026-07-28";caps=false)),-32602), ("unknown_old","resources/list",Dict("_meta"=>meta("2025-11-25")),-32601), ("known_old","tools/list",Dict("_meta"=>meta("2025-11-25")),-32022)]
@testset "Julia mixed-error precedence evidence" begin
 server=McpServer();auth=UInt8[0x61]
 for (id,(name,method,params,expected)) in enumerate(cases)
  request=Dict{String,Any}("id"=>id,"jsonrpc"=>"2.0","method"=>method,"params"=>params)
  response=dispatch_mcp(server,request,auth)
  @test response["error"]["code"]==expected
  out=IOBuffer();wire=McpServer();serve_mcp_stdio!(wire,IOBuffer(JSON3.write(request)*"\n"),out,auth)
  @test JSON3.read(String(take!(out)),Dict{String,Any})==response
  println(JSON3.write(Dict("case"=>name,"error"=>response["error"]["code"])))
 end
 shutdown_mcp!(server)
end
JULIA_MCP_ORDER
```
