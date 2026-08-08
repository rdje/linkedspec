//! Immutable source identities, Unicode-scalar positions, and source spans.
//!
//! The source authority owns caller-supplied decoded text. Values retain only
//! an opaque authority identity, source identity, scalar offsets, and explicit
//! provenance. They never carry copied source text or parser/runtime state.

use serde_json::{Map, Value, json};
use std::collections::BTreeMap;
use std::fmt;
use std::sync::atomic::{AtomicU64, Ordering};

const VALIDATE_VALUE_PHASE: &str = "validate_value";
const SOURCE_MISMATCH_CODE: &str = "source_location_source_mismatch";
const POSITION_OUT_OF_RANGE_CODE: &str = "source_location_position_out_of_range";
const REVERSED_SPAN_CODE: &str = "source_location_reversed_span";
const INVALID_DERIVED_PROVENANCE_CODE: &str = "source_location_invalid_derived_provenance";

static NEXT_AUTHORITY_ID: AtomicU64 = AtomicU64::new(1);

/// Rule and invocation roles attached to private source-location diagnostics.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SourceLocationContext {
    rule_role: Box<str>,
    invocation_role: Box<str>,
}

impl SourceLocationContext {
    /// Construct diagnostic context without retaining parser/runtime objects.
    pub fn new(rule_role: impl Into<Box<str>>, invocation_role: impl Into<Box<str>>) -> Self {
        Self {
            rule_role: rule_role.into(),
            invocation_role: invocation_role.into(),
        }
    }
}

/// One supported derived-text materialization policy.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DerivedTextPolicy {
    /// Concatenate direct spans in their supplied order.
    ConcatenateInOrder,
}

impl DerivedTextPolicy {
    const fn as_str(self) -> &'static str {
        match self {
            Self::ConcatenateInOrder => "concatenate_in_order",
        }
    }
}

/// Immutable source identity plus zero-based Unicode-scalar offset.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Position {
    authority_id: u64,
    source_id: Box<str>,
    offset: u64,
}

impl Position {
    /// Return the zero-based Unicode-scalar offset.
    pub fn offset(&self) -> u64 {
        self.offset
    }

    /// Return a detached neutral record.
    pub fn as_record(&self) -> Value {
        json!({
            "source_id": self.source_id.as_ref(),
            "offset": self.offset,
        })
    }
}

/// Immutable same-source half-open interval plus provenance label.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Span {
    authority_id: u64,
    source_id: Box<str>,
    start: u64,
    end: u64,
    provenance: Box<str>,
}

impl Span {
    /// Return the zero-based Unicode-scalar start offset.
    pub fn start(&self) -> u64 {
        self.start
    }

    /// Return the zero-based Unicode-scalar end offset.
    pub fn end(&self) -> u64 {
        self.end
    }

    /// Return the Unicode-scalar width of this validated span.
    pub fn scalar_len(&self) -> u64 {
        self.end - self.start
    }

    /// Report whether this validated span is empty.
    pub fn is_empty(&self) -> bool {
        self.start == self.end
    }

    /// Return a detached neutral record.
    pub fn as_record(&self) -> Value {
        span_record(self)
    }
}

/// Immutable ordered provenance sequence for explicitly derived text.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DerivedText {
    authority_id: u64,
    policy: DerivedTextPolicy,
    spans: Box<[Span]>,
}

impl DerivedText {
    /// Return a detached neutral record.
    pub fn as_record(&self) -> Value {
        json!({
            "policy": self.policy.as_str(),
            "spans": self.spans.iter().map(span_record).collect::<Vec<_>>(),
        })
    }
}

/// Detached derived coordinate evidence for one position.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SourceCoordinates {
    source_id: Box<str>,
    offset: u64,
    line: u64,
    column: u64,
    utf8_byte_offset: u64,
}

impl SourceCoordinates {
    /// Return the one-based line number.
    pub fn line(&self) -> u64 {
        self.line
    }

    /// Return the one-based column number.
    pub fn column(&self) -> u64 {
        self.column
    }

