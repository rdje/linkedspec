//! Shared Rust trace controls, levels, sinks, and event primitives.
//!
//! This module owns the Rust-facing trace control surface because both
//! `linkedspec-core` and `linkedspec-runtime` need the same contract model.
//! Parser/compiler/runtime event coverage is layered on top of these primitives
//! by the trace-observability follow-up slices.

use std::env;
use std::fmt;
use std::fs::{File, OpenOptions};
use std::io::{self, Write};
use std::path::PathBuf;
use std::str::FromStr;

/// No trace output.
pub const DUMP_NONE: i32 = 0;
/// Essential trace output.
pub const DUMP_LOW: i32 = 100;
/// Standard trace output.
pub const DUMP_MEDIUM: i32 = 200;
/// Detailed trace output.
pub const DUMP_HIGH: i32 = 300;
/// Very detailed trace output.
pub const DUMP_FULL: i32 = 400;
/// Maximum trace output.
pub const DUMP_DEBUG: i32 = 500;

/// Ordered trace verbosity threshold.
#[derive(Clone, Copy, Debug, Eq, PartialEq, Ord, PartialOrd, Hash)]
pub struct TraceLevel(i32);

impl TraceLevel {
    pub const NONE: Self = Self(DUMP_NONE);
    pub const LOW: Self = Self(DUMP_LOW);
    pub const MEDIUM: Self = Self(DUMP_MEDIUM);
    pub const HIGH: Self = Self(DUMP_HIGH);
    pub const FULL: Self = Self(DUMP_FULL);
    pub const DEBUG: Self = Self(DUMP_DEBUG);

    /// Build a numeric threshold. Values above `debug` are accepted as custom
    /// maximum-detail thresholds; values at or below zero behave as `none`.
    pub const fn new(value: i32) -> Self {
        Self(value)
    }

    /// Return the raw numeric threshold.
    pub const fn value(self) -> i32 {
        self.0
    }

    /// Return true when this configured threshold enables an event level.
    pub fn allows(self, event_level: Self) -> bool {
        self.0 > DUMP_NONE && event_level.0 > DUMP_NONE && self.0 >= event_level.0
    }

    /// Return the Perl-compatible bucket name for this numeric level.
    pub fn bucket_name(self) -> &'static str {
        match self.0 {
            value if value <= DUMP_NONE => "none",
            value if value <= DUMP_LOW => "low",
            value if value <= DUMP_MEDIUM => "medium",
            value if value <= DUMP_HIGH => "high",
            value if value <= DUMP_FULL => "full",
            _ => "debug",
        }
    }
}

impl Default for TraceLevel {
    fn default() -> Self {
        Self::NONE
    }
}

impl fmt::Display for TraceLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.bucket_name())
    }
}

impl FromStr for TraceLevel {
    type Err = TraceError;

    fn from_str(input: &str) -> TraceResult<Self> {
        let trimmed = input.trim();
        if trimmed.is_empty() {
            return Err(TraceError::config("empty trace level"));
        }
        if let Ok(value) = trimmed.parse::<i32>() {
            return Ok(Self::new(value));
        }

        match trimmed.to_ascii_lowercase().as_str() {
            "none" | "quiet" | "off" => Ok(Self::NONE),
            "low" => Ok(Self::LOW),
            "medium" | "med" => Ok(Self::MEDIUM),
            "high" => Ok(Self::HIGH),
            "full" => Ok(Self::FULL),
            "debug" | "verbose" => Ok(Self::DEBUG),
            _ => Err(TraceError::config(format!(
                "unsupported trace level '{input}'"
            ))),
        }
    }
}

/// Trace output routing mode.
#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub enum TraceSinkMode {
    /// Write trace output to stdout only.
    Stdout,
    /// Write trace output to the configured file only.
    Route,
    /// Write trace output to stdout and the configured file.
    Mirror,
}

impl Default for TraceSinkMode {
    fn default() -> Self {
        Self::Stdout
    }
}

impl fmt::Display for TraceSinkMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Self::Stdout => "stdout",
            Self::Route => "route",
            Self::Mirror => "mirror",
        })
    }
}

impl FromStr for TraceSinkMode {
    type Err = TraceError;

