import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_sessions.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/feature/auth/roles_line.dart';
import 'package:stelaris/feature/settings/settings_card.dart';
import 'package:stelaris/feature/settings/settings_section.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Who is signed in, and the way out. Shows nothing in a deployment without
/// an identity provider.
class AccountSettingsRow extends StatelessWidget {
  const AccountSettingsRow({this.signOut, super.key});

  /// Ends the session. Defaults to [AuthSessions.signOut], the call the
  /// account menu makes too.
  final Future<void> Function()? signOut;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthState>(
      converter: (store) => store.state.auth,
      builder: (context, auth) {
        if (!auth.isEnabled) return const SizedBox.shrink();

        final l10n = context.l10n;
        return SettingsSection(
          title: l10n.settings_section_account,
          children: [
            if (auth.isSignedIn)
              SettingsCard(
                icon: Icons.account_circle_outlined,
                title: auth.displayName ?? l10n.auth_signed_in,
                subtitle: rolesLine(auth.roles, l10n),
                trailing: OutlinedButton.icon(
                  onPressed: signOut ?? AuthSessions.signOut,
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.auth_sign_out),
                ),
              )
            else
              SettingsCard(
                icon: Icons.account_circle_outlined,
                title: auth.status == AuthStatus.expired
                    ? l10n.auth_session_expired
                    : l10n.settings_account_signed_out,
              ),
          ],
        );
      },
    );
  }
}
