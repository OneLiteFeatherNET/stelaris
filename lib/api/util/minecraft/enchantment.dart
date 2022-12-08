enum Enchantment {

  protection("Protection", 3, "minecraft:protection"),
  fireProtection("Fire Protection", 3, "minecraft:fire_protection"),
  featherFalling("Feather Falling", 3, "minecraft:feather_falling"),
  blastProtection("Blast Protection", 3, "minecraft:blast_protection"),
  projectTileProtection("Projectile Protection", 3, "minecraft:projectile_protection"),
  respiration("Respiration", 3, "minecraft:respiration"),
  aquaAffinity("Aqua Affinity", 3, "minecraft:aqua_affinity"),
  thorns("Thorns", 3, "minecraft:thorns"),
  depthStrider("Depth Strider", 3, "minecraft:depth_strider"),
  frostWalker("Frost Walker", 3, "minecraft:frost_walker"),
  bindingCurse("Binding Curse", 3, "minecraft:binding_curse"),
  soulSpeed("SoulSpeed", 3, "minecraft:soul_speed"),
  swiftSneak("Swift Sneak", 3, "minecraft:swift_sneak"),

  sharpness("Shaprness", 3, "minecraft:sharpness"),
  smite("Smite", 3, "minecraft:smite"),
  baneOfArthropods("Bane of Arthropods", 2, "minecraft:bane_of_arthropods"),
  knockback("Knockback", 3, "minecraft:knockback"),
  fireAspect("Fire Aspect", 3, "minecraft:fire_aspect"),
  looting("Looting", 3, "minecraft:looting"),

  sweeping("Sweeping", 3, "minecrraft:sweeping"),

  efficiency("Efficiency", 3, "minecraft:efficiency"),
  silkTouch("Silktouch", 3, "minecraft:silk_touch"),
  unbreaking("Unbreaking", 3, "minecraft:unbreaking"),
  fortune("Fortune", 3, "minecraft:fortune"),
  power("Power", 3, "minecraft:power"),
  punch("Punch", 3, "minecraft:punch"),
  flame("Flame", 3, "minecraft:flame"),

  infinity("Infinity", 3, "minecraft:infinity"),
  luckOfTheSea("Luck of the Sea", 3, "minecraft:luck_of_the_sea"),
  lure("Lure", 3, "minecraft:lure"),
  loyalty("Loyalty", 3, "minecraft:loyalty"),
  impaling("Impaling", 3, "minecraft:impaling"),
  riptide("Riptide", 3, "minecraft:riptide"),
  channeling("Channeling", 3, "minecraft:channeling"),
  multishot("Multishot", 3, "minecraft:multishot"),
  quickCharge("QuickCharge", 3, "minecraft:quick_charge"),
  piercing("Piercing", 3, "minecraft:piercing"),

  mending("Mending", 3, "minecraft:mending"),
  vanishCourse("VanishCurse", 3, "minecraft:vanishing_curse");

  final String display;
  final int maxLevel;
  final String minecraftValue;

  const Enchantment(this.display, this.maxLevel, this.minecraftValue);
}