    fn from_str(input: &str) -> TraceResult<Self> {
        match input.trim().to_ascii_lowercase().as_str() {
            "stdout" | "console" => Ok(Self::Stdout),
            "route" | "routed" | "file" => Ok(Self::Route),
            "mirror" | "both" => Ok(Self::Mirror),
            _ => Err(TraceError::config(format!(
                "unsupported trace sink mode '{input}'"
            ))),
        }
    }
}

/// Effective trace configuration for Rust entrypoints.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TraceConfig {
    pub level: TraceLevel,
    pub trace_file: Option<PathBuf>,
    pub sink_mode: TraceSinkMode,
    pub reset_file: bool,
    pub emoji: bool,
}

impl Default for TraceConfig {
    fn default() -> Self {
        Self {
            level: TraceLevel::NONE,
            trace_file: None,
            sink_mode: TraceSinkMode::Stdout,
            reset_file: false,
            emoji: false,
        }
    }
}

impl TraceConfig {
    /// Return the default quiet configuration.
    pub fn disabled() -> Self {
        Self::default()
    }

    /// Return an enabled configuration at the requested level.
    pub fn enabled(level: TraceLevel) -> Self {
        Self {
            level,
            ..Self::default()
        }
    }

    pub fn with_level(mut self, level: TraceLevel) -> Self {
        self.level = level;
        self
    }

    pub fn with_trace_file(mut self, path: impl Into<PathBuf>) -> Self {
        self.trace_file = Some(path.into());
        if self.sink_mode == TraceSinkMode::Stdout {
            self.sink_mode = TraceSinkMode::Route;
        }
        self
    }

    pub fn with_sink_mode(mut self, sink_mode: TraceSinkMode) -> Self {
        self.sink_mode = sink_mode;
        self
    }

    pub fn with_reset_file(mut self, reset_file: bool) -> Self {
        self.reset_file = reset_file;
        self
    }

    pub fn with_emoji(mut self, emoji: bool) -> Self {
        self.emoji = emoji;
        self
    }

    /// Return true when this configuration enables the given event level.
    pub fn should_emit(&self, event_level: TraceLevel) -> bool {
        self.level.allows(event_level)
    }

    /// Build a trace configuration from the documented `LINKEDSPEC_TRACE_*`
    /// process environment controls.
    pub fn from_env() -> TraceResult<Self> {
        Self::from_lookup(|key| env::var(key).ok())
    }

    /// Build a trace configuration from a lookup function.
    ///
    /// Tests use this API instead of mutating process environment state.
    pub fn from_lookup<F>(mut lookup: F) -> TraceResult<Self>
    where
        F: FnMut(&str) -> Option<String>,
    {
        let mut config = Self::default();

        if let Some(level) =
            lookup("LINKEDSPEC_TRACE_LEVEL").or_else(|| lookup("LINKEDSPEC_DUMP_VERBOSITY"))
        {
            config.level = TraceLevel::from_str(&level)?;
        }

        if let Some(emoji) = lookup("LINKEDSPEC_TRACE_EMOJI") {
            config.emoji = trace_truthy(&emoji);
        }

        if let Some(trace_file) = lookup("LINKEDSPEC_TRACE_FILE") {
            let trimmed = trace_file.trim();
            if !trimmed.is_empty() {
                config = config.with_trace_file(trimmed);
                config.sink_mode = if lookup("LINKEDSPEC_TRACE_MIRROR_STDOUT")
                    .map(|value| trace_truthy(&value))
                    .unwrap_or(false)
                {
                    TraceSinkMode::Mirror
                } else {
                    TraceSinkMode::Route
                };
            }
        }

        if let Some(reset) = lookup("LINKEDSPEC_TRACE_RESET_FILE") {
            config.reset_file = trace_truthy(&reset);
        }

        Ok(config)
    }
}

/// High-level trace event kind.
#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub enum TraceEventKind {
    Enter,
    Exit,
    Decision,
    Mark,
    Dump,
    Log,
}

impl TraceEventKind {
    fn as_str(self) -> &'static str {
        match self {
            Self::Enter => "enter",
            Self::Exit => "exit",
            Self::Decision => "decision",
            Self::Mark => "mark",
            Self::Dump => "dump",
            Self::Log => "log",
        }
    }
}

/// Scope token returned by [`TraceEmitter::enter_scope`].
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TraceScope {
    topic: String,
    level: TraceLevel,
    emitted: bool,
}

/// Trace sink and formatting owner.
pub struct TraceEmitter {
    config: TraceConfig,
    file: Option<File>,
    stdout: Box<dyn Write + Send>,
    indent_level: usize,
    indent_width: usize,
}

