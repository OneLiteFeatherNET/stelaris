import 'package:stelaris/l10n/app_localizations.dart';

/// How many roles are worth naming before the line stops being readable.
///
/// There is no upper bound on what a provider puts in a role claim: Entra ID
/// with the groups claim turned on emits one object id per group, which can
/// be dozens. Listing them all turns an account menu into a wall of GUIDs and
/// pushes the way out off the bottom of it.
const int _rolesShown = 3;

/// The roles of a session in one line: the first few by name, then how many
/// more there are, or a note that there are none.
String rolesLine(Set<String> roles, AppLocalizations l10n) {
  if (roles.isEmpty) {
    return l10n.auth_no_roles;
  }
  final List<String> named = roles.take(_rolesShown).toList();
  final int rest = roles.length - named.length;
  if (rest == 0) {
    return named.join(', ');
  }
  return '${named.join(', ')} ${l10n.auth_roles_more(rest)}';
}
