class TaskFilter {
  bool hideCompleted;
  String? search;
  int pagina;
  bool sortDescending;

  TaskFilter({
    this.hideCompleted = false,
    this.search = '',
    this.pagina = 1,
    this.sortDescending = true,
  });

  List<dynamic> toArgs() {
    return [hideCompleted, search, pagina,sortDescending];
  }
}