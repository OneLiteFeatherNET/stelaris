/// The roles this application gates its interface on.
///
/// Provisional. The names a deployment actually grants are the provider's to
/// decide, and they are not settled yet; what is settled is that gating happens
/// here and nowhere else, so renaming one is a change to this file.
///
/// Gating is presentation. The backend decides what is permitted, and refuses
/// anything these names got wrong - so an outdated constant costs a visible
/// button and a 403, never unauthorised access.
abstract final class Roles {
  /// May delete models. The only destructive, irreversible action in the app.
  static const String admin = 'stelaris.admin';

  /// May create and change models.
  static const String editor = 'stelaris.editor';
}
