enum Version {
    major("Major"),
    minor("Minor"),
    patch("Patch");

    final String display;

    const Version(this.display);
}