import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/notification/selected_notification_state.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_grid.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/advancement.dart';

/// The notification's page: its material, title and frame type.
class NotificationGeneralPage extends StatelessWidget {
  const NotificationGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedNotificationView>(
      vm: () => SelectedNotificationFactory(),
      builder: (context, vm) {
        final notification = vm.selected;
        void update(NotificationModel changed) =>
            context.dispatch(UpdateNotificationAction(changed));
        return PropertyGrid(
          properties: [
            TextProperty(
              label: context.l10n.card_material,
              value: notification.material ?? emptyString,
              hintText: defaultMaterial,
              validator: (value) {
                if (value == null) return null;
                if (!minecraftPattern.hasMatch(value)) {
                  return context.l10n.input_validation_material;
                }
                return null;
              },
              onChanged: (value) =>
                  update(notification.copyWith(material: value)),
            ),
            TextProperty(
              label: context.l10n.card_title,
              value: notification.title ?? emptyString,
              onChanged: (value) => update(notification.copyWith(title: value)),
            ),
            ChoiceProperty<FrameType>(
              label: context.l10n.card_frame_type,
              help: context.l10n.help_notification_frame_type,
              value: notification.frameType,
              options: FrameType.values,
              display: (type) => type.displayName,
              onChanged: (type) =>
                  update(notification.copyWith(frameType: type)),
            ),
          ],
        );
      },
    );
  }
}