    /// Return a detached neutral record.
    pub fn as_record(&self) -> Value {
        json!({
            "source_id": self.source_id.as_ref(),
            "offset": self.offset,
            "line": self.line,
            "column": self.column,
            "utf8_byte_offset": self.utf8_byte_offset,
        })
    }
}

/// One of the four private immutable-value contract failures.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SourceLocationError {
    record: Value,
}

impl SourceLocationError {
    fn new(
        code: &'static str,
        context: &SourceLocationContext,
        fields: impl IntoIterator<Item = (&'static str, Value)>,
    ) -> Self {
        let mut record = Map::new();
        record.insert("code".to_owned(), Value::String(code.to_owned()));
        record.insert(
            "phase".to_owned(),
            Value::String(VALIDATE_VALUE_PHASE.to_owned()),
        );
        record.insert(
            "rule_role".to_owned(),
            Value::String(context.rule_role.to_string()),
        );
        record.insert(
            "invocation_role".to_owned(),
            Value::String(context.invocation_role.to_string()),
        );
        for (name, value) in fields {
            record.insert(name.to_owned(), value);
        }
        Self {
            record: Value::Object(record),
        }
    }

    /// Return a detached machine-readable error record.
    pub fn as_record(&self) -> Value {
        self.record.clone()
    }
}

impl fmt::Display for SourceLocationError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        let code = self.record["code"]
            .as_str()
            .unwrap_or("source_location_error");
        write!(formatter, "{code}")
    }
}

impl std::error::Error for SourceLocationError {}

struct DecodedSource {
    text: Box<str>,
    line_at_offset: Box<[u64]>,
    column_at_offset: Box<[u64]>,
    byte_at_offset: Box<[u64]>,
}

impl DecodedSource {
    fn new(text: &str) -> Self {
        let mut line_at_offset = Vec::with_capacity(text.chars().count() + 1);
        let mut column_at_offset = Vec::with_capacity(text.chars().count() + 1);
        let mut byte_at_offset = Vec::with_capacity(text.chars().count() + 1);
        let (mut line, mut column) = (1_u64, 1_u64);

        line_at_offset.push(line);
        column_at_offset.push(column);
        byte_at_offset.push(0);
        for (byte_offset, character) in text.char_indices() {
            if character == '\n' {
                line += 1;
                column = 1;
            } else {
                column += 1;
            }
            line_at_offset.push(line);
            column_at_offset.push(column);
            byte_at_offset.push(
                u64::try_from(byte_offset + character.len_utf8())
                    .expect("decoded source byte length must fit u64"),
            );
        }

        Self {
            text: text.to_owned().into_boxed_str(),
            line_at_offset: line_at_offset.into_boxed_slice(),
            column_at_offset: column_at_offset.into_boxed_slice(),
            byte_at_offset: byte_at_offset.into_boxed_slice(),
        }
    }

    fn scalar_length(&self) -> u64 {
        u64::try_from(self.byte_at_offset.len() - 1)
            .expect("decoded source scalar length must fit u64")
    }

    fn boundary_index(&self, offset: u64) -> Option<usize> {
        let index = usize::try_from(offset).ok()?;
        (index < self.byte_at_offset.len()).then_some(index)
    }

    fn scalar_offset_at_utf8_byte(&self, byte_offset: u64) -> Option<u64> {
        let index = self.byte_at_offset.binary_search(&byte_offset).ok()?;
        u64::try_from(index).ok()
    }

    fn slice(&self, start: u64, end: u64) -> Option<&str> {
        let start_index = self.boundary_index(start)?;
        let end_index = self.boundary_index(end)?;
        self.text.get(
            usize::try_from(self.byte_at_offset[start_index]).ok()?
                ..usize::try_from(self.byte_at_offset[end_index]).ok()?,
        )
    }
}

/// Authority that owns immutable decoded-source snapshots and validates values.
pub struct SourceAuthority {
    authority_id: u64,
    sources: BTreeMap<Box<str>, DecodedSource>,
}

