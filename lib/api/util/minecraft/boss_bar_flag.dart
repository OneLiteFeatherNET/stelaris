enum BossBarFlag {
  dark('darken_screen'),
  music('play_boss_music'),
  worldFog('create_world_fog');

  final String name;

  const BossBarFlag(this.name);
}