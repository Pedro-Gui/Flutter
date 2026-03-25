import 'package:isar/isar.dart';
//rodar esse comando para criar o aquivo .g.dart
//dart run build_runner build 
part 'note.g.dart';

@Collection()

class Note{
  Id id = Isar.autoIncrement;
  late String text;
}