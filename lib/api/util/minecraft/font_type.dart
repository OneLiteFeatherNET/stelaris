enum FontType {
  bitmap("BitMap"),
  legacyUnicode("Legacy Unicode"),
  ttf("TrueType | OpenType");

  final String name;

  const FontType(this.name);
}