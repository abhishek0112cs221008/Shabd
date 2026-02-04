import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/word_provider.dart';
import '../widgets/word_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;

  // Cache DateFormatters for performance
  static final DateFormat _headerDayFormat = DateFormat('EEEE, d');
  static final DateFormat _headerMonthFormat = DateFormat('MMMM');
  static final DateFormat _iconMonthFormat = DateFormat('MMM');
  static final DateFormat _iconDayFormat = DateFormat('d');
  static final DateFormat _fullDateFormat = DateFormat('MMMM d, y');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
    ); // Start at Today (Index 0)
    Future.microtask(
      () => Provider.of<WordProvider>(context, listen: false).loadWords(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider to show current data
    final provider = Provider.of<WordProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restored Header with Calendar Icon Style
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Align vertically
                      children: [
                        // Left Side: Text Header
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello,",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _headerDayFormat.format(
                                DateTime.now(),
                              ), // Static Today
                              style: GoogleFonts.poppins(
                                fontSize: 28, // Slightly smaller to fit width
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              _headerMonthFormat.format(
                                DateTime.now(),
                              ), // Static Today
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),

                        // Right Side: Calendar Icon Widget
                        GestureDetector(
                          onTap: () async {
                            final DateTime now = DateTime.now();
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: provider.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: now,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.redAccent,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              // Calculate index based on days difference from today
                              final difference = now.difference(picked).inDays;
                              if (difference >= 0) {
                                _pageController.animateToPage(
                                  difference,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              // Stacked vertically for the icon look
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _iconMonthFormat
                                      .format(provider.selectedDate)
                                      .toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE53935,
                                    ), // Red calendar top
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _iconDayFormat.format(
                                        provider.selectedDate,
                                      ),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expanded Vertical Feed
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      // Limit scroll to total words only (Today is 0)
                      itemCount: provider.words.isEmpty
                          ? 1
                          : provider.words.length,
                      controller: _pageController,
                      onPageChanged: (index) {
                        // Sync Date Logic
                        // Index 0 = Today (0 days ago), Index 1 = Yesterday (1 day ago)
                        final date = DateTime.now().subtract(
                          Duration(days: index),
                        );
                        Provider.of<WordProvider>(
                          context,
                          listen: false,
                        ).selectDate(date);
                      },
                      itemBuilder: (context, index) {
                        final date = DateTime.now().subtract(
                          Duration(days: index),
                        );
                        final word = provider.getWordForDate(date);

                        if (word != null) {
                          return WordCard(word: word);
                        } else {
                          return Center(
                            child: Text(
                              "No word found for\n${_fullDateFormat.format(date)}",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
