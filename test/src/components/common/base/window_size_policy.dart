import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart'
    show ErrorsResult, LibraryElementResult, ResolvedUnitResult;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:path/path.dart' as p;

/// The window-size policy checker over the resolved AST (FO-08 US-08 FR-01,
/// FR-02; base `s03_domain.md` INV-22, INV-23).
///
/// Every Dart file under `root` is resolved by `package:analyzer`, with
/// overlays standing in for files that exist only in memory. A rule hit is
/// `path:line: <source>`:
///
/// (a) a `<`, `<=`, `>`, or `>=` whose resolved operator is declared by
///     `WindowSize`, or whose operand reads `.index` off a `WindowSize`
///     (INV-23);
/// (b) a `switch` expression or statement over a `WindowSize` value with a
///     `default` or `_` case (INV-23);
/// (c) a size-to-number table over `WindowSize` or `WidgetSize` (INV-22): a
///     `switch` expression over one, or a conditional expression whose
///     condition tests one by `==` or `!=`, whose static type is `num`,
///     `int`, or `double`; a `switch` statement over one, or an if chain
///     whose conditions test one by `==` or `!=`, with a branch that returns
///     or assigns a number; a map literal keyed by one with number values.
///     An if chain is one hit, at its head.
///
/// `WidgetSize` order comparisons stay allowed; `WindowSize`'s operators stay
/// public for app code, so the rule reads the resolved operator's declaring
/// element instead of the source text.
///
/// One [AnalysisContextCollection] serves every call in the process, so the
/// warm context is paid for once; overlays swap between calls without a
/// rebuild of the element model.
final class WindowSizePolicyChecker {
  /// Scans the package rooted at the process's working directory.
  new() {
    final packageRoot = Directory.current.path;
    _collection = AnalysisContextCollection(
      includedPaths: [packageRoot],
      resourceProvider: _provider,
      sdkPath: _dartSdkPath(),
    );
  }

  final OverlayResourceProvider _provider = OverlayResourceProvider(
    PhysicalResourceProvider.INSTANCE,
  );

  late final AnalysisContextCollection _collection;

  final List<String> _appliedOverlays = [];

  EnumElement? _windowSize;

  EnumElement? _widgetSize;

  /// The rule hits under `root`, one `path:line: <source>` per break.
  Future<List<String>> windowSizeRuleHits({
    required String root,
    Map<String, String> overlays = const {},
  }) async {
    await _applyOverlays(overlays);
    await _resolveEnums();
    final hits = <String>[];
    for (final file in _dartFilesUnder(root, overlays: overlays)) {
      final context = _collection.contextFor(file);
      final result = await context.currentSession.getResolvedUnit(file);
      if (result is! ResolvedUnitResult) continue;
      final visitor = _PolicyVisitor(
        windowSize: _windowSize,
        widgetSize: _widgetSize,
      );
      result.unit.accept(visitor);
      for (final hit in visitor.hits) {
        final line = result.lineInfo.getLocation(hit.offset).lineNumber;
        hits.add('${_relative(file)}:$line: ${hit.source}');
      }
    }
    hits.sort();
    return hits;
  }

  /// The compile errors of every overlay file, each
  /// `path:line: <code>: <message>`, so a probe can prove the tree rejects
  /// a value the docs do not name (FO-07 US-03 FR-02 E01).
  Future<List<String>> compileErrors(Map<String, String> overlays) async {
    await _applyOverlays(overlays);
    final errors = <String>[];
    for (final path in overlays.keys) {
      final file = _absolute(path);
      final context = _collection.contextFor(file);
      final result = await context.currentSession.getErrors(file);
      if (result is! ErrorsResult) continue;
      for (final diagnostic in result.diagnostics) {
        final line = result.lineInfo.getLocation(diagnostic.offset).lineNumber;
        final name = diagnostic.diagnosticCode.lowerCaseName;
        final message = diagnostic.problemMessage.messageText(
          includeUrl: false,
        );
        errors.add('${_relative(file)}:$line: $name: $message');
      }
    }
    errors.sort();
    return errors;
  }

  /// Frees the analysis context.
  Future<void> dispose() => _collection.dispose();

  /// Swaps the overlays: removes the ones no longer wanted, writes the new
  /// ones, and invalidates both sets, so the next result sees the change
  /// without rebuilding the context.
  Future<void> _applyOverlays(Map<String, String> overlays) async {
    final next = {
      for (final entry in overlays.entries) _absolute(entry.key): entry.value,
    };
    final changed = <String>{};
    _appliedOverlays.where((stale) => !next.containsKey(stale)).forEach((
      stale,
    ) {
      _provider.removeOverlay(stale);
      changed.add(stale);
    });
    for (final entry in next.entries) {
      final untouched =
          _provider.hasOverlay(entry.key) &&
          _provider.getFile(entry.key).readAsStringSync() == entry.value;
      if (!untouched) {
        _provider.setOverlay(
          entry.key,
          content: entry.value,
          modificationStamp: 0,
        );
        changed.add(entry.key);
      }
    }
    if (changed.isNotEmpty) {
      final context = _collection.contextFor(changed.first);
      changed.forEach(context.changeFile);
      await context.applyPendingFileChanges();
    }
    _appliedOverlays
      ..clear()
      ..addAll(next.keys);
  }

