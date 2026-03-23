import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../models/interest_model.dart';
import 'subject_selection_screen.dart';

class InterestPickerScreen extends StatefulWidget {
  final bool isUpdating; 
  const InterestPickerScreen({super.key, this.isUpdating = false});

  @override
  State<InterestPickerScreen> createState() => _InterestPickerScreenState();
}

class _InterestPickerScreenState extends State<InterestPickerScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  List<Interest> interests = [];
  final List<int> _selectedInterests = [];
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isFetching = true;
  
  // Profile Update specific state
  int _updateStep = 0;
  final Set<int> _selectedSubInterests = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96); 
    _fetchInterests();
  }

  Future<void> _fetchInterests() async {
    try {
      final rawData = await _authService.getInterests();
      setState(() {
        interests = rawData.map((data) => Interest.fromJson(data)).toList();
        _isFetching = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() { _isFetching = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load interests: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleInterest(int id) {
    setState(() {
      if (_selectedInterests.contains(id)) {
        _selectedInterests.remove(id);
      } else if (_selectedInterests.length < 2) {
        _selectedInterests.add(id);
      }
    });
  }

  Future<void> _handleNext() async {
    if (widget.isUpdating) {
      if (_updateStep == 0) {
        // Validation for Step 1
        if (_selectedInterests.isEmpty) return;
        setState(() {
          _updateStep = 1;
        });
        return;
      } else {
        // Step 2: Final Save
        setState(() { _isLoading = true; });
        try {
          // Save both main and sub interests
          await _authService.saveInterests(
            _selectedInterests, 
            _selectedSubInterests.toList()
          );
          
          if (mounted) {
            Navigator.pop(context, true); 
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save interests: ${e.toString()}')),
            );
          }
        } finally {
          if (mounted) {
            setState(() { _isLoading = false; });
          }
        }
        return;
      }
    }
  
    // Original Onboarding Logic
    setState(() {
      _isLoading = true;
    });

    try {
      // First save the main interests
      await _authService.saveInterests(_selectedInterests);
      
      if (mounted) {
          // Pass the full interest objects needed for the next screen to save a re-fetch
          final selectedInterestObjects = interests
              .where((i) => _selectedInterests.contains(i.id))
              .toList();
              
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectSelectionScreen(
                validInterests: selectedInterestObjects,
              ),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save interests: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getIconFromName(String name) {
    switch (name) {
      case 'memory': return Icons.memory;
      case 'business_center': return Icons.business_center;
      case 'medical_services': return Icons.medical_services;
      case 'school': return Icons.school;
      case 'handyman': return Icons.handyman;
      case 'volunteer_activism': return Icons.volunteer_activism;
      case 'palette': return Icons.palette;
      default: return Icons.help;
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      return Colors.blue;
    }
  }

  Widget _buildInterestList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: interests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final interest = interests[index];
        final isSelected = _selectedInterests.contains(interest.id);

        return GestureDetector(
          onTap: () => _toggleInterest(interest.id),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.white10 : Colors.grey.shade200),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconFromName(interest.iconName),
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interest.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        interest.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey.shade500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                   const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.check_circle, color: Color(0xFF6366F1), size: 24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      );
    }
    if (widget.isUpdating) {
      return _buildUpdateView();
    }
    return _buildSignupView();
  }

  Widget _buildUpdateView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F7FF);
    final titleColor = isDark ? Colors.white : const Color(0xFF1E3A8A);

    // Gather available subjects based on selected main interests
    List<SubInterest> availableSubs = [];
    if (_updateStep == 1) {
       availableSubs = interests
        .expand((i) => i.subs)
        .toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show blur
      body: Stack(
        children: [
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5), // Single source of dimming
              ),
            ),
          ),
          // Modal Content
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxHeight: 700),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap content
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       // Back Button for Step 2
                       if (_updateStep == 1)
                         IconButton(
                           icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                           onPressed: () => setState(() => _updateStep = 0),
                           padding: EdgeInsets.zero,
                           constraints: const BoxConstraints(),
                         )
                       else 
                         const SizedBox(width: 24), // Spacer for centering if needed

                       Text(
                         _updateStep == 0 ? 'Update Your Interests' : 'Select Specifics',
                         style: TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: titleColor,
                         ),
                       ),
                       
                       IconButton(
                         icon: const Icon(Icons.close, color: Colors.grey),
                         onPressed: () => Navigator.pop(context),
                         padding: EdgeInsets.zero,
                         constraints: const BoxConstraints(),
                       ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _updateStep == 0 
                        ? "Choose 1 or 2 categories that interest you most"
                        : "Pick a few specific topics you want to see",
                      style: GoogleFonts.raleway(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                   const SizedBox(height: 20),

                  // Content Area
                  Expanded(
                    child: _updateStep == 0 
                      ? _buildInterestList()
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: availableSubs.map((sub) {
                               return SubjectChip(
                                 label: sub.name, 
                                 isSelected: _selectedSubInterests.contains(sub.id),
                                 isBlueMode: true,
                                 onTap: () {
                                   setState(() {
                                     if (_selectedSubInterests.contains(sub.id)) {
                                       _selectedSubInterests.remove(sub.id);
                                     } else {
                                       if (_selectedSubInterests.length < 5) { // Arbitrary limit or none? Let's say 5
                                         _selectedSubInterests.add(sub.id);
                                       }
                                     }
                                   });
                                 }
                               );
                            }).toList(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Save/Next Button (Bottom Right aligned)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: (_updateStep == 0 && _selectedInterests.isEmpty) 
                          ? null 
                          : _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1), // Purple-Blue
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                      child: _isLoading 
                          ? const SizedBox(
                              height: 16, 
                              width: 16, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : Text(
                              _updateStep == 0 ? 'Next' : 'Save',
                              style: const TextStyle(
                                fontSize: 16,
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
    );
  }

  Widget _buildSignupView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF909090);
    final primaryAccent = const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background blobs (decorative)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primaryAccent.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 60, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.raleway(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            height: 1.1,
                          ),
                          children: [
                            const TextSpan(text: 'What is the '),
                            TextSpan(
                              text: 'categories',
                              style: GoogleFonts.raleway(
                                color: primaryAccent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const TextSpan(text: '\nthat you most\ninterested in?'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Choose 1 or 2 that you're interested in. Don't stress you can change later",
                        style: GoogleFonts.raleway(
                          color: subtitleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: interests.length,
                    itemBuilder: (context, index) {
                      final interest = interests[index];
                      final selectionIndex = _selectedInterests.indexOf(interest.id);
                      final isSelected = selectionIndex != -1;
                      
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                          } else {
                            value = index == _currentPage ? 1.0 : 0.7;
                          }
                          final curve = Curves.easeOut.transform(value);
                          final scale = 0.92 + (0.08 * curve);
                          
                          return Center(
                            child: Transform.scale(
                              scale: scale,
                              child: AspectRatio(
                                aspectRatio: 0.95,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 17),
                                  decoration: BoxDecoration(
                                    color: _getColorFromHex(interest.colorHex),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getColorFromHex(interest.colorHex).withOpacity(0.4 * curve),
                                        blurRadius: 20 * curve,
                                        offset: Offset(0, 10 * curve),
                                      ),
                                    ],
                                  ),
                                  child: child,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Material(
                          color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _toggleInterest(interest.id),
                                borderRadius: BorderRadius.circular(30),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 60.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _getIconFromName(interest.iconName),
                                              color: _getColorFromHex(interest.colorHex),
                                              size: 42, 
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                interest.title,
                                                style: GoogleFonts.raleway(
                                                  color: Colors.white,
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                interest.description,
                                                style: GoogleFonts.raleway(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 14,
                                                  height: 1.4,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 25,
                                        right: 25,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${selectionIndex + 1}',
                                              style: GoogleFonts.raleway(
                                                color: _getColorFromHex(interest.colorHex),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Indicators and Next button
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(interests.length, (index) => _buildDot(index, isDark, primaryAccent)),
                      ),
                      const SizedBox(height: 25),
                      // Next Button
                      Center(
                        child: GestureDetector(
                          onTap: _selectedInterests.isNotEmpty ? _handleNext : null,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _selectedInterests.isNotEmpty ? 1.0 : 0.5,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: primaryAccent,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryAccent.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 20 : 8, // Elongated active dot
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? accent 
            : (isDark ? Colors.white10 : const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