impl TraceEmitter {
    /// Create an emitter that writes stdout-routed trace text to process stdout.
    pub fn new(config: TraceConfig) -> TraceResult<Self> {
        Self::with_stdout(config, Box::new(io::stdout()))
    }

    /// Create an emitter with an injected stdout writer.
    pub fn with_stdout(config: TraceConfig, stdout: Box<dyn Write + Send>) -> TraceResult<Self> {
        let file = if matches!(
            config.sink_mode,
            TraceSinkMode::Route | TraceSinkMode::Mirror
        ) {
            if let Some(path) = &config.trace_file {
                let mut options = OpenOptions::new();
                options.create(true).write(true);
                if config.reset_file {
                    options.truncate(true);
                } else {
                    options.append(true);
                }
                Some(options.open(path).map_err(|err| {
                    TraceError::io(format!(
                        "failed to open trace file '{}': {err}",
                        path.display()
                    ))
                })?)
            } else {
                None
            }
        } else {
            None
        };

        Ok(Self {
            config,
            file,
            stdout,
            indent_level: 0,
            indent_width: 2,
        })
    }

    pub fn config(&self) -> &TraceConfig {
        &self.config
    }

    pub fn should_emit(&self, event_level: TraceLevel) -> bool {
        self.config.should_emit(event_level)
    }

    /// Emit one already-formatted trace line, appending a newline if needed.
    pub fn emit_line(&mut self, event_level: TraceLevel, line: impl AsRef<str>) -> TraceResult<()> {
        if !self.should_emit(event_level) {
            return Ok(());
        }

        let mut payload = line.as_ref().to_string();
        if !payload.ends_with('\n') {
            payload.push('\n');
        }
        self.write_payload(payload.as_bytes())
    }

    /// Emit a structured event line.
    pub fn emit_event(
        &mut self,
        kind: TraceEventKind,
        topic: impl AsRef<str>,
        details: impl AsRef<str>,
        level: TraceLevel,
    ) -> TraceResult<()> {
        if !self.should_emit(level) {
            return Ok(());
        }

        let indent = " ".repeat(self.indent_level * self.indent_width);
        let details = details.as_ref();
        let detail_suffix = if details.trim().is_empty() {
            String::new()
        } else {
            format!(" {details}")
        };
        let line = match kind {
            TraceEventKind::Enter => {
                format!(
                    "[{}][{}] {}-> {}{}",
                    level.bucket_name().to_ascii_uppercase(),
                    kind.as_str(),
                    indent,
                    topic.as_ref(),
                    detail_suffix
                )
            }
            TraceEventKind::Exit => {
                format!(
                    "[{}][{}] {}<- {}{}",
                    level.bucket_name().to_ascii_uppercase(),
                    kind.as_str(),
                    indent,
                    topic.as_ref(),
                    detail_suffix
                )
            }
            _ => {
                format!(
                    "[{}][{}] {}{}{}",
                    level.bucket_name().to_ascii_uppercase(),
                    kind.as_str(),
                    indent,
                    topic.as_ref(),
                    detail_suffix
                )
            }
        };
        self.emit_line(level, line)
    }

    /// Emit an enter event and return the matching scope token.
    pub fn enter_scope(
        &mut self,
        topic: impl Into<String>,
        details: impl AsRef<str>,
        level: TraceLevel,
    ) -> TraceResult<TraceScope> {
        let topic = topic.into();
        let emitted = self.should_emit(level);
        if emitted {
            self.emit_event(TraceEventKind::Enter, &topic, details, level)?;
            self.indent_level += 1;
        }
        Ok(TraceScope {
            topic,
            level,
            emitted,
        })
    }

    /// Emit the exit event for a scope returned by [`enter_scope`](Self::enter_scope).
    pub fn exit_scope(&mut self, scope: TraceScope, details: impl AsRef<str>) -> TraceResult<()> {
        if scope.emitted {
            self.indent_level = self.indent_level.saturating_sub(1);
            self.emit_event(TraceEventKind::Exit, scope.topic, details, scope.level)?;
        }
        Ok(())
    }

    /// Emit a decision event and return the original branch value.
    pub fn trace_decision(
        &mut self,
        decision_name: impl AsRef<str>,
        taken: bool,
        reason: impl AsRef<str>,
        level: TraceLevel,
    ) -> bool {
        let details = format!(
            "taken={} reason={}",
            if taken { 1 } else { 0 },
            reason.as_ref()
        );
        let _ = self.emit_event(
            TraceEventKind::Decision,
            decision_name.as_ref(),
            details,
            level,
        );
        taken
    }

