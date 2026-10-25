//! Numeric transport must preserve the value, not a saturated host integer.
use linkedspec_core::types::RuntimeValue;
use serde_json::{Value, json};

#[test]
fn finite_values_survive_json_text_length_display_and_numeric_serde() {
    let fixture: Value =
        serde_json::from_str(include_str!("../../../tests/numeric-conversion/cases.json"))
            .expect("authored numeric cases");
    let mut failures = Vec::new();
    for case in fixture["cases"].as_array().expect("case array") {
        let name = case["id"].as_str().expect("case id");
        let encoded_bits = case["bits"].as_str().expect("authored bits");
        let bits = u64::from_str_radix(encoded_bits, 16).expect("binary64 bits");
        let number = f64::from_bits(bits);
        let value = RuntimeValue::Number(number);
        let projected = value.to_json();
        let text = value.to_str();
        let display = value.to_string();
        let length = value.len();
        let raw_serde = serde_json::to_string(&value).expect("numeric serde output");
        let recovered = serde_json::from_str::<RuntimeValue>(&raw_serde);
        let recovered_bits = recovered
            .as_ref()
            .ok()
            .and_then(RuntimeValue::as_number)
            .map(|number| format!("{:016x}", number.to_bits()));
        let observed = json!({
            "id": name,
            "bits": encoded_bits,
            "native_json": serde_json::Number::from_f64(number).map(Value::Number),
            "projected": projected,
            "projected_raw": projected.to_string(),
            "text": text,
            "length": length,
            "display": display,
            "raw_serde": raw_serde,
            "recovered_bits": recovered_bits,
            "serde_error": recovered.as_ref().err().map(ToString::to_string),
            "scalar_text_control": value.to_scalar_text(),
        });
        println!("NUMERIC_CORE\t{observed}");

        let mut check = |condition: bool, field: &str| {
            if !condition {
                failures.push(format!("{name}:{field}"));
            }
        };
        match case["json_kind"].as_str().expect("JSON target class") {
            "null" => check(projected.is_null(), "nonfinite_null"),
            "negative_zero" => check(
                projected.is_f64() && projected.as_f64().map(f64::to_bits) == Some(bits),
                "signed_zero_json",
            ),
            "signed_integer" | "unsigned_integer" => check(
                !projected.is_f64() && projected.to_string() == case["integer"].as_str().unwrap(),
                "exact_integer_json",
            ),
            "finite_float" => check(
                projected.is_f64() && projected.as_f64().map(f64::to_bits) == Some(bits),
                "finite_float_json",
            ),
            _ => panic!("unknown authored numeric target"),
        }
        if let Some(expected) = case["expected_text"].as_str() {
            check(text == expected, "text");
            check(display == expected, "display");
            check(length == expected.len(), "length");
        } else {
            // Wider/fractional values keep the existing Rust decimal formatter.
            // Check value and consistency without choosing portable spelling.
            check(
                text.parse::<f64>().map(f64::to_bits).ok() == Some(bits),
                "floating_text_value",
            );
            check(display == text, "floating_display");
            check(length == text.len(), "floating_length");
        }
        if number.is_finite() {
            check(
                recovered_bits.as_deref() == Some(encoded_bits),
                "numeric_serde_roundtrip",
            );
        } else {
            check(
                matches!(recovered, Ok(RuntimeValue::Undef)),
                "nonfinite_serde_null",
            );
        }
    }
    assert!(
        failures.is_empty(),
        "numeric conversion mismatches: {failures:?}"
    );
}
