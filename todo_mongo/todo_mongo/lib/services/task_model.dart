class Task {
  final String id;
  final String title;
  final String situacao;
  final String userId;
  final String ownerUsername;
  final bool privado;
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.situacao,
    required this.userId,
    required this.ownerUsername,
    required this.privado,
    this.createdAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      situacao: map['situacao'] ?? 'naoConcluido',
      userId: map['userId'] ?? '',
      ownerUsername: map['ownerUsername'] ?? '',
      privado: map['privado'] ?? false,
      createdAt: map['createdAt'] is DateTime ? map['createdAt']: DateTime.tryParse(map['createdAt'].toString()),
    );
  
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'situacao': situacao,
      'userId': userId,
      'ownerUsername': ownerUsername,
      'privado': privado,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toMapEdit() {
    return {
      'title': title,
      'situacao': situacao,
      'ownerUsername': ownerUsername,
      'privado': privado,
    };
  }

}