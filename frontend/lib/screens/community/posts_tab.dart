import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../services/community_service.dart';
import 'post_card.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'user_profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => PostsTabState();
}

class PostsTabState extends State<PostsTab> {
  final TextEditingController _searchController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    fetchPosts();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await _authService.getUser();
      if (mounted) setState(() => _currentUserId = user['id']);
    } catch (_) {}
  }

  Future<void> fetchPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final posts = await _communityService.getPosts();
      final recommendations = await _communityService.getRecommendations();
      if (mounted) {
        setState(() {
          _posts = posts;
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    final isLiked = post['isLiked'] == 1 || post['isLiked'] == true;
    final postId = post['id'];

    // Optimistic update
    setState(() {
      _posts[index]['isLiked'] = !isLiked;
      _posts[index]['likeCount'] = isLiked 
          ? (_posts[index]['likeCount'] ?? 1) - 1 
          : (_posts[index]['likeCount'] ?? 0) + 1;
    });

    try {
      await _communityService.toggleLike(postId);
    } catch (e) {
      // Revert if error
      if (mounted) {
        setState(() {
          _posts[index]['isLiked'] = isLiked;
           _posts[index]['likeCount'] = isLiked 
              ? (_posts[index]['likeCount'] ?? 0) + 1 
              : (_posts[index]['likeCount'] ?? 1) - 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToUpdateLike)),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildRecommendationsCarousel() {
    if (_recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: kPrimaryBlue(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.peopleWithTheSameInterest,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final user = _recommendations[index];
              final String name = user['name'] ?? 'Unknown';
              final String? image = user['userImage'];
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        userId: user['id'],
                        userName: name,
                        userImage: image ?? '',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: image != null && image.isNotEmpty ? NetworkImage(image) : null,
                        backgroundColor: kPrimaryBlue(context).withOpacity(0.1),
                        child: (image == null || image.isEmpty) ? Text(name[0].toUpperCase(), style: GoogleFonts.outfit(color: kPrimaryBlue(context), fontWeight: FontWeight.bold)) : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await _communityService.sendFriendRequest(user['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.friendRequestSentTo(name))),
                              );
                              // Refetch to remove them from recommendations
                              fetchPosts();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.failedToSendRequest)),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue(context),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                           child: Text(AppLocalizations.of(context)!.addFriend, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue(context))))
              : (_posts.isEmpty && _recommendations.isEmpty)
                  ? Center(child: Text(AppLocalizations.of(context)!.noPostsYetBeTheFirstToPost))
                  : RefreshIndicator(
                      onRefresh: fetchPosts,
                      child: CustomScrollView(
                        slivers: [
                          if (_recommendations.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _buildRecommendationsCarousel(),
                            ),

                          if (_posts.isEmpty)
                            SliverFillRemaining(
                              child: Center(child: Text(AppLocalizations.of(context)!.noPostsYetBeTheFirstToPost)),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.only(bottom: 120),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final post = _posts[index];
                                    String timeDisplay;
                                    try {
                                      final date = DateTime.parse(post['created_at']);
                                      timeDisplay = timeago.format(date);
                                    } catch (e) {
                                      timeDisplay = 'Just now';
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: PostCard(
                                        id: post['id'],
                                        userId: post['user_id'] ?? 0,
                                        userName: post['userName'] ?? 'Unknown',
                                        userImage: post['userImage'],
                                        userStreak: post['current_streak'] ?? 0,
                                        timeAgo: timeDisplay,
                                        viewCount: '${post['view_count'] ?? 0}',
                                        isVerified: post['isVerified'] == 1 || post['isVerified'] == true,
                                        isHot: post['isHot'] == 1 || post['isHot'] == true,
                                        title: post['title'] ?? '',
                                        body: post['body'] ?? '',
                                        imageUrl: post['image_url'],
                                        mediaUrls: post['media_urls'] != null ? List<String>.from(post['media_urls']) : [],
                                        tags: post['tags'] != null ? List<String>.from(post['tags']) : [],
                                        likeCount: post['likeCount'] ?? 0,
                                        commentCount: post['commentCount'] ?? 0,
                                        isLiked: post['isLiked'] == 1 || post['isLiked'] == true,
                                        currentUserId: _currentUserId,
                                        onLike: () => _toggleLike(index),
                                        onEdit: fetchPosts,
                                        onDelete: fetchPosts,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PostDetailScreen(postData: post),
                                            ),
                                          ).then((_) => fetchPosts());
                                        },
                                      ),
                                    );
                                  },
                                  childCount: _posts.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}

class _RecommendationsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _RecommendationsHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => 250;

  @override
  double get minExtent => 250;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
