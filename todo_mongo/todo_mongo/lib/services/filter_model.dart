class TaskFilter {
  bool hideCompleted;
  String? search;
  int pagina;

  TaskFilter({
    this.hideCompleted = false,
    this.search = '',
    this.pagina = 1,
  });

  List<dynamic> toArgs() {
    return [hideCompleted, search, pagina];
  }
}