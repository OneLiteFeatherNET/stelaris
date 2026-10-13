import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_sessions.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/feature/auth/roles_line.dart';
import 'package:stelaris/l10n/app_localizations.dart';

/// Who is signed in, and the way out.
///
/// Renders nothing at all in a deployment without an identity provider: there
/// is no session to show, and an account menu that cannot do anything is worse
/// than no menu.
class SessionIndicator extends StatelessWidget {
  const SessionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthState>(
      converter: (store) => store.state.auth,
      builder: (context, auth) {
        if (!auth.isEnabled || !auth.isSignedIn) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context)!;
        final String? name = auth.displayName;

        return PopupMenuButton<void>(
          tooltip: name ?? l10n.auth_account,
          icon: const Icon(Icons.account_circle_outlined),
          itemBuilder: (context) => [
            PopupMenuItem<void>(
              enabled: false,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(name ?? l10n.auth_signed_in),
                subtitle: Text(rolesLine(auth.roles, l10n)),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<void>(
              onTap: () => AuthSessions.signOut(),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout),
                title: Text(l10n.auth_sign_out),
              ),
            ),
          ],
        );
      },
    );
  }
}
