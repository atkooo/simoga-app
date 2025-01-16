import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class EducationContentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> konten;

  const EducationContentDetailScreen({Key? key, required this.konten})
      : super(key: key);

  @override
  _EducationContentDetailScreenState createState() =>
      _EducationContentDetailScreenState();
}

class _EducationContentDetailScreenState
    extends State<EducationContentDetailScreen> {
  VideoPlayerController? _videoController;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.konten['mime_type'] == 'video/mp4') {
      _videoController =
          VideoPlayerController.network(widget.konten['media_url'])
            ..initialize().then((_) {
              setState(() {});
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String judul = widget.konten['judul'] ?? 'Tanpa Judul';
    final String isiKonten =
        widget.konten['konten'] ?? 'Deskripsi tidak tersedia';
    final String mediaUrl = widget.konten['media_url'] ?? '';
    final String mimeType = widget.konten['mime_type'] ?? '';
    final String tanggalPosting = widget.konten['tanggal_posting'] ?? '';

    final String formattedDate = tanggalPosting.isNotEmpty
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(tanggalPosting))
        : 'Tanggal tidak tersedia';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                judul,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text(
                            'Diposting pada $formattedDate',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Deskripsi Konten",
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        isiKonten,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (mimeType.startsWith('image/'))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (mimeType == 'video/mp4' && _videoController != null)
                    _buildVideoPlayer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Video Konten",
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : Center(child: CircularProgressIndicator()),
            SizedBox(height: 8),
            VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.blueAccent,
                bufferedColor: Colors.lightBlue,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _videoController!.value.isPlaying
                          ? _videoController!.pause()
                          : _videoController!.play();
                    });
                  },
                  icon: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _videoController!.seekTo(Duration.zero);
                    });
                  },
                  icon: Icon(Icons.stop, color: Colors.blueAccent),
                ),
                Text(
                  "${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}",
                  style: GoogleFonts.lato(color: Colors.grey[600]),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.volume_up, color: Colors.blueAccent),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                        _videoController!.setVolume(_volume);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
