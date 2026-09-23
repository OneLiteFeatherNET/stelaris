import 'package:material_ui/material_ui.dart';

/// The forms of the currently shown detail page. The save action lives in
/// the page header, far from the tab bodies that own the forms, so the
/// forms register here instead of each carrying its own save button.
abstract final class DetailForms {
  static final Set<GlobalKey<FormState>> _keys = {};

  static void register(GlobalKey<FormState> key) => _keys.add(key);

  static void unregister(GlobalKey<FormState> key) => _keys.remove(key);

  /// Validates every registered form that is currently mounted — not just
  /// the first invalid one, so each shows its error text.
  static bool validateAll() {
    var valid = true;
    for (final key in _keys.toList()) {
      valid = (key.currentState?.validate() ?? true) && valid;
    }
    return valid;
  }
}

/// Registers [formKey] with [DetailForms] for as long as it is mounted.
/// Renders nothing — drop it next to the form it registers.
class RegisterDetailForm extends StatefulWidget {
  const RegisterDetailForm({required this.formKey, super.key});

  final GlobalKey<FormState> formKey;

  @override
  State<RegisterDetailForm> createState() => _RegisterDetailFormState();
}

class _RegisterDetailFormState extends State<RegisterDetailForm> {
  @override
  void initState() {
    super.initState();
    DetailForms.register(widget.formKey);
  }

  @override
  void didUpdateWidget(RegisterDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formKey != widget.formKey) {
      DetailForms.unregister(oldWidget.formKey);
      DetailForms.register(widget.formKey);
    }
  }

  @override
  void dispose() {
    DetailForms.unregister(widget.formKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
