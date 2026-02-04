import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/word_model.dart';

class WordCard extends StatefulWidget {
  final Word word;

  const WordCard({super.key, required this.word});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _captureAndShare() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // 1. Capture the widget
      RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        // Retry or handle error (sometimes context isn't ready)
        print("Boundary was null");
        return;
      }

      // Convert to image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // High quality
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/word_of_day.png');
      await file.writeAsBytes(pngBytes);

      // 3. Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out the Word of the Day from Shabd App! 🌟',
        subject: 'Word of the Day: ${widget.word.word}',
      );
    } catch (e) {
      print("Error sharing: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not share image")));
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  // Helper to get color theme based on day of week
  Map<String, Color> _getThemeColors(DateTime date) {
    // 1 = Monday, 7 = Sunday
    switch (date.weekday) {
      case 1: // Monday - Blue
        return {
          'bg': const Color(0xFF1565C0), // Blue 800
          'primary': Colors.white,
          'accent': const Color(0xFFBBDEFB), // Light Blue 100
          'border': const Color(0xFF1E88E5), // Blue 600
        };
      case 2: // Tuesday - Purple
        return {
          'bg': const Color(0xFF6A1B9A), // Purple 800
          'primary': Colors.white,
          'accent': const Color(0xFFE1BEE7), // Purple 100
          'border': const Color(0xFF8E24AA), // Purple 600
        };
      case 3: // Wednesday - Green
        return {
          'bg': const Color(0xFF2E7D32), // Green 800
          'primary': Colors.white,
          'accent': const Color(0xFFC8E6C9), // Green 100
          'border': const Color(0xFF43A047), // Green 600
        };
      case 4: // Thursday - Orange
        return {
          'bg': const Color(0xFFEF6C00), // Orange 800
          'primary': Colors.white,
          'accent': const Color(0xFFFFE0B2), // Orange 100
          'border': const Color(0xFFF57C00), // Orange 700
        };
      case 5: // Friday - Pink
        return {
          'bg': const Color(0xFFAD1457), // Pink 800
          'primary': Colors.white,
          'accent': const Color(0xFFF8BBD0), // Pink 100
          'border': const Color(0xFFD81B60), // Pink 600
        };
      case 6: // Saturday - Teal
        return {
          'bg': const Color(0xFF00695C), // Teal 800
          'primary': Colors.white,
          'accent': const Color(0xFFB2DFDB), // Teal 100
          'border': const Color(0xFF00897B), // Teal 600
        };
      case 7: // Sunday - Amber
        return {
          'bg': const Color(0xFFFF8F00), // Amber 800
          'primary': Colors.white,
          'accent': const Color(0xFFFFECB3), // Amber 100
          'border': const Color(0xFFFFB300), // Amber 600
        };
      default:
        return {
          'bg': const Color(0xFF212121), // Grey 900
          'primary': Colors.white,
          'accent': Colors.grey,
          'border': Colors.grey.shade700,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getThemeColors(widget.word.date);
    final bgColor = theme['bg']!;
    final primaryColor = theme['primary']!;
    final accentColor = theme['accent']!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. The Captured Card Content (Wrapped in RepaintBoundary)
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              // We duplicate decoration here for the capture to have background
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "WORD OF THE DAY",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const Spacer(flex: 2),
                  Text(
                    widget.word.word,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.permanentMarker(
                      fontSize: 64,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    widget.word.definition,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kalam(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.word.partOfSpeech,
                        style: GoogleFonts.kalam(
                          fontSize: 18,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  Text(
                    widget.word.hindiMeaning,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kalam(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(flex: 3),

                  // Branding Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Shabd App",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Floating Action Bar (Right Side)
          Positioned(
            right: 16,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  icon: Icons.share,
                  label: "Share",
                  color: primaryColor,
                  onTap: _captureAndShare, // Use the capture logic
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.copy,
                  label: "Copy",
                  color: primaryColor,
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: '${widget.word.word} - ${widget.word.definition}',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Copied to clipboard!",
                          style: GoogleFonts.poppins(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.black87,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Loading Overlay for Sharing
          if (_isSharing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Glassy effect
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
