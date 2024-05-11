enum FontType {
  bitmap('BitMap'),
  legacyUnicode('Legacy Unicode'),
  ttf('TrueType | OpenType');

  final String displayName;

  const FontType(this.displayName);
}