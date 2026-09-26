//! Public Rust entrypoints mirror the reference parser's leading-trivia boundary.

use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn leading_trivia_preserves_absolute_positions_and_content_across_carriers() {
    let source = "Top:: I { return(cursor_pos()) }\n";
    let compiled = compile(&parse_spec_with_user_functions(source).unwrap()).unwrap();
    let encoded = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&encoded).unwrap();
    let plan = [GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    // Only complete LF blank lines and leading # comment lines are trivia.
    // Ordinary horizontal space, CRLF blank lines and Unicode whitespace stay input.
    let cases = [
        ("", ""),
        ("word", ""),
        (" \tword", ""),
        (" \t", ""),
        ("\nword", "\n"),
        (" \t\nword", " \t\n"),
        ("# comment\nword", "# comment\n"),
        (" \t# 雪🦀\n\nword", " \t# 雪🦀\n\n"),
        ("# comment at EOF", "# comment at EOF"),
        ("\n# 雪 at EOF", "\n# 雪 at EOF"),
        ("\r\nword", ""),
        ("\u{a0}\nword", ""),
        ("word\n# later", ""),
        ("\n  word", "\n"),
    ];
    for carrier in [compiled, restored] {
        let engine = Engine::new(carrier);
        for (input, skipped) in cases {
            let expected = json!(skipped.chars().count());
            assert_eq!(
                engine
                    .execute_value(input, &ExecutionOptions::new())
                    .unwrap(),
                expected,
                "native/reconstructed {input:?}"
            );
            assert_eq!(engine.execute(input).unwrap(), json!([expected]));
            assert_eq!(
                execute_generated_parser(&encoded, &plan, input).unwrap(),
                json!([expected]),
                "generated compatibility {input:?}"
            );
            assert_eq!(
                execute_generated_parser_v2(
                    &encoded,
                    &plan,
                    input,
                    "leading-input.spec",
                    GENERATED_SOURCE_CONTRACT,
                )
                .unwrap(),
                expected,
                "generated {input:?}"
            );
        }
    }
}

#[test]
fn child_entry_does_not_skip_trivia_again() {
    let source =
        "Top::\n -> Word { return(call(Child)) }\nWord: /x/\nChild: I { return(cursor_pos()) }\n";
    let compiled = compile(&parse_spec_with_user_functions(source).unwrap()).unwrap();
    let encoded = serde_json::to_string(&compiled).unwrap();
    let plan = ["Top", "Word", "Child"].map(|label| GeneratedPlanRow {
        label,
        family: "default",
    });
    assert_eq!(
        Engine::new(compiled)
            .execute_value("x\n\nword", &ExecutionOptions::new())
            .unwrap(),
        json!(1)
    );
    assert_eq!(
        execute_generated_parser_v2(
            &encoded,
            &plan,
            "x\n\nword",
            "child-entry.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .unwrap(),
        json!(1)
    );
}

#[test]
fn leading_trivia_does_not_remove_source() {
    let source = "Top:: I { return(input_slice(0, 3)) }\n";
    let compiled = compile(&parse_spec_with_user_functions(source).unwrap()).unwrap();
    assert_eq!(
        Engine::new(compiled)
            .execute_value("\n#雪\nword", &ExecutionOptions::new())
            .unwrap(),
        json!("\n#雪")
    );
}
