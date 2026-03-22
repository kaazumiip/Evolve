import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/interest_model.dart';

class SubjectSelectionScreen extends StatefulWidget {
  final List<Interest> validInterests;

  const SubjectSelectionScreen({
    Key? key,
    required this.validInterests,
  }) : super(key: key);

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  
  // List of all available sub-interests based on selected main interests
  late List<SubInterest> subjects;
  
  // Set of selected SubInterest IDs
  final Set<int> selectedSubjectIds = {};

  @override
  void initState() {
    super.initState();
    _populateSubjects();
  }

  void _populateSubjects() {
    subjects = [];
    for (var interest in widget.validInterests) {
      subjects.addAll(interest.subs);
    }
  }

  Future<void> _handleNext() async {
    setState(() { _isLoading = true; });

    try {
      // Re-save main interests (optional, but ensures consistency) and save sub-interests
      // Since API design allows saving both, but our UI flow split them. 
      // Ideally we passed IDs here. We can re-extract interest IDs from widget.validInterests
      List<int> interestIds = widget.validInterests.map((i) => i.id).toList();
      
      await _authService.saveInterests(interestIds, selectedSubjectIds.toList());

      if (mounted) {
         Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save subjects: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey;
    final accentColor = const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Title section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'More ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            TextSpan(
                              text: 'Specific',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose 1 or 2 subject that seem interesting',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Subject chips
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: subjects.map((subject) {
                        return SubjectChip(
                          label: subject.name,
                          isSelected: selectedSubjectIds.contains(subject.id),
                          onTap: () {
                            setState(() {
                              if (selectedSubjectIds.contains(subject.id)) {
                                selectedSubjectIds.remove(subject.id);
                              } else {
                                if (selectedSubjectIds.length < 2) {
                                  selectedSubjectIds.add(subject.id);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                // Next button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _handleNext,
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SubjectChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SubjectChip> createState() => _SubjectChipState();
}

class _SubjectChipState extends State<SubjectChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SubjectChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward().then((_) => _controller.reverse());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = const Color(0xFF6366F1);

    return AnimatedScale(
      scale: widget.isSelected ? 1.15 : 1.0,
      curve: Curves.elasticOut,
      duration: const Duration(milliseconds: 500),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? accentColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(25),
          border: isDark && !widget.isSelected ? Border.all(color: Colors.white10) : null,
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: widget.onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                  ),
                  child: Text(widget.label),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.green, // Green background for tick
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
