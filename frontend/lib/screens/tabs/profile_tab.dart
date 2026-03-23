import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../models/interest_model.dart';
import '../../services/api_service.dart';
import '../../services/community_service.dart';
import '../interest_picker_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'favorites_tab.dart';
import 'pricing_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../main.dart'; 
import 'package:frontend/services/api_service.dart';
import '../../state/language_provider.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n/app_localizations.dart';
// Note: Ensure that the ApiService import is here

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);
Color kStreakColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8B5CF6) : const Color(0xFFF97316);

class ProfileTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onRefresh;

  const ProfileTab({super.key, required this.userData, this.onRefresh});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthService _authService = AuthService();
  final CommunityService _communityService = CommunityService();
  List<Interest> _interestDefinitions = [];
  bool _isLoadingInterests = true;
  
  List<Map<String, dynamic>> _activities = [];
  bool _isLoadingActivities = true;

  @override
  void initState() {
    super.initState();
    _fetchInterestDefinitions();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    try {
      final userId = widget.userData['id'];
      if (userId == null) return;
      
      final acts = await _communityService.getUserActivities(userId);
      if (mounted) {
        setState(() {
          _activities = acts;
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingActivities = false);
      }
    }
  }

  Future<void> _fetchInterestDefinitions() async {
    try {
      final rawData = await _authService.getInterests();
      if (mounted) {
        setState(() {
          _interestDefinitions = rawData.map((data) => Interest.fromJson(data)).toList();
          _isLoadingInterests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInterests = false);
      }
      print("Error fetching definitions: $e");
    }
  }
  
  void _handleSignOut(BuildContext context) async {
    // Reset theme to light mode automatically on sign out
    themeManager.value = false;
    ApiService.isDarkMode = false;
    const storage = FlutterSecureStorage();
    await storage.write(key: 'is_dark_mode', value: 'false');

    await _authService.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> _handleUpdateInterests(BuildContext context) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, 
        pageBuilder: (context, _, __) => const InterestPickerScreen(isUpdating: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
    
    if (result == true) {
      widget.onRefresh?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interests updated successfully!')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
     try {
       final XFile? image = await picker.pickImage(
         source: source,
         imageQuality: 70, // Significant compression to reduce file size
         maxWidth: 1000,   // Max width for profile pic
         maxHeight: 1000,  // Max height for profile pic
       );
       if (image != null) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Uploading image...')),
           );
         }
         await _authService.uploadProfilePicture(image.path);
         widget.onRefresh?.call();
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Profile picture updated!')),
           );
         }
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Upload failed: $e')),
         );
       }
     }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showChangePasswordPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(
          userData: widget.userData,
          onUpdate: () => widget.onRefresh?.call(),
        ),
      ),
    );
  }

  Future<void> _showEditProfilePage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          userData: widget.userData,
          onUpdate: () => widget.onRefresh?.call(),
        ),
      ),
    );
  }

  void _showMockDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.userData['name'] ?? 'User';
    String userEmail = widget.userData['email'] ?? '';

    // Parse interest IDs from user data
    List<int> userInterestIds = [];
    if (widget.userData['interestIds'] != null) {
       userInterestIds = List<int>.from(widget.userData['interestIds']);
    }

    Color getSubscriptionColor(String plan) {
      final p = plan.toLowerCase();
      if (p.contains('pro')) return Colors.amber.shade700;
      if (p.contains('premium') || p.contains('elite')) return Colors.purple.shade600;
      if (p.contains('focused') || p.contains('decision')) return Colors.teal.shade400; // Teal/Mint
      return kPrimaryBlue(context); // Free/others
    }
    final subColor = getSubscriptionColor(ApiService.currentGlobalSubscription);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      // backgroundColor: Colors.white, // Remove fixed white to use theme color
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 23, 16, 12),
              child: Text(
                AppLocalizations.of(context)!.profile,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // User Identity Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F7FF), // Theme aware card color
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kPrimaryBlue(context).withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryBlue(context).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kPrimaryBlue(context).withOpacity(0.2), width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: kPrimaryBlue(context).withOpacity(0.1),
                            backgroundImage: (widget.userData['profile_picture'] != null &&
                                    widget.userData['profile_picture'].toString().isNotEmpty)
                                ? NetworkImage(widget.userData['profile_picture'].toString())
                                : null,
                            child: (widget.userData['profile_picture'] == null ||
                                    widget.userData['profile_picture'].toString().isEmpty)
                                ? Text(
                                    userName.substring(0, 1).toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryBlue(context),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showImagePickerOptions(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kPrimaryBlue(context),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryBlue(context).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                                Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                 decoration: BoxDecoration(
                                  color: kStreakColor(context).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      color: kStreakColor(context),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.userData['current_streak'] ?? 0} ${AppLocalizations.of(context)!.daysStreak}',
                                      style: GoogleFonts.outfit(
                                        color: kStreakColor(context),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: subColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.workspace_premium, color: subColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      ApiService.currentGlobalSubscription, // dynamic
                                      style: GoogleFonts.outfit(
                                        color: subColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              Row(
                children: [
                   Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(color: kPrimaryBlue(context), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.personalization,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildSettingGroup([
                _buildSettingTile(
                  icon: Icons.tune,
                  title: AppLocalizations.of(context)!.updateInterests,
                  subtitle: AppLocalizations.of(context)!.updateInterestsSub,
                  onTap: () => _handleUpdateInterests(context),
                ),
                _buildSettingTile(
                  icon: Icons.star_border_rounded,
                  title: AppLocalizations.of(context)!.favorites,
                  subtitle: AppLocalizations.of(context)!.myFavoritesSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FavoritesTab(),
                      ),
                    );
                  },
                ),
                _buildThemeTile(context),
                _buildLanguageTile(context),
              ]),

              const SizedBox(height: 32),
              
              Row(
                children: [
                   Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(color: kPrimaryBlue(context), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.accountSettings,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildSettingGroup([
                _buildSettingTile(
                  icon: Icons.person_outline,
                  title: AppLocalizations.of(context)!.editProfileInfo,
                  onTap: () => _showEditProfilePage(context),
                ),
                _buildSettingTile(
                  icon: Icons.workspace_premium_outlined,
                  title: AppLocalizations.of(context)!.manageSubscription,
                  subtitle: AppLocalizations.of(context)!.manageSubscriptionSub,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PricingScreen()),
                    );
                  },
                ),
                _buildSettingTile(
                  icon: Icons.lock_outline,
                  title: AppLocalizations.of(context)!.changePassword,
                  onTap: () => _showChangePasswordPage(context),
                ),
                _buildSettingTile(
                  icon: Icons.logout,
                  title: AppLocalizations.of(context)!.signOut,
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () => _handleSignOut(context),
                  showArrow: false,
                ),
              ]),

              const SizedBox(height: 32),

              // Activity Section Header
              Row(
                children: [
                   Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(color: kPrimaryBlue(context), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.recentActivity,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoadingActivities)
                const Center(child: CircularProgressIndicator())
              else if (_activities.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.noRecentActivity, style: GoogleFonts.outfit(color: const Color(0xFF94A3B8))),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _activities.map((act) {
                      String actionType = act['action_type']?.toString() ?? 'unknown';
                      String subTitle = 'You performed an action';
                      IconData iconData = Icons.local_activity;
                      Color iconColor = Colors.grey;
                      Color bgColor = Colors.grey.shade100;

                      if (actionType == 'created_post') {
                        subTitle = AppLocalizations.of(context)!.communityPost;
                        iconData = Icons.post_add;
                        iconColor = const Color(0xFF2563EB);
                        bgColor = Colors.blue.shade50;
                      } else if (actionType == 'favorited_item') {
                        subTitle = AppLocalizations.of(context)!.favoritedItem;
                        iconData = Icons.star;
                        iconColor = Colors.amber;
                        bgColor = Colors.amber.shade50;
                      } else if (actionType == 'viewed_scholarship') {
                        subTitle = AppLocalizations.of(context)!.viewedScholarship;
                        iconData = Icons.school;
                        iconColor = Colors.green;
                        bgColor = Colors.green.shade50;
                      }

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: iconColor, size: 20),
                        ),
                        title: Text(
                          act['title'] ?? AppLocalizations.of(context)!.unknownActivity,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: titleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                          subtitle: Text(subTitle, style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF64748B))),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 120), // Bottom padding for nav bar overlap
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSettingGroup(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int index = entry.key;
          Widget child = entry.value;
          bool isLast = index == children.length - 1;

          if (isLast) return child;

          return Column(
            children: [
              child,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeManager,
      builder: (context, isDark, child) {
        return _buildSettingTile(
          icon: isDark ? Icons.dark_mode : Icons.light_mode,
          title: AppLocalizations.of(context)!.darkMode,
          subtitle: isDark ? AppLocalizations.of(context)!.darkAesthetic : AppLocalizations.of(context)!.lightAesthetic,
          onTap: () {}, // Handled by trailing
          showArrow: false,
          trailing: Switch(
            value: isDark,
            activeColor: kPrimaryBlue(context),
            onChanged: (val) async {
              themeManager.value = val;
              ApiService.isDarkMode = val;
              final storage = FlutterSecureStorage();
              await storage.write(key: 'is_dark_mode', value: val.toString());
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = langProvider.locale?.languageCode == 'km';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _buildSettingTile(
      icon: Icons.language_rounded,
      title: isKhmer ? 'ភាសា' : 'Language',
      subtitle: isKhmer ? 'ខ្មែរ' : 'English',
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectLanguage,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                      title: Text('English', style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87)),
                      trailing: !isKhmer ? Icon(Icons.check_circle, color: kPrimaryBlue(context)) : null,
                      onTap: () {
                        langProvider.setLocale(const Locale('en'));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Text('🇰🇭', style: TextStyle(fontSize: 24)),
                      title: Text('ខ្មែរ (Khmer)', style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87)),
                      trailing: isKhmer ? Icon(Icons.check_circle, color: kPrimaryBlue(context)) : null,
                      onTap: () {
                        langProvider.setLocale(const Locale('km'));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      showArrow: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isKhmer ? 'KH' : 'EN',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue(context),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white24 : Colors.grey.shade400),
        ],
      ),
    );
  }


  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    bool showArrow = true,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveIconColor = isDark ? const Color(0xFF6366F1) : const Color(0xFF2563EB); // purpleish blue like navbar
    final Color effectiveTitleColor = titleColor ?? (isDark ? Colors.white : const Color(0xFF1E293B));
    final Color effectiveSubtitleColor = isDark ? Colors.white : const Color(0xFF64748B); 

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: effectiveIconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: effectiveIconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: effectiveTitleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: effectiveSubtitleColor))
          : null,
      trailing: trailing ?? (showArrow
          ? Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white24 : Colors.grey.shade400)
          : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
