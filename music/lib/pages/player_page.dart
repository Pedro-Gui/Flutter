import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music/components/neu_box.dart';
import 'package:music/components/show_name_banner.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final playlist = value.playlist;
        if (playlist.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final currentSong = playlist[value.currentSongIndex!];
        if (currentSong.songName.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Appbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          value.pause();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                      Text(
                        currentSong.artistName.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),

                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.menu),
                      ),
                    ],
                  ),
                  //Song Image
                  const SizedBox(height: 75),
                  NeuBox(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(currentSong.albumArtImagePath),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 320, child: ShowNameBanner(name: currentSong.songName)),
                                    Text(
                                      currentSong.artistName,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.inverseSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.favorite, color: Colors.red),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  //controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              value.currentDuration
                                  .toString()
                                  .split('.')
                                  .first
                                  .substring(2),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.shuffle),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.repeat),
                            ),
                            Text(
                              value.totalDuration
                                  .toString()
                                  .split('.')
                                  .first
                                  .substring(2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                      ),
                    ),
                    child: Slider(
                      min: 0,
                      max: value.totalDuration.inSeconds.toDouble(),
                      value: value.currentDuration.inSeconds.toDouble(),
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey,
                      onChanged: (value) {},
                      onChangeEnd: (double double) {
                        value.seek(Duration(seconds: double.toInt()));
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: NeuBox(
                          child: IconButton(
                            onPressed: () {
                              value.playPreviousSong();
                            },
                            icon: Icon(Icons.skip_previous),
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        flex: 2,
                        child: NeuBox(
                          child: IconButton(
                            onPressed: () {
                              value.pauseOrResume();
                            },
                            icon: Icon(
                              value.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: NeuBox(
                          child: IconButton(
                            onPressed: () {
                              value.playNextSong();
                            },
                            icon: Icon(Icons.skip_next),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 75),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
