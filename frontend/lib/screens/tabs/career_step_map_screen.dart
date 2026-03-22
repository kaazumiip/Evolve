import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'pricing_screen.dart';

class CareerStepMapScreen extends StatefulWidget {
  final String careerTitle;

  const CareerStepMapScreen({super.key, required this.careerTitle});

  @override
  State<CareerStepMapScreen> createState() => _CareerStepMapScreenState();
}

class _CareerStepMapScreenState extends State<CareerStepMapScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await _apiService.getCareerRoadmap(widget.careerTitle);
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  bool _isMapLocked() {
    final plan = ApiService.currentGlobalSubscription.toLowerCase();
    return !(plan.contains('premium') || plan.contains('elite') || plan.contains('decision') || plan.contains('pack'));
  }

  Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark 
      ? const Color(0xFF6366F1) 
      : const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.careerTitle} Map', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue(context))))
          : _data == null
              ? const Center(child: Text('Failed to load map'))
              : _isMapLocked() 
                  ? _buildLockedOverlay(isDark, textColor)
                  : _buildMapContent(isDark, textColor, secondaryTextColor),
    );
  }

  Widget _buildMapContent(bool isDark, Color textColor, Color secondaryTextColor) {
    final reqs = _data?['requirements'] ?? {};
    final steps = List<String>.from(reqs['technical_skills'] ?? []);
    final softSkills = List<String>.from(reqs['soft_skills'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Text(
              "Your Journey Map",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Follow this step-by-step guide to succeed dynamically in this field.",
              style: TextStyle(color: secondaryTextColor, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 35),
            
            // Timeline stepper
            ...steps.asMap().entries.map((entry) {
                int index = entry.key;
                String stepText = entry.value;
                bool isLast = index == steps.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: kPrimaryBlue(context).withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: kPrimaryBlue(context), width: 2)
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(color: kPrimaryBlue(context), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: kPrimaryBlue(context).withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                ),
                              ],
                              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
                            ),
                            child: Text(
                              stepText,
                              style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
            }),
            
            const SizedBox(height: 20),
            Text(
              "Professional Foundations",
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 20),
            
            _buildFoundationCard(
              Icons.school_rounded, 
              'Education', 
              reqs['education'] ?? 'Degree in related field', 
              isDark, 
              textColor
            ),
            const SizedBox(height: 15),
            _buildFoundationCard(
              Icons.work_outline_rounded, 
              'Experience', 
              reqs['experience'] ?? 'Entry level possible', 
              isDark, 
              textColor
            ),
            const SizedBox(height: 15),
            _buildFoundationCard(
              Icons.psychology_rounded, 
              'Soft Skills', 
              softSkills.isNotEmpty ? softSkills.join(', ') : 'Teamwork, Communication', 
              isDark, 
              textColor
            ),
            const SizedBox(height: 60),
         ],
      ),
    );
  }

  Widget _buildFoundationCard(IconData icon, String title, String description, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryBlue(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: kPrimaryBlue(context), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedOverlay(bool isDark, Color textColor) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2433) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: kPrimaryBlue(context).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryBlue(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline_rounded, color: kPrimaryBlue(context), size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Premium Feature',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            Text(
              'The step-by-step career path map is available for Decision Pack & Premium members.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 15, color: isDark ? Colors.white70 : Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Unlock with Decisions Pack', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