impl SourceAuthority {
    /// Snapshot all supplied decoded sources into a new, independent authority.
    pub fn new(sources: &BTreeMap<String, String>) -> Self {
        let authority_id = NEXT_AUTHORITY_ID
            .fetch_update(Ordering::Relaxed, Ordering::Relaxed, |current| {
                current.checked_add(1)
            })
            .expect("source authority identity space exhausted");
        let sources = sources
            .iter()
            .map(|(source_id, text)| (source_id.clone().into_boxed_str(), DecodedSource::new(text)))
            .collect();
        Self {
            authority_id,
            sources,
        }
    }

    /// Construct and validate one scalar-offset position.
    pub fn position(
        &self,
        source_id: &str,
        offset: u64,
        context: &SourceLocationContext,
    ) -> Result<Position, SourceLocationError> {
        let source = self.sources.get(source_id);
        let source_length = source.map_or(0, DecodedSource::scalar_length);
        if source
            .and_then(|entry| entry.boundary_index(offset))
            .is_none()
        {
            return Err(SourceLocationError::new(
                POSITION_OUT_OF_RANGE_CODE,
                context,
                [
                    ("source_id", json!(source_id)),
                    ("position_offset", json!(offset)),
                    ("source_length", json!(source_length)),
                ],
            ));
        }
        Ok(Position {
            authority_id: self.authority_id,
            source_id: source_id.to_owned().into_boxed_str(),
            offset,
        })
    }

    pub(crate) fn position_from_utf8_byte(
        &self,
        source_id: &str,
        byte_offset: u64,
        context: &SourceLocationContext,
    ) -> Result<Position, SourceLocationError> {
        let source = self.sources.get(source_id);
        let scalar_offset = source.and_then(|entry| entry.scalar_offset_at_utf8_byte(byte_offset));
        let Some(scalar_offset) = scalar_offset else {
            return Err(SourceLocationError::new(
                POSITION_OUT_OF_RANGE_CODE,
                context,
                [
                    ("source_id", json!(source_id)),
                    ("position_offset", json!(byte_offset)),
                    (
                        "source_length",
                        json!(source.map_or(0, DecodedSource::scalar_length)),
                    ),
                ],
            ));
        };
        self.position(source_id, scalar_offset, context)
    }

    pub(crate) fn source_scalar_length(&self, source_id: &str) -> Option<u64> {
        self.sources
            .get(source_id)
            .map(DecodedSource::scalar_length)
    }

    /// Construct and validate one direct half-open span.
    pub fn direct_span(
        &self,
        start: &Position,
        end: &Position,
        provenance: &str,
        context: &SourceLocationContext,
    ) -> Result<Span, SourceLocationError> {
        if start.source_id != end.source_id
            || start.authority_id != end.authority_id
            || start.authority_id != self.authority_id
        {
            return Err(SourceLocationError::new(
                SOURCE_MISMATCH_CODE,
                context,
                [
                    ("source_id", json!(start.source_id.as_ref())),
                    ("other_source_id", json!(end.source_id.as_ref())),
                ],
            ));
        }
        if start.offset > end.offset {
            return Err(SourceLocationError::new(
                REVERSED_SPAN_CODE,
                context,
                [
                    ("source_id", json!(start.source_id.as_ref())),
                    ("start_offset", json!(start.offset)),
                    ("end_offset", json!(end.offset)),
                ],
            ));
        }
        Ok(Span {
            authority_id: self.authority_id,
            source_id: start.source_id.clone(),
            start: start.offset,
            end: end.offset,
            provenance: provenance.to_owned().into_boxed_str(),
        })
    }

    /// Construct and validate an explicit ordered derived-text value.
    pub fn derived_text(
        &self,
        policy: DerivedTextPolicy,
        spans: &[Span],
        context: &SourceLocationContext,
    ) -> Result<DerivedText, SourceLocationError> {
        for (index, span) in spans.iter().enumerate() {
            if span.authority_id != self.authority_id || !self.sources.contains_key(&span.source_id)
            {
                return Err(SourceLocationError::new(
                    INVALID_DERIVED_PROVENANCE_CODE,
                    context,
                    [
                        ("provenance_index", json!(index)),
                        ("source_id", json!(span.source_id.as_ref())),
                    ],
                ));
            }
        }
        Ok(DerivedText {
            authority_id: self.authority_id,
            policy,
            spans: spans.to_vec().into_boxed_slice(),
        })
    }

