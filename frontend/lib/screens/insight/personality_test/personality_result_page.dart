import 'package:flutter/material.dart';
import '../../../services/personality_storage_service.dart';
import 'personality_intro_page.dart';
import 'personality_translations.dart';
import '../../../generated/l10n/app_localizations.dart';

class PersonalityResultPage extends StatelessWidget {
  final String personalityType;
  final Map<String, int> scores;

  const PersonalityResultPage({
    super.key,
    required this.personalityType,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = isDark ? const Color(0xFF6366F1) : const Color(0xFF225BE3);
    final bgColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF5F7FF);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final baseData = _personalityData[personalityType] ?? _personalityData['ENFJ']!;
    final typeData = PersonalityTranslations.getLocalizedData(context, personalityType, _personalityData);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: baseData['color'] as Color,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home_rounded, color: Colors.white),
            ),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  await PersonalityStorageService.clearResult();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const PersonalityIntroPage()),
                    );
                  }
                },
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 18),
                label: Text(
                  AppLocalizations.of(context)!.retake,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (baseData['color'] as Color).withValues(alpha: 0.95),
                      (baseData['color'] as Color)
                          .withBlue(
                          ((baseData['color'] as Color).blue * 0.7)
                              .round())
                          .withValues(alpha: 1),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: 30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                typeData['nickname'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              personalityType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            Text(
                              typeData['fullName'] as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Dimension scores
                  _SectionTitle(title: AppLocalizations.of(context)!.yourDimensions, icon: Icons.bar_chart_rounded),
                  const SizedBox(height: 12),
                  _DimensionScores(
                    scores: scores,
                    accentColor: baseData['color'] as Color,
                  ),

                  const SizedBox(height: 24),

                  // Summary
                  _SectionTitle(title: AppLocalizations.of(context)!.overview, icon: Icons.person_rounded),
                  const SizedBox(height: 12),
                  _InfoCard(
                    content: typeData['summary'] as String,
                    color: baseData['color'] as Color,
                  ),

                  const SizedBox(height: 24),

                  // Strengths
                  _SectionTitle(
                      title: AppLocalizations.of(context)!.strengths,
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFF0AB68B)),
                  const SizedBox(height: 12),
                  _TraitList(
                    traits: typeData['strengths'] as List<String>,
                    color: const Color(0xFF0AB68B),
                    icon: Icons.check_circle_rounded,
                  ),

                  const SizedBox(height: 24),

                  // Weaknesses
                  _SectionTitle(
                      title: AppLocalizations.of(context)!.growthAreas,
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFFE35B22)),
                  const SizedBox(height: 12),
                  _TraitList(
                    traits: typeData['weaknesses'] as List<String>,
                    color: const Color(0xFFE35B22),
                    icon: Icons.info_rounded,
                  ),

                  const SizedBox(height: 24),

                  // Career paths
                  _SectionTitle(
                      title: AppLocalizations.of(context)!.careerPaths,
                      icon: Icons.work_rounded,
                      color: const Color(0xFF7C5CBF)),
                  const SizedBox(height: 12),
                  _CareerGrid(
                    careers: typeData['careers'] as List<String>,
                    color: baseData['color'] as Color,
                  ),

                  const SizedBox(height: 24),

                  // Relationships
                  _SectionTitle(
                      title: AppLocalizations.of(context)!.inRelationships,
                      icon: Icons.favorite_rounded,
                      color: const Color(0xFFE3225B)),
                  const SizedBox(height: 12),
                  _InfoCard(
                    content: typeData['relationships'] as String,
                    color: const Color(0xFFE3225B),
                  ),

                  const SizedBox(height: 24),

                  // Famous people
                  _SectionTitle(
                      title: AppLocalizations.of(context)!.famousPeopleOfType(personalityType),
                      icon: Icons.star_rounded,
                      color: const Color(0xFFE3B822)),
                  const SizedBox(height: 12),
                  _FamousPeople(
                    people: typeData['famous'] as List<String>,
                    color: baseData['color'] as Color,
                  ),

                  const SizedBox(height: 32),

                  // Retake button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: brandColor.withOpacity(0.4),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.backToHome,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.icon,
    this.color = const Color(0xFF225BE3),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String content;
  final Color color;

  const _InfoCard({required this.content, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 14,
          height: 1.65,
          color: isDark ? Colors.white70 : const Color(0xFF3A3A5A),
        ),
      ),
    );
  }
}

