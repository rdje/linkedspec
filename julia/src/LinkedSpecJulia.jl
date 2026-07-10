module LinkedSpecJulia

export backend_name,
    backend_status,
    cli_entrypoint,
    corpus_runner_entrypoint,
    CorpusFixture,
    CorpusManifest,
    CorpusManifestException,
    CorpusValidationResult,
    ActionEdgeBodyElementKind,
    BlindEdgeBodyElementKind,
    BodyElement,
    CodeBlockBodyElementKind,
    ConditionalBodyElementKind,
    EdgeTarget,
    FluentCall,
    FluentChainBodyElementKind,
    FunctionDefinition,
    LifecycleMarkerBodyElementKind,
    load_corpus_fixtures,
    parse_spec,
    PlainBlockBodyElementKind,
    RawBodyElementKind,
    RegexBodyElementKind,
    Rule,
    RuleHeader,
    RuleMode,
    SourceSpan,
    SpecAstException,
    SpecParseException,
    SpecFile,
    SplitMarkerBodyElementKind,
    StagedParseJob,
    StagedSourceSpan,
    and_bounded_rule_mode,
    default_rule_mode,
    find_rule,
    from_json,
    is_and,
    is_repetition,
    or_bounded_rule_mode,
    rep_max,
    rep_min,
    run_cli,
    run_corpus_runner,
    top_rule,
    to_json

const BACKEND_NAME = "julia"
const PACKAGE_NAME = "LinkedSpecJulia"
const PACKAGE_VERSION = v"0.1.0"
const CLI_ENTRYPOINT = "julia/bin/linkedspec_julia.jl"
const CORPUS_RUNNER_ENTRYPOINT = "julia/bin/corpus_runner.jl"
const PARITY_STATUS = "source-parser"

include("corpus/CorpusManifest.jl")
include("spec/Ast.jl")
include("spec/Parser.jl")
include("cli/LinkedSpecJuliaCli.jl")

backend_name() = BACKEND_NAME
cli_entrypoint() = CLI_ENTRYPOINT
corpus_runner_entrypoint() = CORPUS_RUNNER_ENTRYPOINT

function backend_status()
    return (;
        backend = BACKEND_NAME,
        package = PACKAGE_NAME,
        version = string(PACKAGE_VERSION),
        parity = PARITY_STATUS,
        cli = CLI_ENTRYPOINT,
        corpus_runner = CORPUS_RUNNER_ENTRYPOINT,
    )
end

end