    pub fn log_output(
        &mut self,
        level: TraceLevel,
        message: impl AsRef<str>,
        context: impl AsRef<str>,
    ) -> TraceResult<()> {
        let context = context.as_ref();
        let details = if context.is_empty() {
            message.as_ref().to_string()
        } else {
            format!("{} context={context}", message.as_ref())
        };
        self.emit_event(TraceEventKind::Log, "log_output", details, level)
    }

    pub fn log_dump(&mut self, level: TraceLevel, message: impl AsRef<str>) -> TraceResult<()> {
        self.emit_event(TraceEventKind::Dump, "log_dump", message, level)
    }

    fn write_payload(&mut self, payload: &[u8]) -> TraceResult<()> {
        if !matches!(self.config.sink_mode, TraceSinkMode::Route) {
            self.stdout.write_all(payload).map_err(TraceError::from)?;
            self.stdout.flush().map_err(TraceError::from)?;
        }

        if matches!(
            self.config.sink_mode,
            TraceSinkMode::Route | TraceSinkMode::Mirror
        ) && let Some(file) = &mut self.file
        {
            file.write_all(payload).map_err(TraceError::from)?;
            file.flush().map_err(TraceError::from)?;
        }
        Ok(())
    }
}

/// Trace configuration or sink error.
#[derive(Debug, Clone, Eq, PartialEq)]
pub struct TraceError {
    message: String,
}

impl TraceError {
    fn config(message: impl Into<String>) -> Self {
        Self {
            message: message.into(),
        }
    }

    fn io(message: impl Into<String>) -> Self {
        Self {
            message: message.into(),
        }
    }
}

impl fmt::Display for TraceError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.message)
    }
}

impl std::error::Error for TraceError {}

impl From<io::Error> for TraceError {
    fn from(err: io::Error) -> Self {
        Self::io(err.to_string())
    }
}

pub type TraceResult<T> = std::result::Result<T, TraceError>;

