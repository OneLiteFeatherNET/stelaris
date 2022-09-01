enum ItemFlag {
  enchantment("Enchantment", "HIDE_ENCHANTMENT"),
  attributes("Attributes", "HIDE_ATTRIBUTES"),
  unbreakable("Unbreakable", "HIDE_UNBREAKABLE"),
  destroys("Destroys", "HIDE_DESTROYS"),
  placedOn("PlacedOn", "HIDE_PLACED_ON"),
  potions("PotionEffects", "HIDE_POTION_EFFECTS"),
  dye("Dye", "HIDE_DYE");

  final String display;
  final String minestomValue;

  const ItemFlag(this.display, this.minestomValue);
}