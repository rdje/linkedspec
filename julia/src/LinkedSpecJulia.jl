module LinkedSpecJulia

export backend_name,
    backend_status,
    cli_entrypoint,
    corpus_runner_entrypoint,
    ActionAccessSegment,
    ActionArgument,
    ActionArrayLiteralExpr,
    ActionAssignArrayAppendExpr,
    ActionAssignHashIndexExpr,
    ActionAssignNestedAccessExpr,
    ActionAssignScalarExpr,
    ActionBlock,
    ActionBlockValueExpr,
    ActionBooleanLiteralExpr,
    ActionCallExpr,
    ActionContractDiagnostic,
    ActionContractResolution,
    ActionControlCaseExpr,
    ActionControlDefaultExpr,
    ActionControlElseExpr,
    ActionControlIfExpr,
    ActionControlMarkerExpr,
    ActionControlSwitchExpr,
    ActionControlWhileExpr,
    CorpusFixture,
    CorpusManifest,
    CorpusManifestException,
    CorpusValidationResult,
    ActionEdgeBodyElementKind,
    ActionExpr,
    ActionFluentCall,
    ActionFluentChainExpr,
    ActionHashLiteralEntry,
    ActionHashLiteralExpr,
    ActionIndexedVarExpr,
    ActionIndexAccessSegment,
    ActionKeyAccessSegment,
    ActionKeywordArgument,
    ActionNestedAccessExpr,
    ActionNode,
    ActionNumberLiteralExpr,
    ActionPositionalArgument,
    ActionRawExpr,
    ActionRegexLiteralExpr,
    ActionResolvedContract,
    ActionSourceSpan,
    ActionStatement,
    ActionStringLiteralExpr,
    ActionUndefExpr,
    ActionVariableExpr,
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
    parse_spec_with_user_function_definition_asts,
    parse_action_block,
    parse_action_expression,
    parse_action_statement,
    PlainBlockBodyElementKind,
    project_user_function_definition_asts,
    RawBodyElementKind,
    RegexBodyElementKind,
    Rule,
    RuleHeader,
    RuleMode,
    SourceSpan,
    SpecAstException,
    SpecParseException,
    SpecValidationException,
    SpecFile,
    SplitMarkerBodyElementKind,
    StagedParseJob,
    StagedSourceSpan,
    UserFunctionDefinitionException,
    UserFunctionDefinitionProjection,
    and_bounded_rule_mode,
    canonical_action_helper_name,
    canonicalized,
    default_rule_mode,
    definition_nodes_from_user_function_definition_output,
    find_rule,
    from_json,
    is_and,
    is_known_action_ir_call_name,
    is_repetition,
    or_bounded_rule_mode,
    rep_max,
    rep_min,
    resolve_action_block_contracts,
    resolve_action_expression_contracts,
    resolve_action_statement_contracts,
    run_cli,
    run_corpus_runner,
    top_rule,
    to_json,
    validate_spec

const BACKEND_NAME = "julia"
const PACKAGE_NAME = "LinkedSpecJulia"
const PACKAGE_VERSION = v"0.1.0"
const CLI_ENTRYPOINT = "julia/bin/linkedspec_julia.jl"
const CORPUS_RUNNER_ENTRYPOINT = "julia/bin/corpus_runner.jl"
const PARITY_STATUS = "action-contracts"

include("corpus/CorpusManifest.jl")
include("spec/Ast.jl")
include("action/ActionAst.jl")
include("action/ActionParser.jl")
include("action/ActionContracts.jl")
include("spec/Parser.jl")
include("spec/UserFunctionDefinitionShell.jl")
include("spec/Validator.jl")
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
