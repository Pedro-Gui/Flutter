import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_database.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final textController = TextEditingController();
  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  @override
  void initState() {
    super.initState();
    readNotes();
  }

  void createNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New note'),
        content: TextField(controller: textController),
        actions: [
          MaterialButton(
            onPressed: () {
              context.read<NoteDatabase>().addNote(textController.text);
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void updateNote(Note note) {
    textController.text = note.text;
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('Update note'),
        content: TextField(controller: textController),
        actions: [
          MaterialButton
          (onPressed: (){
            context.read<NoteDatabase>().updateNote(note.id, textController.text);
            textController.clear();
            Navigator.pop(context);
          },
          child: const Text('Update'),
          )
        ],
        
      ));
  }

  void deleteNote(int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    final noteDatabase = context.watch<NoteDatabase>();
    List<Note> currNotes = noteDatabase.currentNotes;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Notes', 
            style: GoogleFonts.dmSerifText(
              fontSize: 48,
             // fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            )
            ),
        )
          ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        onPressed: createNote,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: currNotes.length,
        itemBuilder: (context, index) {
          final note = currNotes[index];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.all(Radius.circular(12))
              ),
            margin: EdgeInsets.only(left: 20, right: 5, top: 15),
            padding: EdgeInsets.all(12),
            child: ListTile(
              title: Text(note.text),
              trailing: Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  IconButton(onPressed:() => updateNote(note), icon: Icon(Icons.edit)),
                  IconButton(onPressed:() => deleteNote(note.id), icon: Icon(Icons.delete)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
