import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/dropdown_card.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class NotificationGeneralPage extends StatefulWidget {
  final NotificationModel model;
  final ValueNotifier<NotificationModel?> selectedItem;

  const NotificationGeneralPage(
      {Key? key, required this.model, required this.selectedItem})
      : super(key: key);

  @override
  State<NotificationGeneralPage> createState() =>
      _NotificationGeneralPageState();
}

class _NotificationGeneralPageState extends State<NotificationGeneralPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Wrap(
          children: [
            TextInputCard<String>(
                title: Text(context.l10n.card_name),
                infoText: context.l10n.tooltip_name,
                currentValue: widget.model.name ?? empty,
                valueUpdate: (value) {
                  if (value == widget.model.name) return;
                  final oldModel = widget.model;
                  final newEntry = oldModel.copyWith(name: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateNotificationAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                }),
            TextInputCard<String>(
                title: Text(context.l10n.card_material),
                currentValue: widget.model.material ?? empty,
                infoText: context.l10n.tooltip_material,
                valueUpdate: (value) {
                  if (value == widget.model.material) return;
                  final oldModel = widget.model;
                  final newEntry = oldModel.copyWith(material: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateNotificationAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                },
                validator: (value) {
                  if (value == null) return false;
                  return !value.startsWith("minecraft:");
                },
              errorMessage: "The material must begins with minecraft:",
            ),
            TextInputCard<String>(
                title: Text(context.l10n.card_title),
                currentValue: widget.model.title ?? empty,
                infoText: context.l10n.tooltip_title,
                valueUpdate: (value) {
                  if (value == widget.model.title) return;
                  final oldModel = widget.model;
                  final newEntry = oldModel.copyWith(title: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateNotificationAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                }),
            TextInputCard<String>(
                title: Text(context.l10n.card_description),
                currentValue: widget.model.description ?? empty,
                infoText: context.l10n.tooltip_description,
                valueUpdate: (value) {
                  if (value == widget.model.description) return;
                  final oldModel =widget.model;
                  final newEntry = oldModel.copyWith(description: value);
                  setState(() {
                    StoreProvider.dispatch(
                        context, UpdateNotificationAction(oldModel, newEntry));
                    widget.selectedItem.value = newEntry;
                  });
                }),
            DropDownCard<FrameType, NotificationModel>(
              currentValue: widget.model,
              title: Text(context.l10n.card_frame_type,
                  textAlign: TextAlign.center),
              items: getItems(),
              valueUpdate: (FrameType? value) {
                if (value == getDefaultValue(widget.model)) return;
                final newEntry = widget.model.copyWith(frameType: value?.value);
                setState(() {
                  StoreProvider.dispatch(
                      context, UpdateNotificationAction(widget.model, newEntry));
                  widget.selectedItem.value = newEntry;
                });
              },
              defaultValue: getDefaultValue,
            ),
          ],
        ),
        SaveButton(
          callback: () {
            ApiService().notificationAPI.update(widget.model);
          },
        ),
      ],
    );
  }

  List<DropdownMenuItem<FrameType>> getItems() {
    List<FrameType> values = FrameType.values;
    return List.generate(
        values.length,
        (index) => DropdownMenuItem(
              value: values[index],
              child: Text(values[index].value),
            ));
  }

  FrameType getDefaultValue(NotificationModel value) {
    return FrameType.values
        .firstWhere((element) => element.name == value.frameType);
  }
}
