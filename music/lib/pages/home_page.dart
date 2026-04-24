import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: Text(
          'PLAYLIST',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          if (value.options.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: value.options.length,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child:Image.asset(value.options[index].imagePath) ),
                title: Text(value.options[index].artistName, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                onTap: () {
                  Navigator.pushNamed(context, '/playlist', arguments: value.options[index].artistName);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
