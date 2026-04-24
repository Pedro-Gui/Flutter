import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatelessWidget {
  final String playlistName;
  const PlaylistPage({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlaylistProvider>(context, listen: false).loadPlaylistByName(playlistName);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: Text(
          playlistName.toUpperCase(),
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
          if (value.playlist.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: value.playlist.length,
            itemBuilder: (context, index) {
              final song = value.playlist[index];
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(song.albumArtImagePath),
                  ),
                  title: Text(song.songName, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  subtitle: Text(song.artistName, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  onTap: () { 
                    value.currentSongIndeX = index;
                    Navigator.pushNamed(context, '/player');
                   },
                ),
              );
            },
          );
        },
      ),
    );
  }
}