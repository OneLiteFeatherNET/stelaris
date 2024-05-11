enum BranchOption {
  release('Release'),
  snapshot('Snapshot');

  final String name;

  const BranchOption(this.name);
}