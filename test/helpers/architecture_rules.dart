/// Import and widget rules from ADR 0003 (#18) and #37, checked as plain text
/// so no extra package is needed.
library;

/// Files allowed to import every feature (composition roots).
const compositionRoots = {'lib/injection.dart', 'lib/router.dart'};

/// Files allowed to draw lines (the chart baseline). None exist yet.
const defaultChartFiles = <String>{};

const _domainAllowedDart = {'dart:core', 'dart:async', 'dart:convert'};
const _domainAllowedPackages = {
  'fpdart',
  'equatable',
  'meta',
  'uuid',
  'characters',
};
const _lineWidgets = ['Divider', 'VerticalDivider', 'Border', 'BorderSide'];

final _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);
final _lineWidget = RegExp('\\b(${_lineWidgets.join('|')})\\b');

/// Returns one message per broken rule in [sources] (path → file contents).
/// Paths use `/` and start with `lib/`.
List<String> findArchitectureViolations(
  Map<String, String> sources, {
  Set<String> chartFiles = defaultChartFiles,
}) {
  final violations = <String>[];
  for (final MapEntry(key: path, value: source) in sources.entries) {
    final code = _stripComments(source);
    for (final match in _directive.allMatches(code)) {
      final message = _checkImport(path, match.group(1)!);
      if (message != null) violations.add('$path: $message');
    }
    if (!chartFiles.contains(path)) {
      for (final match in _lineWidget.allMatches(code)) {
        violations.add(
          '$path: uses ${match.group(1)}; no lines outside the chart (#37)',
        );
      }
    }
  }
  return violations;
}

String? _checkImport(String path, String uri) {
  final from = path.substring('lib/'.length).split('/');
  final isInternal = uri.startsWith('package:snow_flow/');
  if (!uri.contains(':')) {
    return 'relative import "$uri"; use package:snow_flow/... instead';
  }
  final to = isInternal
      ? uri.substring('package:snow_flow/'.length).split('/')
      : const <String>[];

  if (from.contains('domain')) {
    final allowed = isInternal
        ? to.contains('domain')
        : _domainAllowedDart.contains(uri) ||
              _domainAllowedPackages.contains(_packageName(uri));
    if (!allowed) return 'domain/ must not import "$uri"';
  }

  if (compositionRoots.contains(path)) return null;
  if (to.isEmpty || to.first != 'features') return null;
  if (from.first == 'features') {
    if (from[1] != to[1]) return 'feature must not import "$uri"';
    return null;
  }
  return 'only features and composition roots may import "$uri"';
}

String? _packageName(String uri) =>
    uri.startsWith('package:') ? uri.substring(8).split('/').first : null;

String _stripComments(String source) => source
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp(r'//.*'), '');
