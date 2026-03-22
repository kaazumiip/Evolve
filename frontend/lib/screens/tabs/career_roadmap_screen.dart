import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pricing_screen.dart';
import '../../generated/l10n/app_localizations.dart';


class CareerRoadmapScreen extends StatefulWidget {
  final String careerTitle;
  final int initialTabIndex;

  const CareerRoadmapScreen({
    super.key, 
    required this.careerTitle,
    this.initialTabIndex = 0,
  });

  @override
  State<CareerRoadmapScreen> createState() => _CareerRoadmapScreenState();
}


class _CareerRoadmapScreenState extends State<CareerRoadmapScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
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

  bool _isTabLocked(int index) {
    if (index == 0) return false; // Overview is always free
    final plan = ApiService.currentGlobalSubscription.toLowerCase();
    // Decisions Pack or Premium/Elite accounts unlock everything
    return !(plan.contains('premium') || plan.contains('elite') || plan.contains('decision') || plan.contains('pack'));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded, color: textColor),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue(context))))
          : _data == null
              ? const Center(child: Text('Failed to load roadmap'))
              : _buildMainContent(isDark, textColor, secondaryTextColor),
    );
  }

  Widget _buildMainContent(bool isDark, Color textColor, Color secondaryTextColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data?['career_title'] ?? widget.careerTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _data?['subtitle'] ?? AppLocalizations.of(context)!.appTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Hero Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                _data?['hero_image'] ?? 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: kPrimaryBlue(context).withOpacity(0.1),
                  child: Icon(Icons.image, color: kPrimaryBlue(context)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Custom Tab Bar
          _buildTabBar(isDark),

          const SizedBox(height: 20),

          // Tab Content with Paywall
          _isTabLocked(_tabController.index)
            ? _buildLockedOverlay(isDark, textColor)
            : IndexedStack(
                index: _tabController.index,
                children: [
                  _buildOverviewTab(isDark, textColor, secondaryTextColor),
                  _buildResourceTab(isDark, textColor, secondaryTextColor),
                  _buildCompaniesTab(isDark, textColor, secondaryTextColor),
                ],
              ),

          // Bottom Spacing (40px gap as requested)
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildLockedOverlay(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kPrimaryBlue(context).withOpacity(0.2)),
      ),
      child: Column(
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
            'Premium Feature', // I should localize this too
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          Text(
            'Requirements, Resources, and Top Companies are available for Decision Pack & Premium members.',
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
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        isScrollable: true,
        indicator: BoxDecoration(
          color: kPrimaryBlue(context),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
        labelPadding: const EdgeInsets.symmetric(horizontal: 24),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(text: AppLocalizations.of(context)!.explore),
          const Tab(text: 'Resources'), // Add to ARB if needed
          const Tab(text: 'Top Companies'),
        ],

      ),
    );
  }

  Widget _buildOverviewTab(bool isDark, Color textColor, Color secondaryTextColor) {
    final overview = _data?['overview'] ?? {};
    final dayInLife = List<String>.from(overview['day_in_life'] ?? []);
    final progression = List<dynamic>.from(overview['career_progression'] ?? []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: AppLocalizations.of(context)!.normalDayTitle,
            isDark: isDark,
            child: Column(
              children: dayInLife.asMap().entries.map((entry) {
                return _buildCircleListTile(entry.key + 1, entry.value, isDark);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: AppLocalizations.of(context)!.developmentTitle,
            isDark: isDark,
            child: Column(
              children: progression.asMap().entries.map((entry) {
                final role = entry.value;
                return _buildProgressionTile(
                  entry.key + 1,
                  role['role'] ?? '',
                  role['description'] ?? '',
                  role['salary'] ?? '',
                  isDark,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementTab(bool isDark, Color textColor, Color secondaryTextColor) {
    final reqs = _data?['requirements'] ?? {};
    final technical = List<String>.from(reqs['technical_skills'] ?? []);
    final soft = List<String>.from(reqs['soft_skills'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Learning Path (1, 2, 3...)',
            isDark: isDark,
            child: Column(
              children: technical.asMap().entries.map((entry) {
                return _buildCircleListTile(entry.key + 1, entry.value, isDark);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Professional Foundations',
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequirementItem(Icons.school_rounded, 'Education', reqs['education'] ?? 'Degree in related field', isDark),
                const SizedBox(height: 20),
                _buildRequirementItem(Icons.work_outline_rounded, 'Experience', reqs['experience'] ?? 'Entry level possible', isDark),
                const SizedBox(height: 20),
                _buildRequirementItem(Icons.psychology_rounded, 'Soft Skills', soft.isNotEmpty ? soft.join(', ') : 'Teamwork, Communication', isDark),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildResourceTab(bool isDark, Color textColor, Color secondaryTextColor) {
    final resources = List<dynamic>.from(_data?['resources'] ?? []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: _buildSectionCard(
        title: 'Learning Resources',
        isDark: isDark,
        child: Column(
          children: resources.map((res) {
            bool isLast = resources.last == res;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: _buildResourceTile(res, isDark),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCompaniesTab(bool isDark, Color textColor, Color secondaryTextColor) {
    final companies = List<dynamic>.from(_data?['top_companies'] ?? []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: _buildSectionCard(
        title: 'Top Hiring Companies',
        isDark: isDark,
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.70,
          ),
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final company = companies[index];
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
                  ),
                  child: _buildCompanyLogo(company['name'], company['logo_url'], isDark),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    company['name'],
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildSectionCard({required String title, required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildCircleListTile(int index, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: kPrimaryBlue(context).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.outfit(
                  color: kPrimaryBlue(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionTile(int index, String role, String desc, String salary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kPrimaryBlue(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(role, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                    Text(salary, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: kPrimaryBlue(context), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.outfit(color: isDark ? Colors.white54 : Colors.grey, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(IconData icon, String title, String? desc, bool isDark, {Widget? child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kPrimaryBlue(context), size: 28),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              if (desc != null)
                Text(desc, style: GoogleFonts.outfit(color: isDark ? Colors.white54 : Colors.grey, height: 1.5, fontSize: 14)),
              if (child != null) child,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillTag(String skill, bool isDark, bool isTechnical) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isTechnical 
            ? kPrimaryBlue(context).withOpacity(0.12)
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill,
        style: GoogleFonts.outfit(
          color: isTechnical ? kPrimaryBlue(context) : (isDark ? Colors.white70 : Colors.black54),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildResourceTile(dynamic res, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(res['name'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryBlue(context))),
              Text(res['type'] ?? '', style: GoogleFonts.outfit(color: isDark ? Colors.white54 : Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.open_in_new_rounded, size: 20, color: isDark ? Colors.white54 : Colors.black54),
          onPressed: () {
            final url = res['link'];
            if (url != null) launchUrl(Uri.parse(url));
          },
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: res['badge'] == 'Free' ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            res['badge'] ?? 'Free',
            style: GoogleFonts.outfit(
              color: res['badge'] == 'Free' ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyLogo(String name, String? logoUrl, bool isDark) {
    if (logoUrl != null && logoUrl.startsWith('http')) {
      return Image.network(
        logoUrl,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _fallbackCompanyIcon(name),
      );
    }
    return _fallbackCompanyIcon(name);
  }

  Widget _fallbackCompanyIcon(String name) {
    IconData icon = Icons.business_rounded;
    if (name.toLowerCase().contains('google')) icon = Icons.g_mobiledata_rounded;
    if (name.toLowerCase().contains('microsoft')) icon = Icons.window_rounded;
    if (name.toLowerCase().contains('amazon')) icon = Icons.cloud_queue_rounded;
    if (name.toLowerCase().contains('meta') || name.toLowerCase().contains('facebook')) icon = Icons.all_inclusive_rounded;
    if (name.toLowerCase().contains('netflix')) icon = Icons.movie_outlined;
    if (name.toLowerCase().contains('uber')) icon = Icons.car_rental_rounded;
    
    return Icon(icon, color: kPrimaryBlue(context), size: 32);
  }
}
