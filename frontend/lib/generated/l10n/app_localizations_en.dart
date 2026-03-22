// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Evolve';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get insight => 'Insight';

  @override
  String get community => 'Community';

  @override
  String get profile => 'Profile';

  @override
  String get postHub => 'Post Hub';

  @override
  String get careerRoadmap => 'Career Roadmap';

  @override
  String get saveRoadmap => 'Save Roadmap';

  @override
  String get viewMap => 'View Map';

  @override
  String get normalDayTitle => 'Normal Day in Field';

  @override
  String get developmentTitle => 'Development & Promotion';

  @override
  String get addComment => 'Write a comment...';

  @override
  String get addReply => 'Add a reply...';

  @override
  String get send => 'Send';

  @override
  String get like => 'Like';

  @override
  String get comment => 'Comment';

  @override
  String get share => 'Share';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get noData => 'No data available';

  @override
  String get visionBoard => 'Vision board';

  @override
  String get visionHub => 'Vision Hub';

  @override
  String get emoticons => 'Emoticons';

  @override
  String get recents => 'Recents';

  @override
  String get trendingKawaii => 'Trending Kawaii';

  @override
  String get searchEmoticons => 'Search Emoticons...';

  @override
  String get addVision => 'Add to Vision Board';

  @override
  String visionsCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Visions Created',
      one: '1 Vision Created',
      zero: 'No Visions',
    );
    return '$_temp0';
  }

  @override
  String storiesRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stories Recorded',
      one: '1 Story Recorded',
      zero: 'No Entries',
    );
    return '$_temp0';
  }

  @override
  String vibesSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vibes Saved',
      one: '1 Vibe Saved',
      zero: 'Find your vibe',
    );
    return '$_temp0';
  }

  @override
  String get savedToCache => 'Saved to cache';

  @override
  String get failedToSave => 'Failed to save to cache';

  @override
  String get overview => 'Overview';

  @override
  String get roadmap => 'Roadmap';

  @override
  String get learningResources => 'Resources';

  @override
  String get topCompanies => 'Top Hiring Companies';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get unlockRoadmap => 'Unlock with Decisions Pack';

  @override
  String get streakDay => 'Streak Day';

  @override
  String get days => 'days';

  @override
  String currentStreakBest(int count) {
    return 'Current streak - Best: $count days';
  }

  @override
  String goalDays(int count) {
    return 'Goal: $count days';
  }

  @override
  String get thisWeek => 'This week';

  @override
  String get streakMotivation =>
      'Great momentum! Keep it up to reach your goal.';

  @override
  String get scholarshipsForYou => 'Scholarships based on YOU';

  @override
  String get showMore => 'Show More';

  @override
  String get noScholarshipsFound => 'No scholarships found. Try showing more.';

  @override
  String get applyDetails => 'Apply Details';

  @override
  String get matchText => 'Match';

  @override
  String get explorePath => 'Explore path';

  @override
  String get mapText => 'Map';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get studentHub => 'Student Hub';

  @override
  String get searchHub => 'Search people, tags, or posts...';

  @override
  String get favorites => 'My Favorites';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumComparison => 'Premium Comparison';

  @override
  String get seeAll => 'See All';

  @override
  String get yourInterestCategoriesNcomparison =>
      'Your Interest Categories\nComparison';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get careerPathBasedOnYourCategories =>
      'Career path based on your categories';

  @override
  String get failedToGenerateCareerComparison =>
      'Failed to generate career comparison';

  @override
  String get coreTechnicalSkills => 'Core Technical Skills';

  @override
  String get by => 'by ';

  @override
  String get applyNow => 'Apply Now';

  @override
  String get requirementsChecklist => 'Requirements Checklist';

  @override
  String get quickFacts => 'Quick Facts';

  @override
  String get applicationRequirement => 'Application requirement';

  @override
  String get applicationProcess => 'Application Process';

  @override
  String get scholarshipExplorer => 'Scholarship Explorer';

  @override
  String get noScholarshipsFound1 => 'No scholarships found';

  @override
  String get scoutingScholarships => 'Scouting scholarships...';

  @override
  String get tryRefreshingOrChangingFilters =>
      'Try refreshing or changing filters';

  @override
  String get viewMoreScholarships => 'View More Scholarships';

  @override
  String get vs => 'VS';

  @override
  String
  get unlockDeepAiPoweredInsightsIntoDifferentUniversityMajorsAndCareerPathsWithOurPremiumPlan =>
      'Unlock deep AI-powered insights into different university majors and career paths with our Premium plan.';

  @override
  String
  get exploreDetailedInsightsAboutYourSelectedFieldsAndDiscoverWhichPathAlignsBestWithYourGoals =>
      'Explore detailed insights about your selected fields and discover which path aligns best with your goals.';

  @override
  String get postCreatedSuccessfully => 'Post created successfully!';

  @override
  String get addDescriptiveTags => 'Add descriptive tags...';

  @override
  String get postUpdatedSuccessfully => 'Post updated successfully!';

  @override
  String get recommendedTags => 'Recommended Tags:';

  @override
  String get pleaseFillInTitleAndContent => 'Please fill in title and content';

  @override
  String get postTitle => 'Post Title';

  @override
  String get hot => 'Hot';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get postDeletedSuccessfully => 'Post deleted successfully!';

  @override
  String get editPost => 'Edit Post';

  @override
  String get areYouSureYouWantToDeleteThisComment =>
      'Are you sure you want to delete this comment?';

  @override
  String get save => 'Save';

  @override
  String get commentDeletedSuccessfully => 'Comment deleted successfully!';

  @override
  String get failedToLikePost => 'Failed to like post';

  @override
  String get reply => 'Reply';

  @override
  String get postNotFound => 'Post not found';

  @override
  String get deleteComment => 'Delete Comment';

  @override
  String get editComment => 'Edit Comment';

  @override
  String get editYourComment => 'Edit your comment...';

  @override
  String get whatsOnYourMind => 'What\'s on your mind?';

  @override
  String get createPost => 'Create Post';

  @override
  String get postAction => 'Post';

  @override
  String get peopleWithTheSameInterest => 'People with the same interest';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get noPostsYetBeTheFirstToPost =>
      'No posts yet. Be the first to post!';

  @override
  String get failedToUpdateLike => 'Failed to update like';

  @override
  String friendRequestSentTo(Object name) {
    return 'Friend request sent to $name';
  }

  @override
  String get failedToSendRequest => 'Failed to send request';

  @override
  String get areYouSureYouWantToDeleteThisPostThisActionCannotBeUndone =>
      'Are you sure you want to delete this post? This action cannot be undone.';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get friendRequestSent => 'Friend request sent!';

  @override
  String get pending => 'Pending';

  @override
  String get friends => 'Friends';

  @override
  String get likes => 'Likes';

  @override
  String viewsWithCount(Object count) {
    return '$count views';
  }

  @override
  String commentsWithCount(Object count) {
    return 'Comments ($count)';
  }

  @override
  String get replyingTo => 'Replying to ';

  @override
  String get addAReply => 'Add a reply...';

  @override
  String get writeAComment => 'Write a comment...';

  @override
  String errorAddingComment(Object error) {
    return 'Error adding comment: $error';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String likedYourPost(Object name) {
    return '$name liked your post.';
  }

  @override
  String commentedOnYourPost(Object name) {
    return '$name commented on your post.';
  }

  @override
  String likedYourComment(Object name) {
    return '$name liked your comment.';
  }

  @override
  String repliedToYourComment(Object name) {
    return '$name replied to your comment.';
  }

  @override
  String sentYouAFriendRequestTapToRespond(Object name) {
    return '$name sent you a friend request. Tap to respond.';
  }

  @override
  String acceptedYourFriendRequestYouAreNowFriends(Object name) {
    return '$name accepted your friend request. You are now friends!';
  }

  @override
  String youAndNameAreNowFriends(Object name) {
    return 'You and $name are now friends.';
  }

  @override
  String interactedWithYourProfile(Object name) {
    return '$name interacted with your profile.';
  }

  @override
  String sentYouANotification(Object name) {
    return '$name sent you a notification.';
  }

  @override
  String get messages => 'Messages';

  @override
  String get searchPeople => 'Search people...';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get startAConversation => 'Start a conversation';

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Video';

  @override
  String get voiceMessage => 'Voice message';

  @override
  String get gif => 'GIF';

  @override
  String get sticker => 'Sticker';

  @override
  String get failedToStartConversation => 'Failed to start conversation';

  @override
  String replyingToName(Object name) {
    return 'Replying to $name';
  }

  @override
  String get media => 'Media';

  @override
  String get sending => 'Sending...';

  @override
  String get edited => 'Edited';

  @override
  String get file => 'File';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get lastSeenJustNow => 'Last seen just now';

  @override
  String lastSeenMinsAgo(Object count) {
    return 'Last seen $count mins ago';
  }

  @override
  String lastSeenHoursAgo(Object count) {
    return 'Last seen $count hours ago';
  }

  @override
  String lastSeenTimeAgo(Object time) {
    return 'Last seen $time';
  }

  @override
  String get seen => 'Seen';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get editMessage => 'Edit message...';

  @override
  String get content => 'Content';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get profilePictureUpdated => 'Profile picture updated!';

  @override
  String errorUploadingImage(Object error) {
    return 'Error uploading image: $error';
  }

  @override
  String get userNotFound => 'User not found';

  @override
  String get posts => 'posts';

  @override
  String get editBio => 'Edit Bio';

  @override
  String get addBio => 'Add Bio';

  @override
  String get requested => 'Requested';

  @override
  String get acceptRequest => 'Accept Request';

  @override
  String get unfriend => 'Unfriend';

  @override
  String get addPost => 'Add Post';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get friendRequestSentExclamation => 'Friend request sent!';

  @override
  String failedToSendRequestWithError(Object error) {
    return 'Failed to send request: $error';
  }

  @override
  String get accept => 'Accept';

  @override
  String get message => 'Message';

  @override
  String get refreshCache => 'Refresh Cache';

  @override
  String get all => 'All';

  @override
  String get national => 'National';

  @override
  String get international => 'International';

  @override
  String get scholarship => 'Scholarship';

  @override
  String get provider => 'Provider';

  @override
  String get benefit => 'Benefit';

  @override
  String get eligibility => 'Eligibility';

  @override
  String get deadline => 'Deadline';

  @override
  String get awardAmount => 'Award Amount';

  @override
  String get applicants => 'Applicants';

  @override
  String get pacing => 'Pacing';

  @override
  String get scholarshipType => 'Type';

  @override
  String about(Object name) {
    return 'About $name';
  }

  @override
  String youAreOnStep(Object current, Object total) {
    return 'You are currently on step $current of $total.';
  }

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get stemAndTech => 'Stem & Tech';

  @override
  String get businessInterest => 'Business';

  @override
  String get health => 'Health';

  @override
  String get education => 'Education';

  @override
  String get craftmanship => 'Craftmanship';

  @override
  String get publicService => 'Public Service';

  @override
  String get artsAndDesign => 'Arts & Design';

  @override
  String get averageSalary => 'Average Salary';

  @override
  String get marketDemand => 'Market Demand';

  @override
  String get workLifeBalance => 'Work/Life Balance';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get competitive => 'Competitive';

  @override
  String get veryHigh => 'Very High';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get personalGrowthJourney => 'Your Personal Growth Journey';

  @override
  String get todayQuote => 'Today\'s Quote';

  @override
  String get daysStreak => 'Day Streak';

  @override
  String get journalEntries => 'Journal Entries';

  @override
  String get totalInsights => 'Total Insights';

  @override
  String get growth => 'Growth';

  @override
  String get personalityTest => 'Personality Test';

  @override
  String get viewFullProfile => 'View your full profile';

  @override
  String get discoverYourTraits => 'Discover your traits';

  @override
  String get manifestYourFuture => 'Manifest your future';

  @override
  String get reflectionJournal => 'Reflection Journal';

  @override
  String get documentYourGrowth => 'Document your growth';

  @override
  String get expressYourself => 'Express yourself';

  @override
  String get journeyMap => 'Journey Map';

  @override
  String get noGoalsYetTapToAdd => 'No goals yet — tap to add one!';

  @override
  String goalsCompleted(Object completed, Object total) {
    return '$completed of $total goals completed';
  }

  @override
  String get aiMindChat => 'AI Mind Chat';

  @override
  String get getPersonalizedGuidance => 'Get personalized guidance';

  @override
  String get startChat => 'Start Chat';

  @override
  String get mindfulBreathing => 'Mindful Breathing';

  @override
  String get futureMap => 'Future Map';

  @override
  String get overallProgress => 'OVERALL PROGRESS';

  @override
  String get nextDue => 'NEXT DUE';

  @override
  String overdueCount(Object count) {
    return '$count Overdue';
  }

  @override
  String get statusAll => 'All';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get categoryFilter => 'Category';

  @override
  String get filterByCategory => 'Filter by Category';

  @override
  String get showGoalsFromSpecificArea => 'Show goals from a specific area';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get completedThisWeek => 'Completed This Week';

  @override
  String get lastWeek => 'Last week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get earlier => 'Earlier';

  @override
  String get noGoalsFound => 'No goals found';

  @override
  String get captureFutureGoalsToGrow =>
      'Capture your future goals and track your progress to grow every day.';

  @override
  String get addYourFirstGoal => 'Add Your First Goal';

  @override
  String get retake => 'Retake';

  @override
  String get yourDimensions => 'Your Dimensions';

  @override
  String get strengths => 'Strengths';

  @override
  String get growthAreas => 'Growth Areas';

  @override
  String get careerPaths => 'Career Paths';

  @override
  String get inRelationships => 'In Relationships';

  @override
  String famousPeopleOfType(Object type) {
    return 'Famous ${type}s';
  }

  @override
  String get backToHome => 'Back to Home';

  @override
  String get extraverted => 'Extraverted';

  @override
  String get introverted => 'Introverted';

  @override
  String get sensing => 'Sensing';

  @override
  String get intuitive => 'Intuitive';

  @override
  String get thinking => 'Thinking';

  @override
  String get feeling => 'Feeling';

  @override
  String get judging => 'Judging';

  @override
  String get perceiving => 'Perceiving';

  @override
  String get addAPicture => 'Add a picture';

  @override
  String get chooseHowToAddImage => 'Choose how you want to add your image';

  @override
  String get pickFromPhotos => 'Pick from your photos';

  @override
  String get takeNewPhoto => 'Take a new photo';

  @override
  String get editCard => 'Edit Card';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get rotation => 'Rotation';

  @override
  String get captionOptional => 'Caption (optional)';

  @override
  String get searchForInspiration => 'Search for inspiration...';

  @override
  String noResultsFor(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get visionBoardEmpty => 'Your vision board is empty';

  @override
  String get tapToAddFirstImage => 'Tap + to add your first image';

  @override
  String get poweredByGemini => 'Powered by Google Gemini 2.0';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get freeLimitReached =>
      'Free limit reached for today. Upgrade for more.';

  @override
  String get aiGreeting =>
      'Hello! I am your AI Mind Guide. How are you feeling today?';

  @override
  String aiError(Object error) {
    return 'I\'m having trouble connecting right now (Error: $error). Let\'s reflect on this a bit later.';
  }

  @override
  String get emoticon => 'Emoticon';

  @override
  String get findYourVibe => 'Find your vibe…';

  @override
  String get searchResults => 'Search Results';

  @override
  String get myCustom => 'My Custom';

  @override
  String get clear => 'Clear';

  @override
  String get clearRecents => 'Clear Recents';

  @override
  String get removeAllRecentEmoticons => 'Remove all recent emoticons?';

  @override
  String get customize => 'Customize';

  @override
  String get noEmoticonsFound => 'No emoticons found';

  @override
  String get copiedToClipboard => 'Copied to clipboard!';

  @override
  String get deleteCustomEmoticon => 'Delete Custom Emoticon';

  @override
  String removeFaceFromCustomList(Object face) {
    return 'Remove \"$face\" from your custom list?';
  }

  @override
  String get catAll => 'All';

  @override
  String get catHappy => 'Happy';

  @override
  String get catLove => 'Love';

  @override
  String get catSad => 'Sad';

  @override
  String get catAngry => 'Angry';

  @override
  String get catSleepy => 'Sleepy';

  @override
  String get catHugging => 'Hugging';

  @override
  String get catExcited => 'Excited';

  @override
  String get catEmbarrassed => 'Embarrassed';

  @override
  String get catSurprised => 'Surprised';

  @override
  String get catConfused => 'Confused';

  @override
  String get catGreeting => 'Greeting';

  @override
  String get catWinking => 'Winking';

  @override
  String get createEmoticon => 'Create Emoticon';

  @override
  String get preview => 'Preview';

  @override
  String get leftArm => 'Left Arm';

  @override
  String get eyes => 'Eyes';

  @override
  String get mouth => 'Mouth';

  @override
  String get rightArm => 'Right Arm';

  @override
  String get extras => 'Extras';

  @override
  String get category => 'Category';

  @override
  String get saveEmoticon => 'Save Emoticon';

  @override
  String get customEmoticonSaved => 'Custom emoticon saved!';

  @override
  String get none => 'none';

  @override
  String get myJournal => 'My Journal';

  @override
  String get searchYourEntries => 'Search your entries...';

  @override
  String get showingArchivedEntries => 'Showing archived entries';

  @override
  String get noEntriesFound => 'No entries found';

  @override
  String get noJournalEntriesYet => 'No journal entries yet.\nStart writing ✨';

  @override
  String get older => 'Older';

  @override
  String get hideArchived => 'Hide archived';

  @override
  String get showArchived => 'Show archived';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodGood => 'Good';

  @override
  String get moodOkay => 'Okay';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodBad => 'Bad';

  @override
  String get nerisTypeExplorer => 'NERIS Type Explorer';

  @override
  String get discoverWhoYouAre => 'Discover Who You Are';

  @override
  String get personalityTestDesc =>
      'Answer 70 questions to uncover your unique personality type from 16 possible profiles. There are no right or wrong answers.';

  @override
  String get beforeYouBegin => 'Before You Begin';

  @override
  String get beYourself => 'Be yourself';

  @override
  String get beYourselfDesc =>
      'Answer as who you are, not who you want to be seen as.';

  @override
  String get answerQuickly => 'Answer quickly';

  @override
  String get answerQuicklyDesc =>
      'Go with your first instinct. Don\'t overthink each question.';

  @override
  String get gainSelfAwareness => 'Gain self-awareness';

  @override
  String get gainSelfAwarenessDesc =>
      'Learn how your personality shapes your career, relationships, and strengths.';

  @override
  String get fifteenMinutes => '15 minutes';

  @override
  String get fifteenMinutesDesc =>
      '70 questions across 14 pages. You can go back and change answers.';

  @override
  String get questions => 'Questions';

  @override
  String get types => 'Types';

  @override
  String get dimensions => 'Dimensions';

  @override
  String get startTest => 'Start Test';

  @override
  String get pleaseAnswerAllQuestions =>
      'Please answer all questions on this page';

  @override
  String pageOf(Object current, Object total) {
    return 'Page $current of $total';
  }

  @override
  String tasksCompleted(Object count) {
    return '$count/70 Tasks';
  }

  @override
  String get exit => 'Exit';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get seeResults => 'See Results';

  @override
  String get or => 'or';

  @override
  String get editReflection => 'Edit Reflection';

  @override
  String get myDailyReflection => 'My daily reflection';

  @override
  String get howAreYouFeelingToday => 'How are you feeling today?';

  @override
  String get journalEntry => 'Journal Entry';

  @override
  String get journalEntrySubtitle => 'Let your journey brighten your path.';

  @override
  String get title => 'Title';

  @override
  String get startWritingYourThoughts => 'Start writing your thoughts...';

  @override
  String get updateReflection => 'Update Reflection';

  @override
  String get saveReflection => 'Save Reflection';

  @override
  String get pleaseFillBothTitleAndContent =>
      'Please fill in both title and content';

  @override
  String get updatedSuccessfully => 'Updated successfully! ✅';

  @override
  String get savedSuccessfully => 'Saved successfully! ✅';

  @override
  String errorSavingEntry(Object error) {
    return 'Error saving entry: $error';
  }

  @override
  String get deleteEntry => 'Delete Entry';

  @override
  String get deleteEntryConfirm =>
      'Are you sure you want to delete this journal entry? This action cannot be undone.';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get entryArchived => 'Entry archived';

  @override
  String get entryUnarchived => 'Entry unarchived';

  @override
  String get archived => 'Archived';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get goalTitle => 'Goal Title';

  @override
  String get description => 'Description';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get buildFirstWebPageHint => 'e.g. Build First Web App';

  @override
  String get whatDoYouWantToAchieveHint => 'What do you want to achieve?';

  @override
  String get catStudy => 'Study';

  @override
  String get catProject => 'Project';

  @override
  String get catCareer => 'Career';

  @override
  String get catPersonal => 'Personal';

  @override
  String get catOther => 'Other';

  @override
  String get catEducation => 'Education';

  @override
  String get catHealth => 'Health';

  @override
  String get studyHint => 'assignments, exams, homework';

  @override
  String get projectHint => 'school projects, coding projects';

  @override
  String get careerHint => 'internships, portfolio, job prep';

  @override
  String get personalHint => 'habits, self-development, new skills';

  @override
  String get otherHint => 'general goals';

  @override
  String get currentProgress => 'Current Progress';

  @override
  String get goals => 'Goals';

  @override
  String get status => 'Status';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get overdue => 'Overdue';

  @override
  String get tapToAddGoal => 'Tap + to add your first goal';

  @override
  String get stats => 'Stats';

  @override
  String goalsCompletedCount(Object count) {
    return '$count Goals completed';
  }

  @override
  String get activeFilter => 'Active Filter';

  @override
  String get clearFilter => 'Clear';

  @override
  String get addMilestone => 'Add Milestone';

  @override
  String get noGoalsMatch => 'No goals match';

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get tryChangingFilters => 'Try changing your filters.';

  @override
  String get nothingPendingRightNow =>
      'Nothing pending right now —\ncheck the Completed tab for your history.';

  @override
  String get tapAddMilestoneBelow =>
      'Tap \"Add Milestone\" below\nto set your first goal!';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get done => 'Done';

  @override
  String get stickerStudio => 'Sticker Studio';

  @override
  String get searchPublicStickers => 'Search public stickers...';

  @override
  String get publicStore => 'Public Store';

  @override
  String get myStickers => 'My Stickers';

  @override
  String get createSticker => 'Create Sticker';

  @override
  String get failedToLoadStickers => 'Failed to load stickers';

  @override
  String get noPublicStickersFound => 'No public stickers found';

  @override
  String get haventCreatedStickersYet =>
      'You haven\'t created any stickers yet';

  @override
  String get stickerLinkCopied => 'Sticker link copied!';

  @override
  String get copyLink => 'Copy Link';

  @override
  String createdBy(Object name) {
    return 'Created by $name';
  }

  @override
  String get backgroundRemovedSuccessfully =>
      'Background removed successfully!';

  @override
  String get selectImageAndEnterName =>
      'Please select an image and enter a name';

  @override
  String get failedToSaveSticker => 'Failed to save sticker';

  @override
  String get selectAPhoto => 'Select a Photo';

  @override
  String get objectSelected => 'Object Selected';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get alphaMask => 'Alpha Mask';

  @override
  String get collectionSettings => 'Collection Settings';

  @override
  String get stickerName => 'Sticker Name';

  @override
  String get stickerNameHint => 'e.g., Happy Cat, Super Cool...';

  @override
  String get makePublic => 'Make Public';

  @override
  String get makePublicSubtitle =>
      'Public stickers can be searched and used by everyone';

  @override
  String get finishAndAddToCollection => 'Finish & Add to Collection';

  @override
  String get analyzingDepth => 'Analyzing depth...';

  @override
  String typeLabel(Object type) {
    return 'Type: $type';
  }

  @override
  String get quote1 => 'Your journey is unique, treat it with kindness.';

  @override
  String get quote1Title => 'Inner Peace';

  @override
  String get quote2 => 'Growth is a process, not a destination.';

  @override
  String get quote2Title => 'Steady Growth';

  @override
  String get quote3 => 'Believe in your potential to change.';

  @override
  String get quote3Title => 'Self Belief';

  @override
  String get freeAccess => 'Free Access';

  @override
  String messagesLeftToday(Object count) {
    return '$count messages left today';
  }

  @override
  String get upgradeForMore => 'Upgrade for more';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get areYouSureYouWantToClearChat =>
      'Are you sure you want to clear the chat history?';

  @override
  String get personalization => 'Personalization';

  @override
  String get updateInterests => 'Update Interests';

  @override
  String get updateInterestsSub => 'Change your career recommendations';

  @override
  String get myFavoritesSub => 'Saved scholarships and posts';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get editProfileInfo => 'Edit Profile Information';

  @override
  String get manageSubscription => 'Subscription';

  @override
  String get manageSubscriptionSub => 'Manage your plan';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivity => 'No recent activities yet.';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkAesthetic => 'Using dark aesthetic';

  @override
  String get lightAesthetic => 'Using light aesthetic';

  @override
  String get changePassword => 'Change Password';

  @override
  String get signOut => 'Sign Out';

  @override
  String get premium => 'Premium';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get communityPost => 'Community Post';

  @override
  String get favoritedItem => 'Favorited Item';

  @override
  String get viewedScholarship => 'Viewed Scholarship';

  @override
  String get unknownActivity => 'Unknown Activity';

  @override
  String get updateAccountInfo => 'Update your account information.';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get setNewPassword => 'Set New Password';

  @override
  String get updateSecurityCredentials =>
      'Update your current security credentials.';

  @override
  String get createSecurePassword =>
      'Create a secure password for your new account.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get forgotCurrentPassword => 'Forgot your current password?';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get enterCurrentPassword => 'Please enter your current password';

  @override
  String get enterNewPassword => 'Please enter a new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully!';

  @override
  String get pricingTitle => 'Pricing';

  @override
  String get chooseBestPlan => 'Choose the best plan';

  @override
  String get aiAccessTitle => 'AI Access';

  @override
  String get otherAccessTitle => 'Other Access';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get oneTime => 'One-Time';

  @override
  String get pickPlan => 'Pick the plan';

  @override
  String get youSubscribed => 'You subscribe to this plan';

  @override
  String get freePlanSub => 'Best for exploring and daily reflection';

  @override
  String get premiumPlanSub => 'Best for ongoing self-discovery and growth';

  @override
  String get focusedPackSub => 'Best for students who need clarity now';

  @override
  String get after7Days => 'After 7 days';

  @override
  String get passwordHint => 'Enter current password';

  @override
  String get retypePasswordHint => 'Retype new password';

  @override
  String get min6CharsHint => 'Min. 6 characters';

  @override
  String get currentPasswordHint => 'Enter current password';
}
