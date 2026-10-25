//! Checked conversions at binary64 / host-integer boundaries.

/// Convert a finite, whole, nonnegative binary64 value to a host index.
///
/// The first out-of-range value is an exact power of two. In contrast,
/// `usize::MAX as f64` can round up to that value and admit a saturating cast.
/// Negative zero denotes index zero; fractional and nonfinite values reject.
pub fn nonnegative_integer_to_usize(value: f64) -> Option<usize> {
    let upper_exclusive = 2.0_f64.powi(usize::BITS as i32);
    (value.is_finite() && value >= 0.0 && value.fract() == 0.0 && value < upper_exclusive)
        .then(|| value as usize)
}

pub(crate) fn integral_json_number(value: f64) -> Option<serde_json::Number> {
    if !value.is_finite() || value.fract() != 0.0 {
        return None;
    }
    // Use exact exclusive powers of two: integer MAX values round upward in
    // binary64. Every admitted whole value is exactly representable by the
    // selected integer type; values beyond these domains stay floating point.
    const SIGNED_UPPER: f64 = 9_223_372_036_854_775_808.0;
    const UNSIGNED_UPPER: f64 = 18_446_744_073_709_551_616.0;
    if (-SIGNED_UPPER..SIGNED_UPPER).contains(&value) {
        Some(serde_json::Number::from(value as i64))
    } else if (0.0..UNSIGNED_UPPER).contains(&value) {
        Some(serde_json::Number::from(value as u64))
    } else {
        None
    }
}

pub(crate) fn number_text(value: f64) -> String {
    integral_json_number(value)
        .map(|integer| integer.to_string())
        .unwrap_or_else(|| format!("{value}"))
}

#[cfg(test)]
mod tests {
    use super::nonnegative_integer_to_usize;

    #[test]
    fn strict_host_index_conversion_rejects_the_first_unrepresentable_integer() {
        let upper = 2.0_f64.powi(usize::BITS as i32);
        assert_eq!(nonnegative_integer_to_usize(upper), None);
        assert_eq!(
            nonnegative_integer_to_usize(f64::from_bits(upper.to_bits() + 1)),
            None
        );
        let below = f64::from_bits(upper.to_bits() - 1);
        // The adjacent float below 2^32 is fractional, whereas below 2^64 it
        // is a whole integer. The independent checked u128 conversion supplies
        // the expected host result only for an actual whole input.
        let expected = if below.fract() == 0.0 {
            usize::try_from(below as u128).ok()
        } else {
            None
        };
        assert_eq!(nonnegative_integer_to_usize(below), expected);
        for value in [-1.0, 1.5, f64::INFINITY, f64::NEG_INFINITY, f64::NAN] {
            assert_eq!(nonnegative_integer_to_usize(value), None);
        }
        assert_eq!(nonnegative_integer_to_usize(-0.0), Some(0));
        assert_eq!(nonnegative_integer_to_usize(42.0), Some(42));
    }
}
