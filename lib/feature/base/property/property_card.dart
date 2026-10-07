import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_dialogs.dart';
import 'package:stelaris/feature/model/model_card_actions.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Shows a [Property]'s name and value; a click (or enter and space when
/// focused) opens its dialog. Looks like the cards of the components tab,
/// the name on top and the value at the bottom. Like a model card it shows
/// that it is clickable by its hover and cursor alone. A property with
/// [Property.help] gets an info button that shows the help in a dialog.
class PropertyCard extends StatelessWidget {
  const PropertyCard({required this.property, super.key});

  /// A component card's grid slot (112) minus the card's margin; larger
  /// text makes the card grow past it.
  static const double _minHeight = 104;

  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final help = property.help;
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => property.edit(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            // Less on the right with the button, like a component card.
            padding: EdgeInsets.fromLTRB(16, 12, help == null ? 16 : 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Spreads the texts over the minimum height, like the
              // Spacer of a component card.
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (help != null)
                      ModelCardActions(
                        color: colorScheme.onSurfaceVariant,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.info_outline_rounded,
                              semanticLabel: context.l10n.menu_item_info,
                            ),
                            onPressed: () =>
                                showPropertyInfoDialog(context, property),
                          ),
                        ],
                      ),
                  ],
                ),
                Text(
                  property.displayValue,
                  style: property.showsPlaceholder
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )
                      : theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
