enum ViewMode {
  map,
  list;

  String label() => switch (this) {
        ViewMode.map => 'Carte',
        ViewMode.list => 'Liste',
      };
}
