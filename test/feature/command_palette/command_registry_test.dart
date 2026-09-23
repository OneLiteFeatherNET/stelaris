import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/l10n/app_localizations.dart';

StelarisCommand _command(
  String id, {
  CommandGroup group = CommandGroup.interface,
  String? title,
  List<String> keywords = const <String>[],
  String? requiredRole,
  bool Function(CommandContext)? isAvailable,
}) {
  return StelarisCommand(
    id: id,
    title: (_) => title ?? id,
    keywords: (_) => keywords,
    group: group,
    icon: const IconData(0),
    requiredRole: requiredRole,
    isAvailable: isAvailable ?? (_) => true,
    run: (_) async {},
  );
}

CommandContext _context({
  AuthState auth = const AuthState.disabled(),
  String location = '/items',
}) {
  return CommandContext(
    state: const AppState().copyWith(auth: auth),
    location: location,
  );
}

List<String> _ids(List<StelarisCommand> commands) =>
    commands.map((command) => command.id).toList();

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  group('CommandRegistry.available', () {
    final registry = CommandRegistry([
      _command('open'),
      _command('admin-only', requiredRole: Roles.admin),
      _command('never', isAvailable: (_) => false),
    ]);

    test('leaves out a command whose role the session lacks', () {
      final context = _context(
        auth: const AuthState(
          status: AuthStatus.signedIn,
          roles: {Roles.editor},
        ),
      );
      expect(_ids(registry.available(context)), ['open']);
    });

    test('keeps it when the session holds the role', () {
      final context = _context(
        auth: const AuthState(
          status: AuthStatus.signedIn,
          roles: {Roles.admin},
        ),
      );
      expect(_ids(registry.available(context)), ['open', 'admin-only']);
    });

    test('keeps it when no identity provider is configured', () {
      expect(_ids(registry.available(_context())), ['open', 'admin-only']);
    });

    test('leaves out a command whose own check fails', () {
      expect(_ids(registry.available(_context())), isNot(contains('never')));
    });

    test('a role-gated command cannot be found by searching either', () {
      final context = _context(
        auth: const AuthState(status: AuthStatus.signedIn),
      );
      expect(registry.search('admin', context, l10n), isEmpty);
    });
  });

  group('CommandRegistry.search', () {
    final registry = CommandRegistry([
      _command('b1', group: CommandGroup.backend),
      _command('i1', group: CommandGroup.interface),
      _command('n1', group: CommandGroup.navigation),
      _command('n2', group: CommandGroup.navigation),
      _command('i2', group: CommandGroup.interface),
    ]);

    test('an empty query returns every available command in group order', () {
      expect(_ids(registry.search('', _context(), l10n)), [
        'n1',
        'n2',
        'i1',
        'i2',
        'b1',
      ]);
    });

    test('ranks a title match above a keyword-only match', () {
      final registry = CommandRegistry([
        _command('keyword', title: 'Reload lists', keywords: ['theme']),
        _command('title', title: 'Toggle theme'),
      ]);
      expect(_ids(registry.search('theme', _context(), l10n)), [
        'title',
        'keyword',
      ]);
    });

    test('keeps registry order for equal scores', () {
      final registry = CommandRegistry([
        _command('first', title: 'Same'),
        _command('second', title: 'Same'),
        _command('third', title: 'Same'),
      ]);
      expect(_ids(registry.search('same', _context(), l10n)), [
        'first',
        'second',
        'third',
      ]);
    });

    test('drops commands that do not match', () {
      final registry = CommandRegistry([
        _command('dark', title: 'Toggle dark mode'),
        _command('items', title: 'Go to Items'),
      ]);
      expect(_ids(registry.search('dark', _context(), l10n)), ['dark']);
    });
  });
}