class _TraitList extends StatelessWidget {
  final List<String> traits;
  final Color color;
  final IconData icon;

  const _TraitList(
      {required this.traits, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.15 : 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: traits.map((trait) {
          final isLast = trait == traits.last;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      trait,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : const Color(0xFF3A3A5A),
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 8),
                Divider(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100], height: 1),
                const SizedBox(height: 8),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CareerGrid extends StatelessWidget {
  final List<String> careers;
  final Color color;

  const _CareerGrid({required this.careers, required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: careers.map((career) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work_outline_rounded, color: color, size: 14),
              const SizedBox(width: 6),
              Text(
                career,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FamousPeople extends StatelessWidget {
  final List<String> people;
  final Color color;

  const _FamousPeople({required this.people, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: people.map((person) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                person,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : const Color(0xFF3A3A5A),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DimensionScores extends StatelessWidget {
  final Map<String, int> scores;
  final Color accentColor;

  const _DimensionScores({required this.scores, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final pairs = [
      ['E', 'I'],
      ['S', 'N'],
      ['T', 'F'],
      ['J', 'P'],
    ];
    final labels = {
      'E': AppLocalizations.of(context)!.extraverted,
      'I': AppLocalizations.of(context)!.introverted,
      'S': AppLocalizations.of(context)!.sensing,
      'N': AppLocalizations.of(context)!.intuitive,
      'T': AppLocalizations.of(context)!.thinking,
      'F': AppLocalizations.of(context)!.feeling,
      'J': AppLocalizations.of(context)!.judging,
      'P': AppLocalizations.of(context)!.perceiving,
    };

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.15 : 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: pairs.map((pair) {
          final aKey = pair[0];
          final bKey = pair[1];
          final aVal = scores[aKey] ?? 0;
          final bVal = scores[bKey] ?? 0;
          final total = aVal + bVal;
          final aFrac = total == 0 ? 0.5 : aVal / total;
          final dominant = aVal >= bVal ? aKey : bKey;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        labels[aKey]!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: dominant == aKey
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: dominant == aKey
                              ? accentColor
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                            widthFactor: aFrac,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          labels[bKey]!,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: dominant == bKey
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: dominant == bKey
                                ? accentColor
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '$aKey: $aVal',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$bKey: $bVal',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Personality data for all 16 types
//
//  Color groups (matching 16Personalities / official MBTI):
//  🟣 Purple  — Analysts   : INTJ, INTP, ENTJ, ENTP
//  🟢 Green   — Diplomats  : INFJ, INFP, ENFJ, ENFP
//  🔵 Blue    — Sentinels  : ISTJ, ISFJ, ESTJ, ESFJ
//  🟡 Yellow  — Explorers  : ISTP, ISFP, ESTP, ESFP
// ─────────────────────────────────────────────────────────────

const Map<String, Map<String, dynamic>> _personalityData = {
  'ENFJ': {
    'color': Color(0xFF33A474), // Diplomat green
    'nickname': 'The Giver',
    'fullName': 'Extraverted iNtuitive Feeling Judging',
    'summary':
    'ENFJs are natural-born leaders and people-focused individuals who live in a world of human possibilities. They are warm, empathetic, highly perceptive, and genuinely interested in others. They make things happen for people and get their best personal satisfaction from helping those around them flourish. ENFJs have an extraordinary ability to tune into people and bring out the best in them.',
    'strengths': [
      'Exceptional people skills — naturally empathetic and warm',
      'Natural leader who inspires and motivates others',
      'Excellent communicator with strong verbal and written skills',
      'Loyal, committed, and deeply caring in relationships',
      'Creative and imaginative with a drive to make a difference',
      'Organized and values structure to achieve goals',
    ],
    'weaknesses': [
      'Can neglect their own needs in favor of others',
      'Overly sensitive to criticism and conflict',
      'May become manipulative or controlling when unbalanced',
      'Tendency to idealize people and then feel let down',
      'Can be too self-sacrificing, burning out over time',
    ],
    'careers': [
      'Counselor', 'Teacher', 'HR Manager', 'Life Coach',
      'Social Worker', 'Psychologist', 'Non-profit Director',
      'Public Relations', 'Marketing',
    ],
    'relationships':
    'ENFJs put a lot of effort and enthusiasm into their relationships. They are warmly affirming, nurturing, and deeply invested in the health of their close bonds. They seek lifelong, meaningful connections and are highly loyal partners. Their challenge is ensuring they don\'t give so much that they lose sight of their own needs.',
    'famous': [
      'Oprah Winfrey', 'Barack Obama', 'Morgan Freeman',
      'Jennifer Lawrence', 'Pope John Paul II',
    ],
  },

  'ENTJ': {
    'color': Color(0xFF854FB1), // Analyst purple
    'nickname': 'The Executive',
    'fullName': 'Extraverted iNtuitive Thinking Judging',
    'summary':
    'ENTJs are natural-born leaders who thrive in roles of authority. They possess an exceptional ability to see possibilities and challenges in every situation, and they are driven to overcome them. Bold, strategic, and decisive, ENTJs are often found at the top of organizations, excelling at long-range planning and energizing others toward a shared vision.',
    'strengths': [
      'Exceptionally strong leadership and strategic thinking',
      'Confident, decisive, and action-oriented',
      'Excellent at organizing people and resources toward goals',
      'Highly motivated and hard-working with vision',
      'Intellectually curious and open to well-reasoned arguments',
    ],
    'weaknesses': [
      'Can be blunt, harsh, or dismissive of emotions',
      'Impatient with inefficiency and those who cannot keep pace',
      'May become controlling or domineering in relationships',
      'Tendency to overlook others\' feelings in pursuit of goals',
      'Can be arrogant or intolerant of perceived weakness',
    ],
    'careers': [
      'CEO', 'Entrepreneur', 'Lawyer', 'Judge',
      'Business Executive', 'Military Officer', 'Politician',
      'Management Consultant', 'Financial Advisor',
    ],
    'relationships':
    'ENTJs take their commitments seriously and bring the same energy and drive to their personal lives. They are often fiercely devoted partners who pursue growth together. However, they must consciously develop emotional sensitivity, as their rational nature can make intimate partners feel undervalued.',
    'famous': [
      'Steve Jobs', 'Bill Gates', 'Margaret Thatcher',
      'Napoleon Bonaparte', 'Franklin D. Roosevelt',
    ],
  },

  'ENFP': {
    'color': Color(0xFF33A474), // Diplomat green
    'nickname': 'The Inspirer',
    'fullName': 'Extraverted iNtuitive Feeling Perceiving',
    'summary':
    'ENFPs are warm, enthusiastic, and typically very bright and full of potential. They live in a world of exciting possibilities and become very passionate about things they believe in. They have an excellent ability to intuitively understand people, and are genuinely interested in almost everyone they meet. ENFPs are natural motivators and visionaries.',
    'strengths': [
      'Warm, enthusiastic, and energetic — a natural motivator',
      'Highly creative and imaginative in problem-solving',
      'Exceptional people skills and emotional intelligence',
      'Adaptable and open to new ideas and experiences',
      'Perceptive and insightful about people\'s motivations',
      'Able to inspire and energize those around them',
    ],
    'weaknesses': [
      'May struggle to follow through on projects and commitments',
      'Easily bored with routine or mundane tasks',
      'Overly idealistic and can be unrealistic',
      'Difficulty making decisions when values conflict',
      'Can take criticism very personally',
    ],
    'careers': [
      'Journalist', 'Actor', 'Entrepreneur', 'Consultant',
      'Therapist', 'Coach', 'Artist', 'Teacher',
      'Event Planner', 'PR Specialist',
    ],
    'relationships':
    'ENFPs are deeply caring and enthusiastic partners who bring excitement and warmth to their relationships. They are devoted and loyal, though their love of novelty can make long-term commitment challenging without the right partner. They need someone who appreciates their spontaneous, big-picture nature.',
    'famous': [
      'Robin Williams', 'Will Smith', 'Ellen DeGeneres',
      'Quentin Tarantino', 'Walt Disney',
    ],
  },

  'ENTP': {
    'color': Color(0xFF854FB1), // Analyst purple
    'nickname': 'The Visionary',
    'fullName': 'Extraverted iNtuitive Thinking Perceiving',
    'summary':
    'ENTPs are innovative, strategic thinkers who love intellectual challenges and debate. They are quick, ingenious, and stimulating. ENTPs are skilled at generating and exploring ideas, and they love to wrestle with complex problems. They see patterns and connections others miss, and are natural innovators who challenge the status quo.',
    'strengths': [
      'Highly creative and quick-thinking — natural innovator',
      'Excellent debater who can see all sides of an argument',
      'Charismatic and engaging communicator',
      'Resourceful and able to improvise solutions rapidly',
      'Enthusiastic, energetic, and inspiring to others',
    ],
    'weaknesses': [
      'May argue for the sake of argument, seeming confrontational',
      'Difficulty following through after initial excitement fades',
      'Can be insensitive to others\' feelings in debate',
      'May neglect practical details and responsibilities',
      'Scattered focus when too many ideas compete for attention',
    ],
    'careers': [
      'Entrepreneur', 'Lawyer', 'Engineer', 'Inventor',
      'Software Developer', 'Consultant', 'Scientist',
      'Venture Capitalist', 'Comedian',
    ],
    'relationships':
    'ENTPs are exciting partners who bring creativity and intellectual depth to their relationships. They need a partner who can match their mental agility and isn\'t threatened by spirited debate. They value authenticity and enjoy growing together intellectually, though they must learn to honor emotional needs.',
    'famous': [
      'Socrates', 'Thomas Edison', 'Leonardo da Vinci',
      'Celine Dion', 'Mark Twain',
    ],
  },

  'ESFJ': {
    'color': Color(0xFF4A90D9), // Sentinel blue
    'nickname': 'The Caregiver',
    'fullName': 'Extraverted Sensing Feeling Judging',
    'summary':
    'ESFJs are warm, conscientious, and traditional. They are people persons who thrive on social harmony and deeply value their relationships. They are extraordinarily good at reading others and meeting their needs. ESFJs take their responsibilities seriously and work hard to create stability and care in their families and communities.',
    'strengths': [
      'Genuinely warm, caring, and deeply interested in people',
      'Highly organized and dependable — gets things done',
      'Loyal and committed to those they love',
      'Exceptional at nurturing and supporting others',
      'Strong social skills and ability to read the room',
    ],
    'weaknesses': [
      'Highly sensitive to criticism and personal rejection',
      'Can become needy of approval and validation',
      'May be too traditional and resistant to change',
      'Tendency to be overly controlling or smothering',
      'Can neglect their own needs while caring for others',
    ],
    'careers': [
      'Nurse', 'Teacher', 'Social Worker', 'HR Professional',
      'Event Planner', 'Nutritionist', 'Office Manager',
      'Counselor', 'Religious Leader',
    ],
    'relationships':
    'ESFJs are devoted, warm, and deeply invested partners. They go out of their way to ensure their loved ones feel cared for and appreciated. They thrive in stable, long-term relationships and are most fulfilled when they feel that their efforts are recognized and reciprocated by their partner.',
    'famous': [
      'Taylor Swift', 'Bill Clinton', 'Princess Diana',
      'Danny Glover', 'Martha Stewart',
    ],
  },

  'ESFP': {
    'color': Color(0xFFE4A020), // Explorer yellow
    'nickname': 'The Performer',
    'fullName': 'Extraverted Sensing Feeling Perceiving',
    'summary':
    'ESFPs are spontaneous, energetic, and enthusiastic people who live for experiences and bringing joy to those around them. They are warm, generous, and genuinely interested in people. They have a special ability to find humor and excitement in everyday situations, and they are natural entertainers who make every room brighter.',
    'strengths': [
      'Bold, original, and fun-loving — lights up any room',
      'Warm-hearted, generous, and genuinely caring',
      'Practical and observant with excellent hands-on skills',
      'Excellent social skills and ability to connect with anyone',
      'Spontaneous and adaptable — thrives in the moment',
    ],
    'weaknesses': [
      'Avoids conflict and may ignore difficult problems',
      'Difficulty with long-term planning and commitment',
      'Can be easily bored and seek constant new stimulation',
      'Sensitive to criticism, may take things too personally',
      'May prioritize fun over responsibilities',
    ],
    'careers': [
      'Entertainer', 'Actor', 'Event Planner', 'Salesperson',
      'Tour Guide', 'Nurse', 'Artist', 'Fashion Designer',
      'Physical Therapist',
    ],
    'relationships':
    'ESFPs bring fun, warmth, and spontaneity to their relationships. They are affectionate and demonstrative partners who enjoy every shared experience. They are committed to those they love, though they need partners who appreciate their need for variety and who don\'t try to fence them in.',
    'famous': [
      'Elvis Presley', 'Marilyn Monroe', 'Adele',
      'Jamie Oliver', 'Katy Perry',
    ],
  },

  'ESTJ': {
    'color': Color(0xFF4A90D9), // Sentinel blue
    'nickname': 'The Guardian',
    'fullName': 'Extraverted Sensing Thinking Judging',
    'summary':
    'ESTJs are pillars of the community — dedicated, organized, and traditional. They value order, rules, and systems, and they thrive in roles that allow them to implement and enforce standards. They are natural managers with a no-nonsense approach to getting things done, and they take great pride in their reliability and work ethic.',
    'strengths': [
      'Highly organized, reliable, and hardworking',
      'Natural leader with a clear, decisive approach',
      'Loyal and deeply committed to family and community',
      'Practical, realistic, and results-oriented',
      'Excellent at enforcing structure and maintaining standards',
    ],
    'weaknesses': [
      'Can be inflexible and resistant to change',
      'May be overly judgmental of those who don\'t share their values',
      'Tendency to focus on rules over emotions',
      'Can be too blunt or harsh in expressing criticism',
      'May struggle to express affection or feelings',
    ],
    'careers': [
      'Military Officer', 'Business Manager', 'Lawyer',
      'Accountant', 'Police Officer', 'Judge',
      'Principal', 'Financial Advisor', 'Project Manager',
    ],
    'relationships':
    'ESTJs are loyal, committed partners who take their relationships very seriously. They express love through actions rather than words — providing stability, security, and unwavering dependability. They need to consciously develop emotional sensitivity to ensure their partner feels valued beyond just practical support.',
    'famous': [
      'Judge Judy', 'John D. Rockefeller', 'Lyndon B. Johnson',
      'Uma Thurman', 'Henry Ford',
    ],
  },

  'ESTP': {
    'color': Color(0xFFE4A020), // Explorer yellow
    'nickname': 'The Doer',
    'fullName': 'Extraverted Sensing Thinking Perceiving',
    'summary':
    'ESTPs are energetic, action-oriented people who live in the moment and love a challenge. They are blunt, practical, and perceptive — especially skilled at reading people and situations. They think on their feet, improvise brilliantly, and are natural entrepreneurs. Life is never dull around an ESTP.',
    'strengths': [
      'Bold, direct, and excellent in crisis situations',
      'Highly perceptive — able to read people quickly and accurately',
      'Resourceful, adaptable, and thrives under pressure',
      'Charismatic and persuasive communicator',
      'Practical problem-solver with a strong action bias',
    ],
    'weaknesses': [
      'May be impulsive, taking risks without enough thought',
      'Can be insensitive to others\' emotions',
      'Difficulty with long-term planning and routine',
      'May lose interest in projects after the initial challenge',
      'Can be blunt or even aggressive under pressure',
    ],
    'careers': [
      'Entrepreneur', 'Sales Manager', 'Stock Broker',
      'Paramedic', 'Detective', 'Athlete', 'Pilot',
      'Marketing Executive', 'Real Estate Agent',
    ],
    'relationships':
    'ESTPs bring excitement, playfulness, and raw energy to their relationships. They are loyal to those they care about, though long-term commitment can be a challenge. They thrive with partners who are secure and can keep pace with their spontaneous lifestyle without demanding too much emotional processing.',
    'famous': [
      'Ernest Hemingway', 'Madonna', 'Donald Trump',
      'Jack Nicholson', 'Eddie Murphy',
    ],
  },

  'INFJ': {
    'color': Color(0xFF33A474), // Diplomat green
    'nickname': 'The Protector',
    'fullName': 'Introverted iNtuitive Feeling Judging',
    'summary':
    'INFJs are the rarest of all personality types — gentle, complex, and deeply intuitive. They have an uncanny insight into people and situations, often knowing things without being able to explain why. They are driven by their deeply held values and a desire to make the world a better place. INFJs are creative visionaries who quietly change the world around them.',
    'strengths': [
      'Profound insight into people, emotions, and patterns',
      'Deeply principled with a clear moral compass',
      'Creative and visionary — sees the big picture',
      'Warm, empathetic, and a skilled listener',
      'Determined and persistent in pursuing meaningful goals',
    ],
    'weaknesses': [
      'Prone to burnout from absorbing others\' emotions',
      'Can be overly private and difficult to truly know',
      'May have unrealistically high standards for themselves and others',
      'Sensitive to conflict and criticism',
      'Tendency to become perfectionistic and self-critical',
    ],
    'careers': [
      'Therapist', 'Writer', 'Artist', 'Professor',
      'Non-profit Director', 'Clergy', 'Doctor',
      'Psychologist', 'Social Activist',
    ],
    'relationships':
    'INFJs are deeply devoted, caring partners who seek authentic, long-term connections. They invest heavily in their relationships and bring a rare depth of understanding and empathy. They need a partner who values emotional intimacy and can appreciate their need for both deep connection and personal solitude.',
    'famous': [
      'Nelson Mandela', 'Martin Luther King Jr.', 'Mahatma Gandhi',
      'Plato', 'Carl Jung',
    ],
  },

  'INFP': {
    'color': Color(0xFF33A474), // Diplomat green
    'nickname': 'The Idealist',
    'fullName': 'Introverted iNtuitive Feeling Perceiving',
    'summary':
    'INFPs are sensitive, caring, and fiercely idealistic. They are driven by their deeply held values and a desire to find meaning in everything. They have rich inner worlds and a genuine interest in understanding themselves and those around them. INFPs are natural artists and writers who bring beauty and meaning to the world through their unique perspective.',
    'strengths': [
      'Deeply empathetic and genuinely caring toward others',
      'Creative and imaginative with a unique perspective',
      'Passionate about meaningful causes and values',
      'Excellent listener who makes people feel truly heard',
      'Adaptable and open-minded in most situations',
    ],
    'weaknesses': [
      'Can be unrealistically idealistic and expect too much',
      'Overly sensitive to criticism — takes things personally',
      'Tendency to withdraw and isolate when overwhelmed',
      'May neglect practical day-to-day responsibilities',
      'Can be indecisive when values conflict',
    ],
    'careers': [
      'Writer', 'Artist', 'Counselor', 'Social Worker',
      'Teacher', 'Psychologist', 'Librarian',
      'Non-profit Worker', 'Musician',
    ],
    'relationships':
    'INFPs are devoted, loving partners who value deep, authentic connection above all else. They bring a rare depth of feeling and loyalty to their relationships. They need partners who respect their values and independence, and who can provide gentle encouragement when they become self-critical.',
    'famous': [
      'William Shakespeare', 'J.R.R. Tolkien', 'Princess Diana',
      'Audrey Hepburn', 'Johnny Depp',
    ],
  },

  'INTJ': {
    'color': Color(0xFF854FB1), // Analyst purple
    'nickname': 'The Scientist',
    'fullName': 'Introverted iNtuitive Thinking Judging',
    'summary':
    'INTJs are analytical, strategic, and driven by an insatiable hunger for knowledge and competence. They are supreme strategists — always thinking several steps ahead. They have a gift for seeing patterns and creating systems, and are relentlessly self-improving. INTJs hold extremely high standards for themselves and others.',
    'strengths': [
      'Brilliant strategic thinker with exceptional analytical ability',
      'Independent, confident, and self-driven',
      'Highly competent across diverse disciplines',
      'Creative, original, and visionary in problem-solving',
      'Determined and persistent in achieving long-term goals',
    ],
    'weaknesses': [
      'Can appear cold, arrogant, or dismissive of others',
      'Difficulty expressing emotions or understanding others\' feelings',
      'May be overly critical and hold unrealistic expectations',
      'Intolerant of inefficiency or what they perceive as incompetence',
      'Can be stubborn and refuse to consider alternative views',
    ],
    'careers': [
      'Scientist', 'Engineer', 'Software Developer', 'Strategist',
      'Professor', 'Surgeon', 'Investment Banker',
      'Author', 'Architect',
    ],
    'relationships':
    'INTJs are deeply loyal and committed partners who take relationships seriously. They show love through acts of service and intellectual engagement rather than emotional expression. They need a partner who can match their intellect, respect their need for autonomy, and not require constant emotional reassurance.',
    'famous': [
      'Elon Musk', 'Isaac Newton', 'Nikola Tesla',
      'Friedrich Nietzsche', 'Mark Zuckerberg',
    ],
  },

  'INTP': {
    'color': Color(0xFF854FB1), // Analyst purple
    'nickname': 'The Thinker',
    'fullName': 'Introverted iNtuitive Thinking Perceiving',
    'summary':
    'INTPs are precise, analytical, and endlessly curious. They love theory and abstract concepts, and spend much of their lives inside their rich inner world. They are the pioneering thinkers of new ideas — able to work out logical problems with breathtaking speed and ingenuity. They value truth and accuracy above almost everything else.',
    'strengths': [
      'Brilliant logical thinker — exceptional at solving complex problems',
      'Creative and original with deep theoretical knowledge',
      'Objective and fair-minded in analysis',
      'Open-minded and willing to revise views with new information',
      'Highly independent and able to focus intensely',
    ],
    'weaknesses': [
      'Can be socially awkward and oblivious to social cues',
      'Difficulty expressing feelings or connecting emotionally',
      'May neglect practical matters and daily routines',
      'Prone to procrastination on implementation after theorizing',
      'Can be condescending about others\' intelligence',
    ],
    'careers': [
      'Programmer', 'Mathematician', 'Philosopher', 'Researcher',
      'Data Scientist', 'Systems Analyst', 'Physicist',
      'Professor', 'Economist',
    ],
    'relationships':
    'INTPs are loyal, thoughtful partners who show love through intellectual engagement and problem-solving for those they care about. They struggle to express emotions, and partners need patience and directness. Once committed, they are deeply devoted and love in a pure, genuine way — even if it isn\'t always obvious.',
    'famous': [
      'Albert Einstein', 'Charles Darwin', 'Rene Descartes',
      'Abraham Lincoln', 'Bill Gates',
    ],
  },

  'ISFJ': {
    'color': Color(0xFF4A90D9), // Sentinel blue
    'nickname': 'The Nurturer',
    'fullName': 'Introverted Sensing Feeling Judging',
    'summary':
    'ISFJs are warm, devoted, and extraordinarily hard-working. They are the backbone of society — quietly taking on responsibility and ensuring the needs of others are met. They have a remarkable memory for personal details and are deeply loyal to those they love. ISFJs draw great fulfillment from service to others.',
    'strengths': [
      'Warm, reliable, and deeply devoted to those they love',
      'Highly observant and attentive to people\'s needs',
      'Exceptional memory for important personal details',
      'Practical, organized, and gets things done quietly',
      'Patient, loyal, and consistently supportive',
    ],
    'weaknesses': [
      'Neglects their own needs to take care of others',
      'Difficulty saying no and can be taken advantage of',
      'Very sensitive to criticism and conflict',
      'Reluctant to change established habits and traditions',
      'May bottle up feelings until they overflow',
    ],
    'careers': [
      'Nurse', 'Teacher', 'Social Worker', 'Librarian',
      'Interior Designer', 'Office Manager',
      'Customer Service', 'Counselor', 'Veterinarian',
    ],
    'relationships':
    'ISFJs are deeply devoted and selfless partners. They are warm, affectionate, and genuinely invested in their loved ones\' well-being. They prioritize stability and continuity, and are often the emotional anchor of their families. They need to feel appreciated and must learn to vocalize their own needs in relationships.',
    'famous': [
      'Mother Teresa', 'Queen Elizabeth II', 'Beyoncé',
      'Kate Middleton', 'George Washington',
    ],
  },

  'ISFP': {
    'color': Color(0xFFE4A020), // Explorer yellow
    'nickname': 'The Artist',
    'fullName': 'Introverted Sensing Feeling Perceiving',
    'summary':
    'ISFPs are gentle, kind, and deeply sensitive individuals with a rich appreciation for beauty and a strong connection to their values. They are quiet observers of the world who express themselves through art, action, and quiet acts of care. They live in the present moment and are driven by a desire to live in harmony with their values.',
    'strengths': [
      'Warm, sensitive, and deeply caring toward others',
      'Creative and highly attuned to aesthetics and beauty',
      'Flexible, open-minded, and non-judgmental',
      'Loyal and committed to those they love',
      'Present-focused and able to fully enjoy the moment',
    ],
    'weaknesses': [
      'Overly sensitive to criticism and perceived rejection',
      'Difficulty planning for the future or long-term goals',
      'Can be reserved and hard to get to know deeply',
      'May avoid conflict even when it needs to be addressed',
      'Can be unpredictable or inconsistent in commitments',
    ],
    'careers': [
      'Artist', 'Musician', 'Fashion Designer', 'Chef',
      'Nurse', 'Veterinarian', 'Interior Designer',
      'Physical Therapist', 'Teacher (Arts)',
    ],
    'relationships':
    'ISFPs are devoted, affectionate, and deeply thoughtful partners. They show their love through actions and quiet gestures rather than words. They need a patient, supportive partner who can draw them out of their shell and who appreciates their deep, though understated, capacity for love.',
    'famous': [
      'Michael Jackson', 'Frida Kahlo', 'Jimi Hendrix',
      'Marilyn Monroe', 'Paul McCartney',
    ],
  },

  'ISTJ': {
    'color': Color(0xFF4A90D9), // Sentinel blue
    'nickname': 'The Duty Fulfiller',
    'fullName': 'Introverted Sensing Thinking Judging',
    'summary':
    'ISTJs are responsible, thorough, and deeply principled. They value tradition, loyalty, and dependability above almost all else. They are meticulous in their work and can be counted on to follow through on any commitment they make. ISTJs are pillars of stability who keep systems, families, and organizations running smoothly.',
    'strengths': [
      'Exceptionally reliable, organized, and hard-working',
      'Deeply loyal and committed to their responsibilities',
      'Highly practical and grounded in reality',
      'Excellent memory for facts and details',
      'Strong moral compass and sense of duty',
    ],
    'weaknesses': [
      'Can be resistant to change and new approaches',
      'May be too focused on rules at the expense of people\'s feelings',
      'Difficulty expressing emotions or offering affirmation',
      'Can be judgmental of those who don\'t share their work ethic',
      'May struggle to delegate or trust others with important tasks',
    ],
    'careers': [
      'Accountant', 'Military Officer', 'Police Officer',
      'Dentist', 'Librarian', 'Project Manager',
      'Database Administrator', 'Auditor', 'Judge',
    ],
    'relationships':
    'ISTJs are loyal, devoted partners who take their commitments extremely seriously. They express love through practical actions — providing security, stability, and dependability. They may not be verbally expressive but are deeply dedicated. Partners need to encourage them to open up emotionally over time.',
    'famous': [
      'Angela Merkel', 'Condoleezza Rice', 'George Washington',
      'Warren Buffett', 'Jeff Bezos',
    ],
  },

  'ISTP': {
    'color': Color(0xFFE4A020), // Explorer yellow
    'nickname': 'The Mechanic',
    'fullName': 'Introverted Sensing Thinking Perceiving',
    'summary':
    'ISTPs are masterful problem-solvers with a deep, intuitive understanding of how things work. They are cool under pressure, adaptable, and practical. They prefer action over words and learn best by doing. ISTPs have a quiet confidence and a direct, no-nonsense approach that earns deep respect from those around them.',
    'strengths': [
      'Excellent technical and mechanical skills',
      'Cool, calm, and highly effective in crisis situations',
      'Independent, confident, and self-sufficient',
      'Practical and action-oriented with creative solutions',
      'Loyal and direct — says what they mean',
    ],
    'weaknesses': [
      'Can be emotionally detached or seem uncaring',
      'Difficulty with long-term commitments and planning',
      'May withdraw when emotional demands become intense',
      'Can be insensitive to others\' emotional needs',
      'Tendency to avoid confronting relationship issues',
    ],
    'careers': [
      'Mechanic', 'Engineer', 'Pilot', 'Surgeon',
      'Forensic Scientist', 'Programmer', 'Carpenter',
      'Athlete', 'Firefighter',
    ],
    'relationships':
    'ISTPs are loyal partners who show their love through action and reliability rather than emotional expression. They need significant personal space and independence, and are best matched with partners who value autonomy. Deep connections develop slowly but are strong once established.',
    'famous': [
      'Clint Eastwood', 'Tom Cruise', 'Michael Jordan',
      'Bruce Lee', 'Scarlett Johansson',
    ],
  },
};
