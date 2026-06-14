# Plugin Registry and Legacy Transition

LinkedSpec exposes plugin registration and lookup methods on the public facade. These methods support the plugin system used by shipped `.plg` plugin files and the legacy `PPlugin` runtime.

## Registry maintenance

### `register_plugin($name, $plugin_ref)`

Registers a single plugin by name. `$plugin_ref` is a `PPlugin` instance.

```perl
LinkedSpec::register_plugin('my_plugin', $plugin_instance);
```

### `register_plugins(%plugins)`

Registers multiple plugins at once. Keys are plugin names, values are `PPlugin` instances.

```perl
LinkedSpec::register_plugins(
  plugin_a => $p_a,
  plugin_b => $p_b,
);
```

### `clear_registered_plugins()`

Removes all registered plugins. Called when a fresh plugin state is needed.

```perl
LinkedSpec::clear_registered_plugins();
```

## Legacy transition surface

These methods exist on the public facade for compatibility with existing plugin-using code. They delegate to `LinkedSpec::PluginBridge`, which routes through `PPlugin`.

### `run_plugin($name, @args)`

Runs a registered plugin by name with the given arguments. Returns the plugin's result.

### `get_plugin($name)`

Returns the registered `PPlugin` instance for the given name, or `undef` if not found.

### `dispatch_plugin_autoload_name($name)`

Resolves and dispatches an autoloaded plugin name. Used by the plugin autoloader mechanism.

### `AUTOLOAD`

Perl `AUTOLOAD` handler that catches unresolved method calls on `LinkedSpec` and attempts to route them through registered plugins. This is legacy compatibility behavior.

**Status note:** All seven legacy transition-surface methods (`run_plugin`, `get_plugin`, `dispatch_plugin_autoload_name`, `AUTOLOAD`, `register_plugin`, `register_plugins`, `clear_registered_plugins`) are **DEPRECATED** as of the PLUGIN-MODERNIZATION tree (completed 2026-05-17). They remain on the public facade while the remaining `.plg` files (down from ~36 to 19 after modernization) still use the plugin infrastructure, but new code must use canonical package owners directly. The retirement path is documented in PLUGIN-MODERNIZATION.5: migrate `.plg` actions to package owners, retire `PPlugin`, reduce/delete `PluginBridge`, remove deprecated facade methods, then migrate `FSMGen::AUTOLOAD`.

## Relationship to the compile/runtime surface

The plugin system is separate from the main compile/runtime pipeline (`Get`, `get_parser`). Plugins provide domain-specific functionality (timing analysis, table filtering, etc.) rather than parser compilation. The two surfaces share the same `LinkedSpec` facade but dispatch to different owner trees:

- Compile/runtime → `Compiler`, `SpecEntry`, `Runtime`, `RuntimeContext`
- Plugin registry → `PluginRegistry`, `PluginBridge`, `PPlugin`
