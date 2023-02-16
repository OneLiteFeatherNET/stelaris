import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/dialogs/abort_add_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/delete_dialog.dart';
import 'package:stelaris_ui/feature/dialogs/item_flag_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class FontMetaPage extends StatefulWidget {

  final FontModel model;
  final ValueNotifier<FontModel?> selectedItem;

  const FontMetaPage({Key? key, required this.model, required this.selectedItem}) : super(key: key);

  @override
  State<FontMetaPage> createState() => _FontMetaPageState();
}

class _FontMetaPageState extends State<FontMetaPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Wrap(
            clipBehavior: Clip.hardEdge,
            children: [
              ExpandableDataCard(
                title: const Text("Chars"),
                buttonClick: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EntryAddDialog(
                          title: Text(context.l10n.dialog_char_title, textAlign: TextAlign.center,),
                          forceClose: true,
                          controller: TextEditingController(),
                          formFieldValidator: (value) {
                            String input = value as String;

                            if (input.trim().isEmpty) {
                              return context.l10n.error_card_empty;
                            }

                            if (!input.startsWith("\\u")) {
                              return context.l10n.error_not_unicode_start;
                            }

                            if (input.length > 6) {
                              return context.l10n.error_not_unicode;
                            }
                            return null;
                          },
                          valueUpdate: (value) {
                            if (widget.model.chars != null) {
                              showDialog(context: context, builder: (BuildContext context) {
                                return AbortAddDialog(
                                  title: context.l10n.dialog_abort_chars_add,
                                  content: '${context.l10n.dialog_abort_chars_text} $value',
                                );
                              });
                              return;
                            }
                            final oldEntry = widget.model;
                            List<String> chars = List.of(oldEntry.chars ?? []);
                            chars.add(value);
                            final newEntry = oldEntry.copyWith(chars: chars);
                            setState(() {
                              StoreProvider.dispatch(
                                  context, UpdateFontAction(oldEntry, newEntry));
                              widget.selectedItem.value = newEntry;
                            });
                          },
                      );
                    },
                  );
                },
                widgets: List<Widget>.generate(
                  widget.model.chars?.length ?? 0,
                      (index) {
                    final key = widget.model.chars![index];
                    return ListTile(
                      title: Text(key),
                      trailing: IconButton(
                        icon: deleteIcon,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return DeleteDialog<String>(
                                  title: Text(context.l10n.dialog_delete_confirm),
                                  header: [
                                    TextSpan(
                                        text:
                                        context.l10n.delete_dialog_first_line,
                                        style: whiteStyle
                                    ),
                                    TextSpan(
                                        text: key,
                                        style: redStyle
                                    ),
                                    TextSpan(
                                        text: context.l10n.delete_dialog_entry,
                                        style: whiteStyle
                                    ),
                                  ],
                                  value: key,
                                  successfully: (value) {
                                    final oldEntry = widget.model;
                                    List<String> chars = List.of(
                                        widget.model.chars ?? []);
                                    chars.remove(key);
                                    final newEntry = oldEntry.copyWith(
                                        chars: chars);
                                    setState(() {
                                      StoreProvider.dispatch(context,
                                          UpdateFontAction(oldEntry, newEntry));
                                      widget.selectedItem.value = newEntry;
                                    });
                                    return true;
                                  }
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SaveButton(
          callback: () {
            ApiService().fontAPI.update(widget.model);
          },
        )
      ],
    );
  }
}