    /// Derive one-based line/column and UTF-8 byte evidence for a position.
    pub fn coordinates(
        &self,
        position: &Position,
        context: &SourceLocationContext,
    ) -> Result<SourceCoordinates, SourceLocationError> {
        let source = self.sources.get(&position.source_id);
        let index = source.and_then(|entry| entry.boundary_index(position.offset));
        if position.authority_id != self.authority_id || index.is_none() {
            return Err(SourceLocationError::new(
                POSITION_OUT_OF_RANGE_CODE,
                context,
                [
                    ("source_id", json!(position.source_id.as_ref())),
                    ("position_offset", json!(position.offset)),
                    (
                        "source_length",
                        json!(source.map_or(0, DecodedSource::scalar_length)),
                    ),
                ],
            ));
        }
        let source = source.expect("validated source must exist");
        let index = index.expect("validated position index must exist");
        Ok(SourceCoordinates {
            source_id: position.source_id.clone(),
            offset: position.offset,
            line: source.line_at_offset[index],
            column: source.column_at_offset[index],
            utf8_byte_offset: source.byte_at_offset[index],
        })
    }

    /// Materialize one direct or explicitly derived value from owned sources.
    pub fn materialize<T: MaterializableSourceValue>(
        &self,
        value: &T,
        context: &SourceLocationContext,
    ) -> Result<String, SourceLocationError> {
        value.materialize_from(self, context)
    }

    fn materialize_span(
        &self,
        span: &Span,
        context: &SourceLocationContext,
        provenance_index: usize,
    ) -> Result<&str, SourceLocationError> {
        let source = self.sources.get(&span.source_id);
        let text = source.and_then(|entry| entry.slice(span.start, span.end));
        if span.authority_id != self.authority_id || text.is_none() {
            return Err(SourceLocationError::new(
                INVALID_DERIVED_PROVENANCE_CODE,
                context,
                [
                    ("provenance_index", json!(provenance_index)),
                    ("source_id", json!(span.source_id.as_ref())),
                ],
            ));
        }
        Ok(text.expect("validated span text must exist"))
    }
}

mod sealed {
    pub trait Sealed {}
}

/// Sealed runtime-support trait accepted by [`SourceAuthority::materialize`].
pub trait MaterializableSourceValue: sealed::Sealed {
    #[doc(hidden)]
    fn materialize_from(
        &self,
        authority: &SourceAuthority,
        context: &SourceLocationContext,
    ) -> Result<String, SourceLocationError>;
}

impl sealed::Sealed for Span {}

impl MaterializableSourceValue for Span {
    fn materialize_from(
        &self,
        authority: &SourceAuthority,
        context: &SourceLocationContext,
    ) -> Result<String, SourceLocationError> {
        authority
            .materialize_span(self, context, 0)
            .map(str::to_owned)
    }
}

impl sealed::Sealed for DerivedText {}

impl MaterializableSourceValue for DerivedText {
    fn materialize_from(
        &self,
        authority: &SourceAuthority,
        context: &SourceLocationContext,
    ) -> Result<String, SourceLocationError> {
        if self.authority_id != authority.authority_id {
            let source_id = self
                .spans
                .first()
                .map_or("", |span| span.source_id.as_ref());
            return Err(SourceLocationError::new(
                INVALID_DERIVED_PROVENANCE_CODE,
                context,
                [
                    ("provenance_index", json!(0)),
                    ("source_id", json!(source_id)),
                ],
            ));
        }
        let mut text = String::new();
        for (index, span) in self.spans.iter().enumerate() {
            text.push_str(authority.materialize_span(span, context, index)?);
        }
        Ok(text)
    }
}

fn span_record(span: &Span) -> Value {
    json!({
        "source_id": span.source_id.as_ref(),
        "start": span.start,
        "end": span.end,
        "provenance": span.provenance.as_ref(),
    })
}