fn trace_truthy(value: &str) -> bool {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        return false;
    }
    match trimmed.to_ascii_lowercase().as_str() {
        "0" | "false" | "no" | "off" => false,
        "1" | "true" | "yes" | "on" => true,
        _ => true,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::sync::{Arc, Mutex};
    use std::time::{SystemTime, UNIX_EPOCH};

    #[test]
    fn trace_level_parses_named_aliases_and_numeric_thresholds() {
        assert_eq!("none".parse::<TraceLevel>().unwrap(), TraceLevel::NONE);
        assert_eq!("quiet".parse::<TraceLevel>().unwrap(), TraceLevel::NONE);
        assert_eq!("med".parse::<TraceLevel>().unwrap(), TraceLevel::MEDIUM);
        assert_eq!("verbose".parse::<TraceLevel>().unwrap(), TraceLevel::DEBUG);
        assert_eq!("350".parse::<TraceLevel>().unwrap(), TraceLevel::new(350));
        assert_eq!("-1".parse::<TraceLevel>().unwrap(), TraceLevel::new(-1));
        assert!("unknown".parse::<TraceLevel>().is_err());
    }

    #[test]
    fn trace_level_thresholds_gate_events_like_dump_verbosity() {
        assert!(!TraceLevel::NONE.allows(TraceLevel::LOW));
        assert!(!TraceLevel::LOW.allows(TraceLevel::MEDIUM));
        assert!(TraceLevel::MEDIUM.allows(TraceLevel::LOW));
        assert!(TraceLevel::DEBUG.allows(TraceLevel::FULL));
        assert!(TraceLevel::new(350).allows(TraceLevel::HIGH));
        assert!(!TraceLevel::new(350).allows(TraceLevel::FULL));
    }

    #[test]
    fn trace_config_from_lookup_matches_documented_environment_controls() {
        let config = TraceConfig::from_lookup(|key| match key {
            "LINKEDSPEC_TRACE_LEVEL" => Some("debug".to_string()),
            "LINKEDSPEC_TRACE_FILE" => Some("trace.log".to_string()),
            "LINKEDSPEC_TRACE_MIRROR_STDOUT" => Some("1".to_string()),
            "LINKEDSPEC_TRACE_RESET_FILE" => Some("yes".to_string()),
            "LINKEDSPEC_TRACE_EMOJI" => Some("on".to_string()),
            _ => None,
        })
        .unwrap();

        assert_eq!(config.level, TraceLevel::DEBUG);
        assert_eq!(config.trace_file, Some(PathBuf::from("trace.log")));
        assert_eq!(config.sink_mode, TraceSinkMode::Mirror);
        assert!(config.reset_file);
        assert!(config.emoji);
    }

    #[test]
    fn trace_file_defaults_to_route_and_reset_truncates() {
        let path = temp_trace_path("route-reset");
        fs::write(&path, "old\n").unwrap();

        let config = TraceConfig::enabled(TraceLevel::DEBUG)
            .with_trace_file(path.clone())
            .with_reset_file(true);
        let mut emitter = TraceEmitter::new(config).unwrap();
        emitter.emit_line(TraceLevel::LOW, "hello").unwrap();
        drop(emitter);

        assert_eq!(fs::read_to_string(&path).unwrap(), "hello\n");
        let _ = fs::remove_file(path);
    }

    #[test]
    fn mirror_sink_writes_stdout_and_file() {
        let path = temp_trace_path("mirror");
        let stdout = SharedBuffer::default();
        let stdout_reader = stdout.clone();
        let config = TraceConfig::enabled(TraceLevel::DEBUG)
            .with_trace_file(path.clone())
            .with_sink_mode(TraceSinkMode::Mirror)
            .with_reset_file(true);

        let mut emitter = TraceEmitter::with_stdout(config, Box::new(stdout)).unwrap();
        emitter
            .emit_event(TraceEventKind::Log, "topic", "details", TraceLevel::LOW)
            .unwrap();
        drop(emitter);

        let expected = "[LOW][log] topic details\n";
        assert_eq!(stdout_reader.to_string(), expected);
        assert_eq!(fs::read_to_string(&path).unwrap(), expected);
        let _ = fs::remove_file(path);
    }

    #[test]
    fn log_output_and_log_dump_emit_structured_events() {
        let stdout = SharedBuffer::default();
        let stdout_reader = stdout.clone();
        let config = TraceConfig::enabled(TraceLevel::DEBUG);
        let mut emitter = TraceEmitter::with_stdout(config, Box::new(stdout)).unwrap();

        emitter
            .log_output(TraceLevel::LOW, "runtime message", "ctx=runtime")
            .unwrap();
        emitter
            .log_dump(TraceLevel::FULL, "compiled descriptor dump")
            .unwrap();

        let output = stdout_reader.to_string();
        assert!(output.contains("[LOW][log] log_output runtime message context=ctx=runtime"));
        assert!(output.contains("[FULL][dump] log_dump compiled descriptor dump"));
    }

    #[test]
    fn scope_and_decision_primitives_preserve_branch_values() {
        let stdout = SharedBuffer::default();
        let stdout_reader = stdout.clone();
        let config = TraceConfig::enabled(TraceLevel::DEBUG);
        let mut emitter = TraceEmitter::with_stdout(config, Box::new(stdout)).unwrap();

        let scope = emitter
            .enter_scope("compile", "start", TraceLevel::HIGH)
            .unwrap();
        assert!(!emitter.trace_decision("use_cache", false, "miss", TraceLevel::DEBUG));
        emitter.exit_scope(scope, "done").unwrap();

        let output = stdout_reader.to_string();
        assert!(output.contains("[HIGH][enter] -> compile start"));
        assert!(output.contains("[DEBUG][decision]   use_cache taken=0 reason=miss"));
        assert!(output.contains("[HIGH][exit] <- compile done"));
    }

    fn temp_trace_path(name: &str) -> PathBuf {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        env::temp_dir().join(format!(
            "linkedspec-{name}-{}-{nanos}.trace",
            std::process::id()
        ))
    }

    #[derive(Clone, Default)]
    struct SharedBuffer {
        bytes: Arc<Mutex<Vec<u8>>>,
    }

    impl SharedBuffer {
        fn to_string(&self) -> String {
            String::from_utf8(self.bytes.lock().unwrap().clone()).unwrap()
        }
    }

    impl Write for SharedBuffer {
        fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
            self.bytes.lock().unwrap().extend_from_slice(buf);
            Ok(buf.len())
        }

        fn flush(&mut self) -> io::Result<()> {
            Ok(())
        }
    }
}
