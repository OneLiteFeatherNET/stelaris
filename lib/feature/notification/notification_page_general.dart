import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/dropdown_card.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class NotificationGeneralPage extends StatelessWidget {
  final NotificationModel model;

  NotificationGeneralPage({
    required this.model,
    super.key,
  });

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Form(
            key: _key,
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(
              spacing: 10,
              clipBehavior: Clip.hardEdge,
              children: [
                TextInputCard<String>(
                  display: context.l10n.card_name,
                  currentValue: model.name ?? emptyString,
                  formatter: [FilteringTextInputFormatter.allow(stringPattern)],
                  valueUpdate: (value) {
                    if (value == model.name) return;
                    final oldModel = model;
                    final newEntry = oldModel.copyWith(name: value);
                    StoreProvider.dispatch(
                      context,
                      UpdateNotificationAction(
                        newEntry,
                      ),
                    );
                  },
                  formValidator: (value) {
                    if (value.trim().isEmpty) {
                      return context.l10n.error_card_empty;
                    }
                    return null;
                  },
                ),
                TextInputCard<String>(
                  display: context.l10n.card_material,
                  currentValue: model.material ?? emptyString,
                  hintText: defaultMaterial,
                  valueUpdate: (value) {
                    if (value == model.material) return;
                    final oldModel = model;
                    final newEntry = oldModel.copyWith(material: value);
                    context.dispatch(UpdateNotificationAction(newEntry));
                  },
                  formValidator: (value) {
                    if (value == null) return null;
                    if (!minecraftPattern.hasMatch(value)) {
                      return context.l10n.input_validation_material;
                    }
                    return null;
                  },
                  maxLength: 30,
                ),
                TextInputCard<String>(
                  display: context.l10n.card_title,
                  currentValue: model.title ?? emptyString,
                  valueUpdate: (value) {
                    if (value == model.title) return;
                    final oldModel = model;
                    final newEntry = oldModel.copyWith(title: value);
                    context.dispatch(UpdateNotificationAction(newEntry));
                  },
                ),
                TextInputCard<String>(
                  display: context.l10n.card_description,
                  currentValue: model.description ?? emptyString,
                  valueUpdate: (value) {
                    if (value == model.description) return;
                    final oldModel = model;
                    final newEntry = oldModel.copyWith(description: value);
                    context.dispatch(UpdateNotificationAction(newEntry));
                  },
                ),
                DropdownCard<FrameType, NotificationModel>(
                  currentValue: model,
                  display: context.l10n.card_frame_type,
                  items: getItems(),
                  valueUpdate: (FrameType? value) {
                    if (value == model.frameType) return;
                    final newEntry = model.copyWith(frameType: value!);
                    context.dispatch(UpdateNotificationAction(newEntry));
                  },
                  defaultValue: (value) => value.frameType,
                ),
              ],
            ),
          ),
          SaveButton(
            callback: () {
              if (!_key.currentState!.validate()) return;
              ApiService().notificationAPI.update(model);
            },
          ),
        ],
      ),
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
}