  /// Resolves the `WindowSize` and `WidgetSize` enum elements from their
  /// declaring libraries, once, so every unit matches by element identity
  /// however it imports them: directly, or through any barrel's `export`
  /// chain (`LibraryImport.importedLibrary.getEnum` stops at the first hop).
  Future<void> _resolveEnums() async {
    if (_windowSize != null && _widgetSize != null) return;
    final session = _collection.contexts.first.currentSession;
    final windowLibrary = await session.getLibraryByUri(
      'package:stratum_ui/src/themes/constant/window_size.dart',
    );
    final widgetLibrary = await session.getLibraryByUri(
      'package:stratum_ui/src/themes/constant/widget_size.dart',
    );
    _windowSize = windowLibrary is LibraryElementResult
        ? windowLibrary.element.getEnum('WindowSize')
        : null;
    _widgetSize = widgetLibrary is LibraryElementResult
        ? widgetLibrary.element.getEnum('WidgetSize')
        : null;
  }
}

/// One recorded rule break: its offset in the unit and its source text.
class _Hit {
  const new(this.offset, this.source);

  final int offset;

  final String source;
}

/// Walks a resolved unit and records one [_Hit] per rule break.
class _PolicyVisitor extends RecursiveAstVisitor<void> {
  /// Records hits while walking a unit that names [windowSize] or
  /// [widgetSize], however it imports them.
  new({required this.windowSize, required this.widgetSize});

  /// The declaring `WindowSize` enum element, or `null` while unresolved.
  final EnumElement? windowSize;

  /// The declaring `WidgetSize` enum element, or `null` while unresolved.
  final EnumElement? widgetSize;

