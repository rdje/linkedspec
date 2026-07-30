// FUTURE-PARITY-BACKLOG.10.9.4.1 — generated Dart MCP binding/runtime proof.

import 'package:linkedspec_dart/src/mcp/mcp_server.dart';
import 'package:test/test.dart';

void main() {
  test('embedded bundle is digest-verified and clone-isolated', () {
    final first = McpServerTestHarness.contract();
    expect(first['protocol_version'], '2026-07-28');
    first['protocol_version'] = 'mutated';
    expect(McpServerTestHarness.contract()['protocol_version'], '2026-07-28');

    final discover = McpServerTestHarness.frame('discover_request');
    expect(discover, isNotNull);
    expect(McpServerTestHarness.validateFrame(discover), isTrue);
  });

  test('frozen schema profile checks patterns and object closure', () {
    expect(
      McpServerTestHarness.validateNamed(
        'handle',
        List<String>.filled(43, 'A').join(),
      ),
      isTrue,
    );
    expect(
      McpServerTestHarness.validateNamed(
        'handle',
        List<String>.filled(42, 'A').join(),
      ),
      isFalse,
    );
    final discover = McpServerTestHarness.frame('discover_request')!;
    expect(
      McpServerTestHarness.validateNamed('discoverRequest', discover),
      isTrue,
    );
    discover['extra'] = true;
    expect(
      McpServerTestHarness.validateNamed('discoverRequest', discover),
      isFalse,
    );
    final query =
        McpServerTestHarness.frame('query_call_request')!['params']!
            as Map<String, Object?>;
    final arguments = query['arguments']! as Map<String, Object?>;
    final request = arguments['request']! as Map<String, Object?>;
    request['contract'] = 'linkedspec-semantic-query-v2';
    expect(
      McpServerTestHarness.validateNamed('semanticQueryRequest', request),
      isTrue,
    );
    request['contract'] = List<String>.filled(128, 'a').join();
    expect(
      McpServerTestHarness.validateNamed('semanticQueryRequest', request),
      isTrue,
    );
    for (final invalid in [
      '',
      List<String>.filled(129, 'a').join(),
      List<String>.filled(65, 'é').join(),
    ]) {
      request['contract'] = invalid;
      expect(
        McpServerTestHarness.validateNamed('semanticQueryRequest', request),
        isFalse,
      );
    }
  });

  test('top-level schema classifies the canonical corpus exactly', () {
    const accepted = <String>[
      'discover_request',
      'discover_response_perl',
      'discover_response_rust',
      'discover_response_dart',
      'discover_response_julia',
      'discover_response_lua',
      'tools_list_request',
      'tools_list_response_perl',
      'capabilities_call_request',
      'capabilities_call_response',
      'query_call_request',
      'query_call_response',
      'semantic_ok_false_request',
      'semantic_ok_false_response',
      'restricted_capabilities_request',
      'restricted_capabilities_response',
      'handle_unavailable_request',
      'handle_unavailable_response',
      'policy_denied_request',
      'policy_denied_response',
      'cancelled_notification',
      'unsupported_version_response',
      'missing_metadata_response',
      'legacy_initialize_response',
      'unknown_method_response',
      'unknown_tool_response',
      'malformed_arguments_response',
      'sanitized_internal_error_response',
    ];
    const rejected = <String>[
      'unsupported_version_request',
      'missing_metadata_request',
      'legacy_initialize_request',
      'legacy_initialized_notification',
      'unknown_method_request',
      'unknown_tool_request',
      'malformed_arguments_request',
    ];

    for (final id in accepted) {
      expect(
        McpServerTestHarness.validateFrame(McpServerTestHarness.frame(id)),
        isTrue,
        reason: '$id must be schema-accepted',
      );
    }
    for (final id in rejected) {
      expect(
        McpServerTestHarness.validateFrame(McpServerTestHarness.frame(id)),
        isFalse,
        reason: '$id must be schema-rejected',
      );
    }
  });

  test('canonical JSON recursively sorts keys without normalizing text', () {
    expect(
      McpServerTestHarness.canonicalJson({
        'z': 1,
        'a': {
          'β': 'e\u{301}',
          'a': [
            {'z': false, 'a': true},
          ],
        },
      }),
      '{"a":{"a":[{"a":true,"z":false}],"β":"é"},"z":1}',
    );
  });
}
