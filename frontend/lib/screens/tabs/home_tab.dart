import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../utils/interest_helper.dart';
import 'dart:convert';
import 'scholarship_screen.dart';
import 'scholarship_detail_screen.dart';
import '../../services/api_service.dart';
import 'career_roadmap_screen.dart';
import 'career_step_map_screen.dart';
import '../community/user_profile_screen.dart';
import '../user_search_screen.dart';
import 'pricing_screen.dart';
import '../../generated/l10n/app_localizations.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);
Color kStreakColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8B5CF6) : const Color(0xFFF97316);

class HomeTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeTab({super.key, required this.userData});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _careerController = PageController();
  final PageController _comparisonController = PageController();
  int _currentCareerPage = 0;
  int _currentComparisonPage = 0;
  List<int> _selectedIndices = [0, 1];

  // Dynamic Content Lists
  List<Map<String, dynamic>> careers = [];
  List<Map<String, dynamic>> comparisons = [];
  
  // Scholarship State
  final ApiService _apiService = ApiService();
  bool _isLoadingScholarships = true;
  // Career Comparison State
  Map<String, dynamic>? _careerComparisonData;
  bool _isComparingCareers = true;
  int _selectedComparisonIndex = 0;
  List<dynamic> _scoutedScholarships = [];
  Set<int> _favoritedScholarshipIds = {};

  @override
  void initState() {
    super.initState();
    _parseAndPopulate();
    _fetchScholarships();
  }

  Future<void> _fetchScholarships() async {
    if (mounted) {
      setState(() => _isLoadingScholarships = true);
    }
    final data = await _apiService.getScoutedScholarships();
    
    // Check favorite status for EACH scouted scholarship
    Set<int> favs = {};
    for (var s in data) {
      if (s['id'] != null) {
        final isFav = await _apiService.checkFavorite('scholarship', s['id']);
        if (isFav) favs.add(s['id']);
      }
    }

    if (mounted) {
      setState(() {
        _scoutedScholarships = data;
        _favoritedScholarshipIds = favs;
        _isLoadingScholarships = false;
      });
    }
  }

  @override
  void didUpdateWidget(HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userData != oldWidget.userData) {
      _parseAndPopulate();
    }
  }
  
  void _parseAndPopulate() {
      // New format: interestIds is explicitly a List<int> (or dynamic list of ints)
      // Old format (fallback): interests string
      
      List<int> interestIds = [];
      // print("HomeTab userData: ${widget.userData}");
      
      if (widget.userData['interestIds'] != null) {
        interestIds = List<int>.from(widget.userData['interestIds']);
      } else {
         // Fallback legacy parsing just in case
         var interestsData = widget.userData['interests'];
         if (interestsData is List) {
           interestIds = interestsData.cast<int>();
         } else if (interestsData is String) {
            try {
              final List<dynamic> parsed = jsonDecode(interestsData);
              interestIds = parsed.cast<int>();
            } catch (e) {
              print('Error parsing interests string: $e');
            }
         }
      }
      
      if (interestIds.isEmpty) interestIds = [1, 7]; // Fallback to avoid empty screen
      _populateContent(interestIds);
      _fetchCareerComparison(interestIds);
  }

  Future<void> _fetchCareerComparison(List<int> interestIds) async {
    if (!mounted) return;
    
    // Check for Premium subscription
    final plan = ApiService.currentGlobalSubscription.toLowerCase();
    final bool isPremium = plan.contains('premium') || plan.contains('elite') || plan.contains('focused');
    
    if (!isPremium) {
      if (mounted) {
        setState(() {
          _isComparingCareers = false;
        });
      }
      return;
    }

    setState(() => _isComparingCareers = true);
    
    final data = await _apiService.getCareerComparison(interestIds);
    if (mounted) {
      setState(() {
        _careerComparisonData = data;
        _isComparingCareers = false;
      });
    }
  }

  void _populateContent(List<int> interestIds) {
    careers = [];
    comparisons = [];

    for (int id in interestIds) {
      switch (id) {
        case 1: // STEM
          careers.add({
            'title': 'Software Developer',
            'match': '95%',
            'color': Colors.purple.shade100,
            'icon': Icons.code,
            'image': 'https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=400',
          });
          careers.add({
             'title': 'Data Scientist',
             'match': '93%',
             'color': Colors.indigo.shade100,
             'icon': Icons.analytics,
             'image': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
           });
           careers.add({
             'title': 'Biomedical Engineer',
             'match': '90%',
             'color': Colors.teal.shade100,
             'icon': Icons.biotech,
             'image': 'https://images.unsplash.com/photo-1581093458791-9f302e6831f7?w=400',
           });
          comparisons.add({
            'title': 'STEM',
            'icon': Icons.memory,
            'color': Colors.blue,
            'stats': {
              'growth': '8.4%',
              'salary': '4.2M',
              'demand': '85%',
            }
          });
          break;
        case 2: // Business
          careers.add({
            'title': 'Marketing Manager',
            'match': '88%',
            'color': Colors.green.shade100,
            'icon': Icons.trending_up,
            'image': 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=400',
          });
           careers.add({
             'title': 'Financial Analyst',
             'match': '92%',
             'color': Colors.cyan.shade100,
             'icon': Icons.attach_money,
             'image': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
           });
           careers.add({
             'title': 'Entrepreneur',
             'match': '96%',
             'color': Colors.amber.shade100,
             'icon': Icons.lightbulb,
             'image': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400',
           });
           comparisons.add({
            'title': 'Business',
            'icon': Icons.business_center,
            'color': Colors.orange,
            'stats': {
              'growth': '15.3%',
              'salary': '2.8M',
              'demand': '93%',
            }
          });
          break;
        case 3: // Health
          careers.add({
            'title': 'Registered Nurse',
            'match': '92%',
            'color': Colors.red.shade100,
            'icon': Icons.medical_services,
            'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400',
          });
          careers.add({
             'title': 'Physical Therapist',
             'match': '89%',
             'color': Colors.pink.shade100,
             'icon': Icons.accessibility,
             'image': 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=400',
           });
           careers.add({
             'title': 'Health Administrator',
             'match': '86%',
             'color': Colors.blueGrey.shade100,
             'icon': Icons.admin_panel_settings,
             'image': 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400',
           });
           comparisons.add({
            'title': 'Health',
            'icon': Icons.medical_services,
            'color': Colors.red,
            'stats': {
              'growth': '12.0%',
              'salary': '3.5M',
              'demand': '90%',
            }
          });
          break;
        case 4: // Education
           careers.add({
            'title': 'High School Teacher',
            'match': '89%',
            'color': Colors.amber.shade100,
            'icon': Icons.school,
            'image': 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=400',
          });
          careers.add({
             'title': 'Instructional Designer',
             'match': '85%',
             'color': Colors.orange.shade100,
             'icon': Icons.design_services,
             'image': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400',
           });
           careers.add({
             'title': 'Education Consultant',
             'match': '91%',
             'color': Colors.deepOrange.shade100,
             'icon': Icons.cast_for_education,
             'image': 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=400',
           });
           comparisons.add({
            'title': 'Education',
            'icon': Icons.school,
            'color': Colors.amber,
            'stats': {
              'growth': '4.1%',
              'salary': '2.2M',
              'demand': '80%',
            }
          });
          break;
        case 5: // Craftmanship
           careers.add({
            'title': 'Senior Mechanic',
            'match': '82%',
            'color': Colors.brown.shade100,
            'icon': Icons.handyman,
            'image': 'https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=400',
          });
          careers.add({
             'title': 'Electrician',
             'match': '87%',
             'color': Colors.amber.shade100,
             'icon': Icons.electrical_services,
             'image': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
           });
           careers.add({
             'title': 'Carpenter',
             'match': '80%',
             'color': Colors.brown.shade200,
             'icon': Icons.construction,
             'image': 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400',
           });
           comparisons.add({
            'title': 'Crafts',
            'icon': Icons.handyman,
            'color': Colors.brown,
            'stats': {
              'growth': '3.0%',
              'salary': '2.0M',
              'demand': '70%',
            }
          });
          break;
        case 6: // Public Service
           careers.add({
            'title': 'Policy Analyst',
            'match': '90%',
            'color': Colors.indigo.shade100,
            'icon': Icons.volunteer_activism,
            'image': 'https://images.unsplash.com/photo-1541872703-74c5963631df?w=400',
          });
          careers.add({
             'title': 'Social Worker',
             'match': '88%',
             'color': Colors.lightBlue.shade100,
             'icon': Icons.people,
             'image': 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=400',
           });
           careers.add({
             'title': 'Urban Planner',
             'match': '84%',
             'color': Colors.green.shade100,
             'icon': Icons.location_city,
             'image': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400',
           });
           comparisons.add({
            'title': 'Service',
            'icon': Icons.volunteer_activism,
            'color': Colors.indigo,
            'stats': {
              'growth': '6.2%',
              'salary': '2.9M',
              'demand': '85%',
            }
          });
          break;
        case 7: // Arts
           careers.add({
            'title': 'UX Designer',
            'match': '85%',
            'color': Colors.pink.shade100,
            'icon': Icons.design_services,
            'image': 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400',
          });
          careers.add({
             'title': 'Graphic Designer',
             'match': '88%',
             'color': Colors.purple.shade100,
             'icon': Icons.brush,
             'image': 'https://images.unsplash.com/photo-1626785774573-4b799312c95d?w=400',
           });
           careers.add({
             'title': 'Art Director',
             'match': '94%',
             'color': Colors.deepPurple.shade100,
             'icon': Icons.movie_creation,
             'image': 'https://images.unsplash.com/photo-1542038784456-1ea0e93ca945?w=400',
           });
           comparisons.add({
            'title': 'Design',
            'icon': Icons.palette,
            'color': Colors.pink,
            'stats': {
              'growth': '5.5%',
              'salary': '3.0M',
              'demand': '75%',
            }
          });
          break;
        default:
           careers.add({
            'title': 'Project Manager',
            'match': '80%',
            'color': Colors.teal.shade100,
            'icon': Icons.assignment,
            'image': 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400',
          });
           comparisons.add({
            'title': 'General',
            'icon': Icons.work,
            'color': Colors.teal,
            'stats': {
              'growth': '4.0%',
              'salary': '2.5M',
              'demand': '60%',
            }
          });
      }
    }
    
    if (careers.isEmpty) {
       careers.add({
        'title': 'Career Explorer',
        'match': '??%',
        'color': Colors.grey.shade100,
        'icon': Icons.search,
        'image': 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400',
      });
    }
    while (comparisons.length < 2) {
      comparisons.add({
            'title': 'Other',
            'icon': Icons.help_outline,
            'color': const Color(0xFF2563EB),
            'stats': {'growth': 'N/A', 'salary': 'N/A', 'demand': 'N/A'}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.userData['name'] ?? 'User';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(AppLocalizations.of(context)!.welcomeBack,
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userName,
                        style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryBlue(context)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      
                      GestureDetector(
                        onTap: () {
                          final currentUserId = int.tryParse(widget.userData['id']?.toString() ?? '');
                          if (currentUserId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(
                                  userId: currentUserId,
                                  userName: userName,
                                  userImage: widget.userData['profile_picture'] ?? '',
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kPrimaryBlue(context).withOpacity(0.2), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: (widget.userData['profile_picture'] != null &&
                                    widget.userData['profile_picture'].toString().isNotEmpty)
                                ? NetworkImage(widget.userData['profile_picture'].toString())
                                : null,
                            child: (widget.userData['profile_picture'] == null ||
                                    widget.userData['profile_picture'].toString().isEmpty)
                                ? Text(
                                    userName.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryBlue(context),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            
            const SizedBox(height: 35),
            
            // Interest Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: comparisons.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> comp = entry.value;
                  bool isSelected = _selectedIndices.contains(idx);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!_selectedIndices.contains(idx)) {
                            _selectedIndices = [idx, _selectedIndices[0]];
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? kPrimaryBlue(context)
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          comp['title'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade600, 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 30),
            Text(AppLocalizations.of(context)!.yourInterestCategoriesNcomparison,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.exploreDetailedInsightsAboutYourSelectedFieldsAndDiscoverWhichPathAlignsBestWithYourGoals,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
            
            const SizedBox(height: 30),
            
            // VS Section
            if (!(['premium', 'elite', 'focused'].any((p) => ApiService.currentGlobalSubscription.toLowerCase().contains(p))))
               _buildPremiumLock(isDark)
            else if (_isComparingCareers)
              _buildComparisonSkeleton()
            else if (_careerComparisonData != null)
              _buildAiComparisonView(isDark)
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20), 
                  child: Text(AppLocalizations.of(context)!.failedToGenerateCareerComparison, style: const TextStyle(color: Colors.grey))
                )
              ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.careerPathBasedOnYourCategories,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context)!.seeAll, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB))),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Career PageView
             SizedBox(
               height: 220, 
               child: careers.isNotEmpty ? PageView.builder(
                 controller: _careerController,
                 onPageChanged: (index) {
                   setState(() => _currentCareerPage = index);
                 },
                 itemCount: careers.length,
                 itemBuilder: (context, index) {
                   final career = careers[index];
                   return Container(
                     margin: const EdgeInsets.only(right: 15),
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(20),
                       image: DecorationImage(
                         image: NetworkImage(career['image']),
                         fit: BoxFit.cover,
                       ),
                     ),
                     child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(20),
                         gradient: LinearGradient(
                           begin: Alignment.topCenter,
                           end: Alignment.bottomCenter,
                           colors: [
                             Colors.transparent,
                             Colors.black.withOpacity(0.8),
                           ],
                         ),
                       ),
                       padding: const EdgeInsets.all(20),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.end,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1BEE7), 
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.matchText,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              career['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => CareerRoadmapScreen(careerTitle: career['title'])),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryBlue(context),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(AppLocalizations.of(context)!.explorePath, style: const TextStyle(fontSize: 11)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CareerStepMapScreen(
      careerTitle: career['title'],
    ),
  ),
);
                                    },
                                    icon: const Icon(Icons.map, size: 14, color: Colors.black87),
                                    label: Text(AppLocalizations.of(context)!.mapText, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
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
                 },
               ) : const Center(child: Text("No career matches found")),
             ),

            const SizedBox(height: 30),
            
            // Streak
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                        Icon(
                          Icons.local_fire_department,
                          color: kStreakColor(context),
                          size: 28,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.streakDay,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: TweenAnimationBuilder<int>(
                                    tween: IntTween(begin: 0, end: widget.userData['current_streak'] ?? 0),
                                    duration: const Duration(seconds: 2),
                                    curve: Curves.easeOutExpo,
                                    builder: (context, value, child) {
                                      return Text(
                                        '$value',
                                        style: TextStyle(
                                          fontSize: 60,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryBlue(context),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${AppLocalizations.of(context)!.days}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.currentStreakBest(widget.userData['longest_streak'] ?? 0),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      AppLocalizations.of(context)!.goalDays(10),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: ((widget.userData['current_streak'] ?? 0) % 10) / 10),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey.shade200,
                            color: kPrimaryBlue(context),
                            minHeight: 8,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.thisWeek,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [AppLocalizations.of(context)!.mon, AppLocalizations.of(context)!.tue, AppLocalizations.of(context)!.wed, AppLocalizations.of(context)!.thu, AppLocalizations.of(context)!.fri, AppLocalizations.of(context)!.sat, AppLocalizations.of(context)!.sun]
                          .asMap()
                          .entries
                          .map((entry) {
                            int idx = entry.key; // 0=Mon, ... 6=Sun
                            String day = entry.value;
                            List<dynamic> weeklyLogins = widget.userData['this_week_logins'] ?? [];
                            bool isLoggedIn = weeklyLogins.contains(idx);

                            return Column(
                                children: [
                                  Text(
                                    day,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isLoggedIn 
                                          ? kStreakColor(context)
                                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                                      shape: BoxShape.circle,
                                    ),
                                    child: isLoggedIn 
                                        ? const Icon(
                                            Icons.local_fire_department,
                                            size: 18,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ],
                              );
                          })
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.streakMotivation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kPrimaryBlue(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Scholarships
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.scholarshipsForYou,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ScholarshipExplorerScreen()),
                    ).then((_) {
                      // Silently refresh the cache when returning from the explorer
                      _fetchScholarships();
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.showMore, style: TextStyle(color: kPrimaryBlue(context), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (_isLoadingScholarships)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_scoutedScholarships.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(AppLocalizations.of(context)!.noScholarshipsFound, style: const TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._scoutedScholarships.take(2).map((scholarship) => _buildScholarshipCard(scholarship, isDark)).toList(),

            const SizedBox(height: 120), // Bottom padding buffer
          ],
        ),
      ),
    );
  }
  
  // Helpers copied from HomeScreen
  Widget _buildVsCard(String title, IconData icon, bool highlight) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlight ? kPrimaryBlue(context) : Colors.grey.shade200,
            width: highlight ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Container(
               width: 60,
               height: 60,
               decoration: BoxDecoration(
                 color: highlight ? kPrimaryBlue(context).withOpacity(0.1) : Colors.grey.shade100,
                 shape: BoxShape.circle,
               ),
               child: Icon(
                 icon, 
                 size: 30, 
                 color: highlight ? kPrimaryBlue(context) : Colors.grey.shade600
               ),
             ),
             const SizedBox(height: 15),
             Text(
               title,
               style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold,
                 color: highlight ? Colors.black : Colors.grey.shade600,
               ),
             ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String val1, String val2, Color color1, Color color2) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: color1,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              val1,
              textAlign: TextAlign.center,
              style: TextStyle(color: kPrimaryBlue(context), fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: color2,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              val2,
              textAlign: TextAlign.center,
              style: TextStyle(color: kPrimaryBlue(context), fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
      }
      return kPrimaryBlue(context);
    } catch (e) {
      return kPrimaryBlue(context);
    }
  }

  void _toggleFavorite(Map<String, dynamic> s) async {
    final int? id = s['id'];
    if (id == null) return;

    final isCurrentlyFav = _favoritedScholarshipIds.contains(id);
    
    // Create custom notification overlay
    _showFavoritePopup(!isCurrentlyFav);

    setState(() {
      if (isCurrentlyFav) {
        _favoritedScholarshipIds.remove(id);
      } else {
        _favoritedScholarshipIds.add(id);
      }
    });

    final result = await _apiService.toggleFavorite('scholarship', id);
    if (mounted) {
      setState(() {
        if (result['isFavorited'] == true) {
          _favoritedScholarshipIds.add(id);
        } else {
          _favoritedScholarshipIds.remove(id);
        }
      });
    }
  }

  void _showFavoritePopup(bool added) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(added ? Icons.star : Icons.star_border, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              added ? 'Added to favorites' : 'Removed from favorites',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: added ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildScholarshipCard(Map<String, dynamic> s, bool isDark) {
    final Color cardColor = _parseColor(s['color']?.toString() ?? '#2563EB');
    final bool isFav = _favoritedScholarshipIds.contains(s['id']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      // ... same container ...
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: cardColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _toggleFavorite(s),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFav ? Colors.amber : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          s['type']?.toString().toUpperCase() ?? 'GENERAL',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s['title']?.toString() ?? 'Scholarship',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: s['logo_url'] != null && s['logo_url'].toString().isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            s['logo_url'],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.school, color: cardColor, size: 24),
                          ),
                        )
                      : Icon(Icons.school, color: cardColor, size: 24),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 _buildInfoRow(Icons.business_outlined, "Provider", s['provider']?.toString() ?? 'N/A'),
                 const SizedBox(height: 12),
                 _buildInfoRow(Icons.monetization_on_outlined, "Benefit", s['amount']?.toString() ?? 'N/A'),
                 const SizedBox(height: 12),
                 _buildInfoRow(Icons.groups_outlined, "Eligibility", s['eligibility']?.toString() ?? 'N/A'),
                 const SizedBox(height: 12),
                 _buildInfoRow(Icons.calendar_today_outlined, "Deadline", s['deadline']?.toString() ?? 'N/A'),
                 const SizedBox(height: 25),
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ScholarshipDetailScreen(scholarship: s)),
                        );
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: cardColor,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       elevation: 0,
                     ),
                     child: Text(AppLocalizations.of(context)!.applyDetails, style: const TextStyle(fontWeight: FontWeight.bold)),
                   ),
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSkeleton() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(child: _buildSkeletonBox(height: 180, radius: 20)),
              const SizedBox(width: 10),
              Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: _buildSkeletonBox(height: 180, radius: 20)),
            ],
          ),
        ),
        const SizedBox(height: 25),
        _buildSkeletonBox(height: 250, radius: 20),
      ],
    );
  }

  Widget _buildSkeletonBox({required double height, required double radius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  String _translateCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('stem') || c.contains('tech')) return AppLocalizations.of(context)!.stemAndTech;
    if (c.contains('business')) return AppLocalizations.of(context)!.businessInterest;
    if (c.contains('health')) return AppLocalizations.of(context)!.health;
    if (c.contains('education')) return AppLocalizations.of(context)!.education;
    if (c.contains('craft') || c.contains('craftsmanship')) return AppLocalizations.of(context)!.craftmanship;
    if (c.contains('public service')) return AppLocalizations.of(context)!.publicService;
    if (c.contains('art') || c.contains('design')) return AppLocalizations.of(context)!.artsAndDesign;
    return category;
  }

  String _translateValue(String value) {
    final v = value.toLowerCase();
    if (v == 'high') return AppLocalizations.of(context)!.high;
    if (v == 'medium') return AppLocalizations.of(context)!.medium;
    if (v == 'low') return AppLocalizations.of(context)!.low;
    if (v == 'competitive') return AppLocalizations.of(context)!.competitive;
    if (v.contains('very high')) return AppLocalizations.of(context)!.veryHigh;
    if (v == 'excellent') return AppLocalizations.of(context)!.excellent;
    if (v == 'good') return AppLocalizations.of(context)!.good;
    // For values like "8/10" or numbers, return as is.
    return value;
  }

  Widget _buildAiComparisonView(bool isDark) {
    final c1 = _careerComparisonData!['field1'];
    final c2 = _careerComparisonData!['field2'];
    if (c1 == null || c2 == null) return const SizedBox();
    
    final selectedField = _selectedComparisonIndex == 0 ? c1 : c2;

    return Column(
      children: [
        // VS Toggle Layout
        SizedBox(
          height: 180,
          child: Row(
            children: [
              _buildVsToggleCard(
                _translateCategory(_careerComparisonData!['interest_labels']?[0] ?? c1['title'] ?? 'Field 1'), 
                Icons.work_outline, 
                0,
                true, // Is left card
                isDark,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context)!.vs, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
              _buildVsToggleCard(
                _translateCategory(_careerComparisonData!['interest_labels']?[1] ?? c2['title'] ?? 'Field 2'), 
                Icons.business_center_outlined, 
                1,
                false, // Is right card
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        
        // Selected Field Details
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(12),
                spreadRadius: 5,
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  selectedField['title'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              _buildFactBox(AppLocalizations.of(context)!.averageSalary, _translateValue(selectedField['salary_range']?.toString() ?? 'N/A'), Icons.monetization_on_outlined, Colors.green),
              const SizedBox(height: 15),
              _buildFactBox(AppLocalizations.of(context)!.marketDemand, _translateValue(selectedField['market_demand']?.toString() ?? 'N/A'), Icons.trending_up, kPrimaryBlue(context)),
              const SizedBox(height: 15),
              _buildFactBox(AppLocalizations.of(context)!.workLifeBalance, _translateValue(selectedField['work_life_balance']?.toString() ?? 'N/A'), Icons.balance, Colors.orange),
              const SizedBox(height: 25),
              Text(AppLocalizations.of(context)!.coreTechnicalSkills, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (selectedField['core_skills'] as List<dynamic>? ?? []).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimaryBlue(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: kPrimaryBlue(context).withOpacity(0.2)),
                    ),
                    child: Text(
                      skill.toString(),
                      style: TextStyle(color: kPrimaryBlue(context), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 15),
              Text(
                _careerComparisonData!['summary_verdict'] ?? '',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVsToggleCard(String title, IconData icon, int toggleIndex, bool isLeft, bool isDark) {
    final isSelected = _selectedComparisonIndex == toggleIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedComparisonIndex = toggleIndex),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLeft ? 20 : 5),
              bottomLeft: Radius.circular(isLeft ? 20 : 5),
              topRight: Radius.circular(isLeft ? 5 : 20),
              bottomRight: Radius.circular(isLeft ? 5 : 20),
            ),
            border: Border.all(
              color: isSelected ? kPrimaryBlue(context) : Colors.grey.shade200,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected) 
                BoxShadow(
                  color: kPrimaryBlue(context).withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryBlue(context).withOpacity(0.1) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? kPrimaryBlue(context) : Colors.grey.shade500, size: 30),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13,
                    color: isSelected ? kPrimaryBlue(context) : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactBox(String title, String value, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumLock(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF2563EB)).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF2563EB)).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_person_rounded, color: isDark ? const Color(0xFF6366F1) : const Color(0xFF2563EB), size: 32),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.premiumComparison,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context)!.unlockDeepAiPoweredInsightsIntoDifferentUniversityMajorsAndCareerPathsWithOurPremiumPlan,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to pricing
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PricingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(AppLocalizations.of(context)!.upgradeToPremium, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