  /// One entry per rule break the unit holds.
  final List<_Hit> hits = [];

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operator = node.operator.type;
    if (operator == TokenType.LT ||
        operator == TokenType.LT_EQ ||
        operator == TokenType.GT ||
        operator == TokenType.GT_EQ) {
      final element = node.element;
      final byOperator =
          element != null && element.enclosingElement == windowSize;
      if (byOperator ||
          _isWindowIndex(node.leftOperand) ||
          _isWindowIndex(node.rightOperand)) {
        hits.add(
          _Hit(node.offset, 'order comparison ${node.toSource()} (INV-23)'),
        );
      }
    }
    super.visitBinaryExpression(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    final subject = node.expression.staticType;
    final isWindow = _is(subject, windowSize);
    final isWidget = _is(subject, widgetSize);
    if (isWindow || isWidget) {
      var hasCatchAll = false;
      for (final switchCase in node.cases) {
        if (_isCatchAllPattern(switchCase.guardedPattern.pattern)) {
          hasCatchAll = true;
          break;
        }
      }
      if (hasCatchAll) {
        hits.add(
          _Hit(node.offset, 'catch-all switch ${node.toSource()} (INV-23)'),
        );
      }
      if (_isNumeric(node.staticType)) {
        hits.add(
          _Hit(node.offset, 'size-to-number ${node.toSource()} (INV-22)'),
        );
      }
    }
    super.visitSwitchExpression(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    final subject = node.expression.staticType;
    if (_is(subject, windowSize)) {
      for (final member in node.members) {
        final isCatchAll =
            member is SwitchDefault ||
            (member is SwitchPatternCase &&
                _isCatchAllPattern(member.guardedPattern.pattern));
        if (isCatchAll) {
          hits.add(
            _Hit(node.offset, 'catch-all switch ${node.toSource()} (INV-23)'),
          );
          break;
        }
      }
    }
    if (_isSize(subject) && node.members.any(_yieldsNumber)) {
      hits.add(_Hit(node.offset, 'size-to-number ${node.toSource()} (INV-22)'));
    }
    super.visitSwitchStatement(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (_testsSize(node.condition) && _isNumeric(node.staticType)) {
      hits.add(_Hit(node.offset, 'size-to-number ${node.toSource()} (INV-22)'));
    }
    super.visitConditionalExpression(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    final parent = node.parent;
    final isChainHead =
        parent is! IfStatement || !identical(parent.elseStatement, node);
    if (isChainHead) {
      for (
        Statement? link = node;
        link is IfStatement;
        link = link.elseStatement
      ) {
        if (_testsSize(link.expression) && _yieldsNumber(link.thenStatement)) {
          hits.add(
            _Hit(node.offset, 'size-to-number ${node.toSource()} (INV-22)'),
          );
          break;
        }
      }
    }
    super.visitIfStatement(node);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    final type = node.staticType;
    if (node.isMap &&
        type is InterfaceType &&
        type.isDartCoreMap &&
        _isSize(type.typeArguments.first) &&
        _isNumeric(type.typeArguments.last)) {
      hits.add(_Hit(node.offset, 'size-to-number ${node.toSource()} (INV-22)'));
    }
    super.visitSetOrMapLiteral(node);
  }

  /// Whether [condition] tests a `WindowSize` or `WidgetSize` by `==` or
  /// `!=`, alone or inside an `&&` or `||`.
  bool _testsSize(Expression condition) {
    final test = condition.unParenthesized;
    if (test is! BinaryExpression) return false;
    final operator = test.operator.type;
    if (operator == TokenType.AMPERSAND_AMPERSAND ||
        operator == TokenType.BAR_BAR) {
      return _testsSize(test.leftOperand) || _testsSize(test.rightOperand);
    }
    return (operator == TokenType.EQ_EQ || operator == TokenType.BANG_EQ) &&
        (_isSize(test.leftOperand.staticType) ||
            _isSize(test.rightOperand.staticType));
  }

  /// Whether [operand] reads `.index` off a `WindowSize` value.
  bool _isWindowIndex(Expression operand) {
    final read = operand.unParenthesized;
    final (target, name) = switch (read) {
      PrefixedIdentifier(:final prefix, :final identifier) => (
        prefix,
        identifier.name,
      ),
      PropertyAccess(:final realTarget, :final propertyName) => (
        realTarget,
        propertyName.name,
      ),
      _ => (null, null),
    };
    return name == 'index' && _is(target?.staticType, windowSize);
  }

  /// Whether [node] returns or assigns a number, outside any function
  /// nested in it.
  bool _yieldsNumber(AstNode node) {
    final finder = _NumberYieldFinder(_isNumeric);
    node.accept(finder);
    return finder.found;
  }

  bool _isSize(DartType? type) =>
      _is(type, windowSize) || _is(type, widgetSize);

  /// A `_` wildcard, or a constant `_` identifier used as a pattern.
  bool _isCatchAllPattern(DartPattern pattern) {
    if (pattern is WildcardPattern) return true;
    return pattern is ConstantPattern &&
        pattern.expression is SimpleIdentifier &&
        (pattern.expression as SimpleIdentifier).token.lexeme == '_';
  }

  bool _is(DartType? type, EnumElement? target) =>
      target != null && type is InterfaceType && type.element == target;

  bool _isNumeric(DartType? type) =>
      type is InterfaceType &&
      (type.isDartCoreNum || type.isDartCoreInt || type.isDartCoreDouble);
}

/// Finds a `return` or an assignment of a number in a branch, skipping the
/// bodies of functions nested in it, which yield to their own callers.
class _NumberYieldFinder extends RecursiveAstVisitor<void> {
  new(this._isNumeric);

  final bool Function(DartType? type) _isNumeric;

  /// Whether the walked branch returns or assigns a number.
  bool found = false;

  @override
  void visitReturnStatement(ReturnStatement node) {
    if (_isNumeric(node.expression?.staticType)) found = true;
    super.visitReturnStatement(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (_isNumeric(node.staticType)) found = true;
    super.visitAssignmentExpression(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {}
}

String _absolute(String path) =>
    p.isAbsolute(path) ? p.normalize(path) : p.normalize(p.absolute(path));

String _relative(String file) => p.relative(file, from: Directory.current.path);

/// The real Dart files under `root`, plus every overlay inside it, so an
/// in-memory probe is scanned without touching the disk.
List<String> _dartFilesUnder(
  String root, {
  Map<String, String> overlays = const {},
}) {
  final directory = Directory(_absolute(root));
  if (!directory.existsSync()) {
    throw StateError('No such directory: ${directory.path}');
  }
  final files = directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .map((file) => file.path)
      .where((path) => p.extension(path) == '.dart')
      .where((path) => !path.contains('${p.separator}generated${p.separator}'))
      .toSet();
  for (final overlay in overlays.keys) {
    final absolute = _absolute(overlay);
    if (p.isWithin(_absolute(root), absolute)) {
      files.add(absolute);
    }
  }
  return files.toList()..sort();
}

/// The Flutter SDK's bundled Dart SDK: `FLUTTER_ROOT`'s
/// `bin/cache/dart-sdk` when set, else the ancestor of the test runner's own
/// executable that holds it.
String _dartSdkPath() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    final sdk = p.join(flutterRoot, 'bin', 'cache', 'dart-sdk');
    if (Directory(sdk).existsSync()) return sdk;
  }
  var directory = File(Platform.resolvedExecutable).parent;
  while (true) {
    final candidate = p.join(directory.path, 'bin', 'cache', 'dart-sdk');
    if (Directory(candidate).existsSync()) return candidate;
    final parent = directory.parent;
    if (parent.path == directory.path) break;
    directory = parent;
  }
  throw StateError('No dart-sdk found above ${Platform.resolvedExecutable}');
}
