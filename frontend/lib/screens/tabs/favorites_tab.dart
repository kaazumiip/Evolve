import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'scholarship_detail_screen.dart';
import '../community/post_detail_screen.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _favorites = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchFavorites() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = data;
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _scholarships => _favorites.where((f) => f['saved_type'] == 'scholarship').toList();
  List<dynamic> get _posts => _favorites.where((f) => f['saved_type'] == 'post').toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header matching Student Hub & Insight
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 23, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Favorites',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: titleColor, size: 20),
                    onPressed: _fetchFavorites,
                  ),
                ],
              ),
            ),
            
            // TabBar moved to body
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.only(left: 35),
              labelPadding: const EdgeInsets.only(left: 0, right: 30),
              labelColor: kPrimaryBlue(context),
              unselectedLabelColor: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              indicatorColor: kPrimaryBlue(context),
              indicatorWeight: 3,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Scholarships'),
                Tab(text: 'Posts'),
              ],
            ),

            // Push content down by 50px
            const SizedBox(height: 50),

            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllList(),
                      _buildScholarshipList(),
                      _buildPostList(),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllList() {
    if (_favorites.isEmpty) return _buildEmptyState('No favorites saved yet.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final item = _favorites[index];
        if (item['saved_type'] == 'scholarship') {
          return _buildScholarshipCard(item);
        } else {
          return _buildPostCard(item);
        }
      },
    );
  }

  Widget _buildScholarshipList() {
    if (_scholarships.isEmpty) return _buildEmptyState('No saved scholarships.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      itemCount: _scholarships.length,
      itemBuilder: (context, index) {
        final s = _scholarships[index];
        return _buildScholarshipCard(s);
      },
    );
  }

  Widget _buildPostList() {
    if (_posts.isEmpty) return _buildEmptyState('No saved posts.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final p = _posts[index];
        return _buildPostCard(p);
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildScholarshipCard(Map<String, dynamic> s) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = _parseColor(s['color'] ?? '#1565C0');
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : cardColor.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : cardColor.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScholarshipDetailScreen(scholarship: s)),
          ).then((_) => _fetchFavorites());
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () async {
                      final int? id = s['id'];
                      if (id != null) {
                        await _apiService.toggleFavorite('scholarship', id);
                        _fetchFavorites(); // Refresh the list
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.star_rounded,
                      color: Colors.amber, 
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['type']?.toString().toUpperCase() ?? 'ALL', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text(s['title'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(s['provider'] ?? 'Unknown Provider', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
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
              child: Row(
                children: [
                  Icon(Icons.monetization_on_outlined, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(s['amount'] ?? 'Varies', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(s['deadline'] ?? 'Open', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> p) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostDetailScreen(postData: p)),
          ).then((_) => _fetchFavorites());
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p['image_url'] != null && p['image_url'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  p['image_url'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.shade50, 
                        backgroundImage: (p['userImage'] != null && p['userImage'].toString().isNotEmpty)
                          ? NetworkImage(p['userImage'])
                          : null,
                        child: (p['userImage'] == null || p['userImage'].toString().isEmpty)
                          ? Text(p['author_name']?.substring(0,1).toUpperCase() ?? 'U', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kPrimaryBlue(context)))
                          : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['author_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(p['created_at'] != null ? p['created_at'].toString().substring(0,10) : '', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (p['title'] != null && p['title'].toString().isNotEmpty) ...[
                    Text(p['title'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    p['body'] ?? p['content'] ?? '', 
                    style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey.shade700), 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    colorString = colorString.toUpperCase().replaceAll("#", "");
    if (colorString.length == 6) {
      colorString = "FF$colorString";
    }
    return Color(int.tryParse(colorString, radix: 16) ?? 0xFF1565C0);
  }
}
