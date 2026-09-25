import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_sessions.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';

/// What an unauthenticated visitor sees.
///
/// Three states rather than one, because they need three different things: a
/// person who is simply signed out needs a button, a person whose session
/// expired needs to know that is what happened, and a deployment whose provider
/// cannot be reached needs to say so instead of offering a flow that will not
/// start.
class SignInPage extends StatelessWidget {
  const SignInPage({this.returnTo, super.key});

  /// The route the visitor asked for, to return to after signing in.
  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthState>(
      converter: (store) => store.state.auth,
      builder: (context, auth) {
        final l10n = AppLocalizations.of(context)!;
        final bool unavailable = auth.status == AuthStatus.unavailable;

        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      unavailable ? Icons.cloud_off : Icons.lock_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      appName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _messageFor(auth.status, l10n),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () =>
                          AuthSessions.current?.signIn(returnTo: returnTo),
                      icon: const Icon(Icons.login),
                      label: Text(
                        unavailable ? l10n.auth_retry : l10n.auth_sign_in,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _messageFor(AuthStatus status, AppLocalizations l10n) =>
      switch (status) {
        AuthStatus.expired => l10n.auth_session_expired,
        AuthStatus.unavailable => l10n.auth_provider_unavailable,
        _ => l10n.auth_sign_in_required,
      };
}
