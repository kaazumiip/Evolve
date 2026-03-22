import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Evolve'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @insight.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get insight;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @postHub.
  ///
  /// In en, this message translates to:
  /// **'Post Hub'**
  String get postHub;

  /// No description provided for @careerRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Career Roadmap'**
  String get careerRoadmap;

  /// No description provided for @saveRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Save Roadmap'**
  String get saveRoadmap;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMap;

  /// No description provided for @normalDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Normal Day in Field'**
  String get normalDayTitle;

  /// No description provided for @developmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Development & Promotion'**
  String get developmentTitle;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get addComment;

  /// No description provided for @addReply.
  ///
  /// In en, this message translates to:
  /// **'Add a reply...'**
  String get addReply;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDelete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @visionBoard.
  ///
  /// In en, this message translates to:
  /// **'Vision board'**
  String get visionBoard;

  /// No description provided for @visionHub.
  ///
  /// In en, this message translates to:
  /// **'Vision Hub'**
  String get visionHub;

  /// No description provided for @emoticons.
  ///
  /// In en, this message translates to:
  /// **'Emoticons'**
  String get emoticons;

  /// No description provided for @recents.
  ///
  /// In en, this message translates to:
  /// **'Recents'**
  String get recents;

  /// No description provided for @trendingKawaii.
  ///
  /// In en, this message translates to:
  /// **'Trending Kawaii'**
  String get trendingKawaii;

  /// No description provided for @searchEmoticons.
  ///
  /// In en, this message translates to:
  /// **'Search Emoticons...'**
  String get searchEmoticons;

  /// No description provided for @addVision.
  ///
  /// In en, this message translates to:
  /// **'Add to Vision Board'**
  String get addVision;

  /// No description provided for @visionsCreated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No Visions} =1{1 Vision Created} other{{count} Visions Created}}'**
  String visionsCreated(int count);

  /// No description provided for @storiesRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No Entries} =1{1 Story Recorded} other{{count} Stories Recorded}}'**
  String storiesRecorded(int count);

  /// No description provided for @vibesSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Find your vibe} =1{1 Vibe Saved} other{{count} Vibes Saved}}'**
  String vibesSaved(int count);

  /// No description provided for @savedToCache.
  ///
  /// In en, this message translates to:
  /// **'Saved to cache'**
  String get savedToCache;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save to cache'**
  String get failedToSave;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @roadmap.
  ///
  /// In en, this message translates to:
  /// **'Roadmap'**
  String get roadmap;

  /// No description provided for @learningResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get learningResources;

  /// No description provided for @topCompanies.
  ///
  /// In en, this message translates to:
  /// **'Top Hiring Companies'**
  String get topCompanies;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @unlockRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Decisions Pack'**
  String get unlockRoadmap;

  /// No description provided for @streakDay.
  ///
  /// In en, this message translates to:
  /// **'Streak Day'**
  String get streakDay;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @currentStreakBest.
  ///
  /// In en, this message translates to:
  /// **'Current streak - Best: {count} days'**
  String currentStreakBest(int count);

  /// No description provided for @goalDays.
  ///
  /// In en, this message translates to:
  /// **'Goal: {count} days'**
  String goalDays(int count);

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @streakMotivation.
  ///
  /// In en, this message translates to:
  /// **'Great momentum! Keep it up to reach your goal.'**
  String get streakMotivation;

  /// No description provided for @scholarshipsForYou.
  ///
  /// In en, this message translates to:
  /// **'Scholarships based on YOU'**
  String get scholarshipsForYou;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @noScholarshipsFound.
  ///
  /// In en, this message translates to:
  /// **'No scholarships found. Try showing more.'**
  String get noScholarshipsFound;

  /// No description provided for @applyDetails.
  ///
  /// In en, this message translates to:
  /// **'Apply Details'**
  String get applyDetails;

  /// No description provided for @matchText.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchText;

  /// No description provided for @explorePath.
  ///
  /// In en, this message translates to:
  /// **'Explore path'**
  String get explorePath;

  /// No description provided for @mapText.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapText;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @studentHub.
  ///
  /// In en, this message translates to:
  /// **'Student Hub'**
  String get studentHub;

  /// No description provided for @searchHub.
  ///
  /// In en, this message translates to:
  /// **'Search people, tags, or posts...'**
  String get searchHub;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get favorites;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumComparison.
  ///
  /// In en, this message translates to:
  /// **'Premium Comparison'**
  String get premiumComparison;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @yourInterestCategoriesNcomparison.
  ///
  /// In en, this message translates to:
  /// **'Your Interest Categories\nComparison'**
  String get yourInterestCategoriesNcomparison;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @careerPathBasedOnYourCategories.
  ///
  /// In en, this message translates to:
  /// **'Career path based on your categories'**
  String get careerPathBasedOnYourCategories;

  /// No description provided for @failedToGenerateCareerComparison.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate career comparison'**
  String get failedToGenerateCareerComparison;

  /// No description provided for @coreTechnicalSkills.
  ///
  /// In en, this message translates to:
  /// **'Core Technical Skills'**
  String get coreTechnicalSkills;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'by '**
  String get by;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @requirementsChecklist.
  ///
  /// In en, this message translates to:
  /// **'Requirements Checklist'**
  String get requirementsChecklist;

  /// No description provided for @quickFacts.
  ///
  /// In en, this message translates to:
  /// **'Quick Facts'**
  String get quickFacts;

  /// No description provided for @applicationRequirement.
  ///
  /// In en, this message translates to:
  /// **'Application requirement'**
  String get applicationRequirement;

  /// No description provided for @applicationProcess.
  ///
  /// In en, this message translates to:
  /// **'Application Process'**
  String get applicationProcess;

  /// No description provided for @scholarshipExplorer.
  ///
  /// In en, this message translates to:
  /// **'Scholarship Explorer'**
  String get scholarshipExplorer;

  /// No description provided for @noScholarshipsFound1.
  ///
  /// In en, this message translates to:
  /// **'No scholarships found'**
  String get noScholarshipsFound1;

  /// No description provided for @scoutingScholarships.
  ///
  /// In en, this message translates to:
  /// **'Scouting scholarships...'**
  String get scoutingScholarships;

  /// No description provided for @tryRefreshingOrChangingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try refreshing or changing filters'**
  String get tryRefreshingOrChangingFilters;

  /// No description provided for @viewMoreScholarships.
  ///
  /// In en, this message translates to:
  /// **'View More Scholarships'**
  String get viewMoreScholarships;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get vs;

  /// No description provided for @unlockDeepAiPoweredInsightsIntoDifferentUniversityMajorsAndCareerPathsWithOurPremiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Unlock deep AI-powered insights into different university majors and career paths with our Premium plan.'**
  String
  get unlockDeepAiPoweredInsightsIntoDifferentUniversityMajorsAndCareerPathsWithOurPremiumPlan;

  /// No description provided for @exploreDetailedInsightsAboutYourSelectedFieldsAndDiscoverWhichPathAlignsBestWithYourGoals.
  ///
  /// In en, this message translates to:
  /// **'Explore detailed insights about your selected fields and discover which path aligns best with your goals.'**
  String
  get exploreDetailedInsightsAboutYourSelectedFieldsAndDiscoverWhichPathAlignsBestWithYourGoals;

  /// No description provided for @postCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully!'**
  String get postCreatedSuccessfully;

  /// No description provided for @addDescriptiveTags.
  ///
  /// In en, this message translates to:
  /// **'Add descriptive tags...'**
  String get addDescriptiveTags;

  /// No description provided for @postUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post updated successfully!'**
  String get postUpdatedSuccessfully;

  /// No description provided for @recommendedTags.
  ///
  /// In en, this message translates to:
  /// **'Recommended Tags:'**
  String get recommendedTags;

  /// No description provided for @pleaseFillInTitleAndContent.
  ///
  /// In en, this message translates to:
  /// **'Please fill in title and content'**
  String get pleaseFillInTitleAndContent;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Title'**
  String get postTitle;

  /// No description provided for @hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @postDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully!'**
  String get postDeletedSuccessfully;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @areYouSureYouWantToDeleteThisComment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get areYouSureYouWantToDeleteThisComment;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @commentDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted successfully!'**
  String get commentDeletedSuccessfully;

  /// No description provided for @failedToLikePost.
  ///
  /// In en, this message translates to:
  /// **'Failed to like post'**
  String get failedToLikePost;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @postNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found'**
  String get postNotFound;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @editComment.
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get editComment;

  /// No description provided for @editYourComment.
  ///
  /// In en, this message translates to:
  /// **'Edit your comment...'**
  String get editYourComment;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @postAction.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postAction;

  /// No description provided for @peopleWithTheSameInterest.
  ///
  /// In en, this message translates to:
  /// **'People with the same interest'**
  String get peopleWithTheSameInterest;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @noPostsYetBeTheFirstToPost.
  ///
  /// In en, this message translates to:
  /// **'No posts yet. Be the first to post!'**
  String get noPostsYetBeTheFirstToPost;

  /// No description provided for @failedToUpdateLike.
  ///
  /// In en, this message translates to:
  /// **'Failed to update like'**
  String get failedToUpdateLike;

  /// No description provided for @friendRequestSentTo.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent to {name}'**
  String friendRequestSentTo(Object name);

  /// No description provided for @failedToSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request'**
  String get failedToSendRequest;

  /// No description provided for @areYouSureYouWantToDeleteThisPostThisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post? This action cannot be undone.'**
  String get areYouSureYouWantToDeleteThisPostThisActionCannotBeUndone;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent!'**
  String get friendRequestSent;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @viewsWithCount.
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String viewsWithCount(Object count);

  /// No description provided for @commentsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Comments ({count})'**
  String commentsWithCount(Object count);

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to '**
  String get replyingTo;

  /// No description provided for @addAReply.
  ///
  /// In en, this message translates to:
  /// **'Add a reply...'**
  String get addAReply;

  /// No description provided for @writeAComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeAComment;

  /// No description provided for @errorAddingComment.
  ///
  /// In en, this message translates to:
  /// **'Error adding comment: {error}'**
  String errorAddingComment(Object error);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @likedYourPost.
  ///
  /// In en, this message translates to:
  /// **'{name} liked your post.'**
  String likedYourPost(Object name);

  /// No description provided for @commentedOnYourPost.
  ///
  /// In en, this message translates to:
  /// **'{name} commented on your post.'**
  String commentedOnYourPost(Object name);

  /// No description provided for @likedYourComment.
  ///
  /// In en, this message translates to:
  /// **'{name} liked your comment.'**
  String likedYourComment(Object name);

  /// No description provided for @repliedToYourComment.
  ///
  /// In en, this message translates to:
  /// **'{name} replied to your comment.'**
  String repliedToYourComment(Object name);

  /// No description provided for @sentYouAFriendRequestTapToRespond.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a friend request. Tap to respond.'**
  String sentYouAFriendRequestTapToRespond(Object name);

  /// No description provided for @acceptedYourFriendRequestYouAreNowFriends.
  ///
  /// In en, this message translates to:
  /// **'{name} accepted your friend request. You are now friends!'**
  String acceptedYourFriendRequestYouAreNowFriends(Object name);

  /// No description provided for @youAndNameAreNowFriends.
  ///
  /// In en, this message translates to:
  /// **'You and {name} are now friends.'**
  String youAndNameAreNowFriends(Object name);

  /// No description provided for @interactedWithYourProfile.
  ///
  /// In en, this message translates to:
  /// **'{name} interacted with your profile.'**
  String interactedWithYourProfile(Object name);

  /// No description provided for @sentYouANotification.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a notification.'**
  String sentYouANotification(Object name);

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people...'**
  String get searchPeople;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @startAConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startAConversation;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @voiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get voiceMessage;

  /// No description provided for @gif.
  ///
  /// In en, this message translates to:
  /// **'GIF'**
  String get gif;

  /// No description provided for @sticker.
  ///
  /// In en, this message translates to:
  /// **'Sticker'**
  String get sticker;

  /// No description provided for @failedToStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Failed to start conversation'**
  String get failedToStartConversation;

  /// No description provided for @replyingToName.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String replyingToName(Object name);

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @tapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get tapToOpen;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @lastSeenJustNow.
  ///
  /// In en, this message translates to:
  /// **'Last seen just now'**
  String get lastSeenJustNow;

  /// No description provided for @lastSeenMinsAgo.
  ///
  /// In en, this message translates to:
  /// **'Last seen {count} mins ago'**
  String lastSeenMinsAgo(Object count);

  /// No description provided for @lastSeenHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Last seen {count} hours ago'**
  String lastSeenHoursAgo(Object count);

  /// No description provided for @lastSeenTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String lastSeenTimeAgo(Object time);

  /// No description provided for @seen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get seen;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit message...'**
  String get editMessage;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profilePictureUpdated;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image: {error}'**
  String errorUploadingImage(Object error);

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'posts'**
  String get posts;

  /// No description provided for @editBio.
  ///
  /// In en, this message translates to:
  /// **'Edit Bio'**
  String get editBio;

  /// No description provided for @addBio.
  ///
  /// In en, this message translates to:
  /// **'Add Bio'**
  String get addBio;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequest;

  /// No description provided for @unfriend.
  ///
  /// In en, this message translates to:
  /// **'Unfriend'**
  String get unfriend;

  /// No description provided for @addPost.
  ///
  /// In en, this message translates to:
  /// **'Add Post'**
  String get addPost;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @friendRequestSentExclamation.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent!'**
  String get friendRequestSentExclamation;

  /// No description provided for @failedToSendRequestWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request: {error}'**
  String failedToSendRequestWithError(Object error);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @refreshCache.
  ///
  /// In en, this message translates to:
  /// **'Refresh Cache'**
  String get refreshCache;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @national.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get national;

  /// No description provided for @international.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get international;

  /// No description provided for @scholarship.
  ///
  /// In en, this message translates to:
  /// **'Scholarship'**
  String get scholarship;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @benefit.
  ///
  /// In en, this message translates to:
  /// **'Benefit'**
  String get benefit;

  /// No description provided for @eligibility.
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get eligibility;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @awardAmount.
  ///
  /// In en, this message translates to:
  /// **'Award Amount'**
  String get awardAmount;

  /// No description provided for @applicants.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicants;

  /// No description provided for @pacing.
  ///
  /// In en, this message translates to:
  /// **'Pacing'**
  String get pacing;

  /// No description provided for @scholarshipType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get scholarshipType;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About {name}'**
  String about(Object name);

  /// No description provided for @youAreOnStep.
  ///
  /// In en, this message translates to:
  /// **'You are currently on step {current} of {total}.'**
  String youAreOnStep(Object current, Object total);

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @stemAndTech.
  ///
  /// In en, this message translates to:
  /// **'Stem & Tech'**
  String get stemAndTech;

  /// No description provided for @businessInterest.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessInterest;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @craftmanship.
  ///
  /// In en, this message translates to:
  /// **'Craftmanship'**
  String get craftmanship;

  /// No description provided for @publicService.
  ///
  /// In en, this message translates to:
  /// **'Public Service'**
  String get publicService;

  /// No description provided for @artsAndDesign.
  ///
  /// In en, this message translates to:
  /// **'Arts & Design'**
  String get artsAndDesign;

  /// No description provided for @averageSalary.
  ///
  /// In en, this message translates to:
  /// **'Average Salary'**
  String get averageSalary;

  /// No description provided for @marketDemand.
  ///
  /// In en, this message translates to:
  /// **'Market Demand'**
  String get marketDemand;

  /// No description provided for @workLifeBalance.
  ///
  /// In en, this message translates to:
  /// **'Work/Life Balance'**
  String get workLifeBalance;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @competitive.
  ///
  /// In en, this message translates to:
  /// **'Competitive'**
  String get competitive;

  /// No description provided for @veryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get veryHigh;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @personalGrowthJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Growth Journey'**
  String get personalGrowthJourney;

  /// No description provided for @todayQuote.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Quote'**
  String get todayQuote;

  /// No description provided for @daysStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get daysStreak;

  /// No description provided for @journalEntries.
  ///
  /// In en, this message translates to:
  /// **'Journal Entries'**
  String get journalEntries;

  /// No description provided for @totalInsights.
  ///
  /// In en, this message translates to:
  /// **'Total Insights'**
  String get totalInsights;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @personalityTest.
  ///
  /// In en, this message translates to:
  /// **'Personality Test'**
  String get personalityTest;

  /// No description provided for @viewFullProfile.
  ///
  /// In en, this message translates to:
  /// **'View your full profile'**
  String get viewFullProfile;

  /// No description provided for @discoverYourTraits.
  ///
  /// In en, this message translates to:
  /// **'Discover your traits'**
  String get discoverYourTraits;

  /// No description provided for @manifestYourFuture.
  ///
  /// In en, this message translates to:
  /// **'Manifest your future'**
  String get manifestYourFuture;

  /// No description provided for @reflectionJournal.
  ///
  /// In en, this message translates to:
  /// **'Reflection Journal'**
  String get reflectionJournal;

  /// No description provided for @documentYourGrowth.
  ///
  /// In en, this message translates to:
  /// **'Document your growth'**
  String get documentYourGrowth;

  /// No description provided for @expressYourself.
  ///
  /// In en, this message translates to:
  /// **'Express yourself'**
  String get expressYourself;

  /// No description provided for @journeyMap.
  ///
  /// In en, this message translates to:
  /// **'Journey Map'**
  String get journeyMap;

  /// No description provided for @noGoalsYetTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'No goals yet — tap to add one!'**
  String get noGoalsYetTapToAdd;

  /// No description provided for @goalsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} goals completed'**
  String goalsCompleted(Object completed, Object total);

  /// No description provided for @aiMindChat.
  ///
  /// In en, this message translates to:
  /// **'AI Mind Chat'**
  String get aiMindChat;

  /// No description provided for @getPersonalizedGuidance.
  ///
  /// In en, this message translates to:
  /// **'Get personalized guidance'**
  String get getPersonalizedGuidance;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @mindfulBreathing.
  ///
  /// In en, this message translates to:
  /// **'Mindful Breathing'**
  String get mindfulBreathing;

  /// No description provided for @futureMap.
  ///
  /// In en, this message translates to:
  /// **'Future Map'**
  String get futureMap;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'OVERALL PROGRESS'**
  String get overallProgress;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'NEXT DUE'**
  String get nextDue;

  /// No description provided for @overdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Overdue'**
  String overdueCount(Object count);

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @categoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryFilter;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @showGoalsFromSpecificArea.
  ///
  /// In en, this message translates to:
  /// **'Show goals from a specific area'**
  String get showGoalsFromSpecificArea;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Completed This Week'**
  String get completedThisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @noGoalsFound.
  ///
  /// In en, this message translates to:
  /// **'No goals found'**
  String get noGoalsFound;

  /// No description provided for @captureFutureGoalsToGrow.
  ///
  /// In en, this message translates to:
  /// **'Capture your future goals and track your progress to grow every day.'**
  String get captureFutureGoalsToGrow;

  /// No description provided for @addYourFirstGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Goal'**
  String get addYourFirstGoal;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @yourDimensions.
  ///
  /// In en, this message translates to:
  /// **'Your Dimensions'**
  String get yourDimensions;

  /// No description provided for @strengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get strengths;

  /// No description provided for @growthAreas.
  ///
  /// In en, this message translates to:
  /// **'Growth Areas'**
  String get growthAreas;

  /// No description provided for @careerPaths.
  ///
  /// In en, this message translates to:
  /// **'Career Paths'**
  String get careerPaths;

  /// No description provided for @inRelationships.
  ///
  /// In en, this message translates to:
  /// **'In Relationships'**
  String get inRelationships;

  /// No description provided for @famousPeopleOfType.
  ///
  /// In en, this message translates to:
  /// **'Famous {type}s'**
  String famousPeopleOfType(Object type);

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @extraverted.
  ///
  /// In en, this message translates to:
  /// **'Extraverted'**
  String get extraverted;

  /// No description provided for @introverted.
  ///
  /// In en, this message translates to:
  /// **'Introverted'**
  String get introverted;

  /// No description provided for @sensing.
  ///
  /// In en, this message translates to:
  /// **'Sensing'**
  String get sensing;

  /// No description provided for @intuitive.
  ///
  /// In en, this message translates to:
  /// **'Intuitive'**
  String get intuitive;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @feeling.
  ///
  /// In en, this message translates to:
  /// **'Feeling'**
  String get feeling;

  /// No description provided for @judging.
  ///
  /// In en, this message translates to:
  /// **'Judging'**
  String get judging;

  /// No description provided for @perceiving.
  ///
  /// In en, this message translates to:
  /// **'Perceiving'**
  String get perceiving;

  /// No description provided for @addAPicture.
  ///
  /// In en, this message translates to:
  /// **'Add a picture'**
  String get addAPicture;

  /// No description provided for @chooseHowToAddImage.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add your image'**
  String get chooseHowToAddImage;

  /// No description provided for @pickFromPhotos.
  ///
  /// In en, this message translates to:
  /// **'Pick from your photos'**
  String get pickFromPhotos;

  /// No description provided for @takeNewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo'**
  String get takeNewPhoto;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @rotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get rotation;

  /// No description provided for @captionOptional.
  ///
  /// In en, this message translates to:
  /// **'Caption (optional)'**
  String get captionOptional;

  /// No description provided for @searchForInspiration.
  ///
  /// In en, this message translates to:
  /// **'Search for inspiration...'**
  String get searchForInspiration;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(Object query);

  /// No description provided for @visionBoardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your vision board is empty'**
  String get visionBoardEmpty;

  /// No description provided for @tapToAddFirstImage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first image'**
  String get tapToAddFirstImage;

  /// No description provided for @poweredByGemini.
  ///
  /// In en, this message translates to:
  /// **'Powered by Google Gemini 2.0'**
  String get poweredByGemini;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @freeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free limit reached for today. Upgrade for more.'**
  String get freeLimitReached;

  /// No description provided for @aiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I am your AI Mind Guide. How are you feeling today?'**
  String get aiGreeting;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'I\'m having trouble connecting right now (Error: {error}). Let\'s reflect on this a bit later.'**
  String aiError(Object error);

  /// No description provided for @emoticon.
  ///
  /// In en, this message translates to:
  /// **'Emoticon'**
  String get emoticon;

  /// No description provided for @findYourVibe.
  ///
  /// In en, this message translates to:
  /// **'Find your vibe…'**
  String get findYourVibe;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @myCustom.
  ///
  /// In en, this message translates to:
  /// **'My Custom'**
  String get myCustom;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearRecents.
  ///
  /// In en, this message translates to:
  /// **'Clear Recents'**
  String get clearRecents;

  /// No description provided for @removeAllRecentEmoticons.
  ///
  /// In en, this message translates to:
  /// **'Remove all recent emoticons?'**
  String get removeAllRecentEmoticons;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @noEmoticonsFound.
  ///
  /// In en, this message translates to:
  /// **'No emoticons found'**
  String get noEmoticonsFound;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @deleteCustomEmoticon.
  ///
  /// In en, this message translates to:
  /// **'Delete Custom Emoticon'**
  String get deleteCustomEmoticon;

  /// No description provided for @removeFaceFromCustomList.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{face}\" from your custom list?'**
  String removeFaceFromCustomList(Object face);

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get catHappy;

  /// No description provided for @catLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get catLove;

  /// No description provided for @catSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get catSad;

  /// No description provided for @catAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get catAngry;

  /// No description provided for @catSleepy.
  ///
  /// In en, this message translates to:
  /// **'Sleepy'**
  String get catSleepy;

  /// No description provided for @catHugging.
  ///
  /// In en, this message translates to:
  /// **'Hugging'**
  String get catHugging;

  /// No description provided for @catExcited.
  ///
  /// In en, this message translates to:
  /// **'Excited'**
  String get catExcited;

  /// No description provided for @catEmbarrassed.
  ///
  /// In en, this message translates to:
  /// **'Embarrassed'**
  String get catEmbarrassed;

  /// No description provided for @catSurprised.
  ///
  /// In en, this message translates to:
  /// **'Surprised'**
  String get catSurprised;

  /// No description provided for @catConfused.
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get catConfused;

  /// No description provided for @catGreeting.
  ///
  /// In en, this message translates to:
  /// **'Greeting'**
  String get catGreeting;

  /// No description provided for @catWinking.
  ///
  /// In en, this message translates to:
  /// **'Winking'**
  String get catWinking;

  /// No description provided for @createEmoticon.
  ///
  /// In en, this message translates to:
  /// **'Create Emoticon'**
  String get createEmoticon;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @leftArm.
  ///
  /// In en, this message translates to:
  /// **'Left Arm'**
  String get leftArm;

  /// No description provided for @eyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get eyes;

  /// No description provided for @mouth.
  ///
  /// In en, this message translates to:
  /// **'Mouth'**
  String get mouth;

  /// No description provided for @rightArm.
  ///
  /// In en, this message translates to:
  /// **'Right Arm'**
  String get rightArm;

  /// No description provided for @extras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get extras;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @saveEmoticon.
  ///
  /// In en, this message translates to:
  /// **'Save Emoticon'**
  String get saveEmoticon;

  /// No description provided for @customEmoticonSaved.
  ///
  /// In en, this message translates to:
  /// **'Custom emoticon saved!'**
  String get customEmoticonSaved;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get none;

  /// No description provided for @myJournal.
  ///
  /// In en, this message translates to:
  /// **'My Journal'**
  String get myJournal;

  /// No description provided for @searchYourEntries.
  ///
  /// In en, this message translates to:
  /// **'Search your entries...'**
  String get searchYourEntries;

  /// No description provided for @showingArchivedEntries.
  ///
  /// In en, this message translates to:
  /// **'Showing archived entries'**
  String get showingArchivedEntries;

  /// No description provided for @noEntriesFound.
  ///
  /// In en, this message translates to:
  /// **'No entries found'**
  String get noEntriesFound;

  /// No description provided for @noJournalEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet.\nStart writing ✨'**
  String get noJournalEntriesYet;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// No description provided for @hideArchived.
  ///
  /// In en, this message translates to:
  /// **'Hide archived'**
  String get hideArchived;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// No description provided for @moodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get moodBad;

  /// No description provided for @nerisTypeExplorer.
  ///
  /// In en, this message translates to:
  /// **'NERIS Type Explorer'**
  String get nerisTypeExplorer;

  /// No description provided for @discoverWhoYouAre.
  ///
  /// In en, this message translates to:
  /// **'Discover Who You Are'**
  String get discoverWhoYouAre;

  /// No description provided for @personalityTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer 70 questions to uncover your unique personality type from 16 possible profiles. There are no right or wrong answers.'**
  String get personalityTestDesc;

  /// No description provided for @beforeYouBegin.
  ///
  /// In en, this message translates to:
  /// **'Before You Begin'**
  String get beforeYouBegin;

  /// No description provided for @beYourself.
  ///
  /// In en, this message translates to:
  /// **'Be yourself'**
  String get beYourself;

  /// No description provided for @beYourselfDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer as who you are, not who you want to be seen as.'**
  String get beYourselfDesc;

  /// No description provided for @answerQuickly.
  ///
  /// In en, this message translates to:
  /// **'Answer quickly'**
  String get answerQuickly;

  /// No description provided for @answerQuicklyDesc.
  ///
  /// In en, this message translates to:
  /// **'Go with your first instinct. Don\'t overthink each question.'**
  String get answerQuicklyDesc;

  /// No description provided for @gainSelfAwareness.
  ///
  /// In en, this message translates to:
  /// **'Gain self-awareness'**
  String get gainSelfAwareness;

  /// No description provided for @gainSelfAwarenessDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn how your personality shapes your career, relationships, and strengths.'**
  String get gainSelfAwarenessDesc;

  /// No description provided for @fifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get fifteenMinutes;

  /// No description provided for @fifteenMinutesDesc.
  ///
  /// In en, this message translates to:
  /// **'70 questions across 14 pages. You can go back and change answers.'**
  String get fifteenMinutesDesc;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @types.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get types;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get startTest;

  /// No description provided for @pleaseAnswerAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'Please answer all questions on this page'**
  String get pleaseAnswerAllQuestions;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(Object current, Object total);

  /// No description provided for @tasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count}/70 Tasks'**
  String tasksCompleted(Object count);

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @seeResults.
  ///
  /// In en, this message translates to:
  /// **'See Results'**
  String get seeResults;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @editReflection.
  ///
  /// In en, this message translates to:
  /// **'Edit Reflection'**
  String get editReflection;

  /// No description provided for @myDailyReflection.
  ///
  /// In en, this message translates to:
  /// **'My daily reflection'**
  String get myDailyReflection;

  /// No description provided for @howAreYouFeelingToday.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeelingToday;

  /// No description provided for @journalEntry.
  ///
  /// In en, this message translates to:
  /// **'Journal Entry'**
  String get journalEntry;

  /// No description provided for @journalEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let your journey brighten your path.'**
  String get journalEntrySubtitle;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @startWritingYourThoughts.
  ///
  /// In en, this message translates to:
  /// **'Start writing your thoughts...'**
  String get startWritingYourThoughts;

  /// No description provided for @updateReflection.
  ///
  /// In en, this message translates to:
  /// **'Update Reflection'**
  String get updateReflection;

  /// No description provided for @saveReflection.
  ///
  /// In en, this message translates to:
  /// **'Save Reflection'**
  String get saveReflection;

  /// No description provided for @pleaseFillBothTitleAndContent.
  ///
  /// In en, this message translates to:
  /// **'Please fill in both title and content'**
  String get pleaseFillBothTitleAndContent;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully! ✅'**
  String get updatedSuccessfully;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully! ✅'**
  String get savedSuccessfully;

  /// No description provided for @errorSavingEntry.
  ///
  /// In en, this message translates to:
  /// **'Error saving entry: {error}'**
  String errorSavingEntry(Object error);

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteEntry;

  /// No description provided for @deleteEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this journal entry? This action cannot be undone.'**
  String get deleteEntryConfirm;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @entryArchived.
  ///
  /// In en, this message translates to:
  /// **'Entry archived'**
  String get entryArchived;

  /// No description provided for @entryUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Entry unarchived'**
  String get entryUnarchived;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Title'**
  String get goalTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @buildFirstWebPageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Build First Web App'**
  String get buildFirstWebPageHint;

  /// No description provided for @whatDoYouWantToAchieveHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to achieve?'**
  String get whatDoYouWantToAchieveHint;

  /// No description provided for @catStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get catStudy;

  /// No description provided for @catProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get catProject;

  /// No description provided for @catCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get catCareer;

  /// No description provided for @catPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get catPersonal;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @studyHint.
  ///
  /// In en, this message translates to:
  /// **'assignments, exams, homework'**
  String get studyHint;

  /// No description provided for @projectHint.
  ///
  /// In en, this message translates to:
  /// **'school projects, coding projects'**
  String get projectHint;

  /// No description provided for @careerHint.
  ///
  /// In en, this message translates to:
  /// **'internships, portfolio, job prep'**
  String get careerHint;

  /// No description provided for @personalHint.
  ///
  /// In en, this message translates to:
  /// **'habits, self-development, new skills'**
  String get personalHint;

  /// No description provided for @otherHint.
  ///
  /// In en, this message translates to:
  /// **'general goals'**
  String get otherHint;

  /// No description provided for @currentProgress.
  ///
  /// In en, this message translates to:
  /// **'Current Progress'**
  String get currentProgress;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @tapToAddGoal.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first goal'**
  String get tapToAddGoal;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @goalsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Goals completed'**
  String goalsCompletedCount(Object count);

  /// No description provided for @activeFilter.
  ///
  /// In en, this message translates to:
  /// **'Active Filter'**
  String get activeFilter;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilter;

  /// No description provided for @addMilestone.
  ///
  /// In en, this message translates to:
  /// **'Add Milestone'**
  String get addMilestone;

  /// No description provided for @noGoalsMatch.
  ///
  /// In en, this message translates to:
  /// **'No goals match'**
  String get noGoalsMatch;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoalsYet;

  /// No description provided for @tryChangingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try changing your filters.'**
  String get tryChangingFilters;

  /// No description provided for @nothingPendingRightNow.
  ///
  /// In en, this message translates to:
  /// **'Nothing pending right now —\ncheck the Completed tab for your history.'**
  String get nothingPendingRightNow;

  /// No description provided for @tapAddMilestoneBelow.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Milestone\" below\nto set your first goal!'**
  String get tapAddMilestoneBelow;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @stickerStudio.
  ///
  /// In en, this message translates to:
  /// **'Sticker Studio'**
  String get stickerStudio;

  /// No description provided for @searchPublicStickers.
  ///
  /// In en, this message translates to:
  /// **'Search public stickers...'**
  String get searchPublicStickers;

  /// No description provided for @publicStore.
  ///
  /// In en, this message translates to:
  /// **'Public Store'**
  String get publicStore;

  /// No description provided for @myStickers.
  ///
  /// In en, this message translates to:
  /// **'My Stickers'**
  String get myStickers;

  /// No description provided for @createSticker.
  ///
  /// In en, this message translates to:
  /// **'Create Sticker'**
  String get createSticker;

  /// No description provided for @failedToLoadStickers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stickers'**
  String get failedToLoadStickers;

  /// No description provided for @noPublicStickersFound.
  ///
  /// In en, this message translates to:
  /// **'No public stickers found'**
  String get noPublicStickersFound;

  /// No description provided for @haventCreatedStickersYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any stickers yet'**
  String get haventCreatedStickersYet;

  /// No description provided for @stickerLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Sticker link copied!'**
  String get stickerLinkCopied;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {name}'**
  String createdBy(Object name);

  /// No description provided for @backgroundRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Background removed successfully!'**
  String get backgroundRemovedSuccessfully;

  /// No description provided for @selectImageAndEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please select an image and enter a name'**
  String get selectImageAndEnterName;

  /// No description provided for @failedToSaveSticker.
  ///
  /// In en, this message translates to:
  /// **'Failed to save sticker'**
  String get failedToSaveSticker;

  /// No description provided for @selectAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select a Photo'**
  String get selectAPhoto;

  /// No description provided for @objectSelected.
  ///
  /// In en, this message translates to:
  /// **'Object Selected'**
  String get objectSelected;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @alphaMask.
  ///
  /// In en, this message translates to:
  /// **'Alpha Mask'**
  String get alphaMask;

  /// No description provided for @collectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Collection Settings'**
  String get collectionSettings;

  /// No description provided for @stickerName.
  ///
  /// In en, this message translates to:
  /// **'Sticker Name'**
  String get stickerName;

  /// No description provided for @stickerNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Happy Cat, Super Cool...'**
  String get stickerNameHint;

  /// No description provided for @makePublic.
  ///
  /// In en, this message translates to:
  /// **'Make Public'**
  String get makePublic;

  /// No description provided for @makePublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Public stickers can be searched and used by everyone'**
  String get makePublicSubtitle;

  /// No description provided for @finishAndAddToCollection.
  ///
  /// In en, this message translates to:
  /// **'Finish & Add to Collection'**
  String get finishAndAddToCollection;

  /// No description provided for @analyzingDepth.
  ///
  /// In en, this message translates to:
  /// **'Analyzing depth...'**
  String get analyzingDepth;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String typeLabel(Object type);

  /// No description provided for @quote1.
  ///
  /// In en, this message translates to:
  /// **'Your journey is unique, treat it with kindness.'**
  String get quote1;

  /// No description provided for @quote1Title.
  ///
  /// In en, this message translates to:
  /// **'Inner Peace'**
  String get quote1Title;

  /// No description provided for @quote2.
  ///
  /// In en, this message translates to:
  /// **'Growth is a process, not a destination.'**
  String get quote2;

  /// No description provided for @quote2Title.
  ///
  /// In en, this message translates to:
  /// **'Steady Growth'**
  String get quote2Title;

  /// No description provided for @quote3.
  ///
  /// In en, this message translates to:
  /// **'Believe in your potential to change.'**
  String get quote3;

  /// No description provided for @quote3Title.
  ///
  /// In en, this message translates to:
  /// **'Self Belief'**
  String get quote3Title;

  /// No description provided for @freeAccess.
  ///
  /// In en, this message translates to:
  /// **'Free Access'**
  String get freeAccess;

  /// No description provided for @messagesLeftToday.
  ///
  /// In en, this message translates to:
  /// **'{count} messages left today'**
  String messagesLeftToday(Object count);

  /// No description provided for @upgradeForMore.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for more'**
  String get upgradeForMore;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @areYouSureYouWantToClearChat.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the chat history?'**
  String get areYouSureYouWantToClearChat;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @updateInterests.
  ///
  /// In en, this message translates to:
  /// **'Update Interests'**
  String get updateInterests;

  /// No description provided for @updateInterestsSub.
  ///
  /// In en, this message translates to:
  /// **'Change your career recommendations'**
  String get updateInterestsSub;

  /// No description provided for @myFavoritesSub.
  ///
  /// In en, this message translates to:
  /// **'Saved scholarships and posts'**
  String get myFavoritesSub;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @editProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Information'**
  String get editProfileInfo;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get manageSubscription;

  /// No description provided for @manageSubscriptionSub.
  ///
  /// In en, this message translates to:
  /// **'Manage your plan'**
  String get manageSubscriptionSub;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activities yet.'**
  String get noRecentActivity;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkAesthetic.
  ///
  /// In en, this message translates to:
  /// **'Using dark aesthetic'**
  String get darkAesthetic;

  /// No description provided for @lightAesthetic.
  ///
  /// In en, this message translates to:
  /// **'Using light aesthetic'**
  String get lightAesthetic;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @communityPost.
  ///
  /// In en, this message translates to:
  /// **'Community Post'**
  String get communityPost;

  /// No description provided for @favoritedItem.
  ///
  /// In en, this message translates to:
  /// **'Favorited Item'**
  String get favoritedItem;

  /// No description provided for @viewedScholarship.
  ///
  /// In en, this message translates to:
  /// **'Viewed Scholarship'**
  String get viewedScholarship;

  /// No description provided for @unknownActivity.
  ///
  /// In en, this message translates to:
  /// **'Unknown Activity'**
  String get unknownActivity;

  /// No description provided for @updateAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your account information.'**
  String get updateAccountInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @updateSecurityCredentials.
  ///
  /// In en, this message translates to:
  /// **'Update your current security credentials.'**
  String get updateSecurityCredentials;

  /// No description provided for @createSecurePassword.
  ///
  /// In en, this message translates to:
  /// **'Create a secure password for your new account.'**
  String get createSecurePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @forgotCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your current password?'**
  String get forgotCurrentPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get enterNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @pricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricingTitle;

  /// No description provided for @chooseBestPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose the best plan'**
  String get chooseBestPlan;

  /// No description provided for @aiAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Access'**
  String get aiAccessTitle;

  /// No description provided for @otherAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Access'**
  String get otherAccessTitle;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One-Time'**
  String get oneTime;

  /// No description provided for @pickPlan.
  ///
  /// In en, this message translates to:
  /// **'Pick the plan'**
  String get pickPlan;

  /// No description provided for @youSubscribed.
  ///
  /// In en, this message translates to:
  /// **'You subscribe to this plan'**
  String get youSubscribed;

  /// No description provided for @freePlanSub.
  ///
  /// In en, this message translates to:
  /// **'Best for exploring and daily reflection'**
  String get freePlanSub;

  /// No description provided for @premiumPlanSub.
  ///
  /// In en, this message translates to:
  /// **'Best for ongoing self-discovery and growth'**
  String get premiumPlanSub;

  /// No description provided for @focusedPackSub.
  ///
  /// In en, this message translates to:
  /// **'Best for students who need clarity now'**
  String get focusedPackSub;

  /// No description provided for @after7Days.
  ///
  /// In en, this message translates to:
  /// **'After 7 days'**
  String get after7Days;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get passwordHint;

  /// No description provided for @retypePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Retype new password'**
  String get retypePasswordHint;

  /// No description provided for @min6CharsHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters'**
  String get min6CharsHint;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get currentPasswordHint;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @tabScholarships.
  ///
  /// In en, this message translates to:
  /// **'Scholarships'**
  String get tabScholarships;

  /// No description provided for @tabPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get tabPosts;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites saved yet.'**
  String get noFavoritesYet;

  /// No description provided for @noSavedScholarships.
  ///
  /// In en, this message translates to:
  /// **'No saved scholarships.'**
  String get noSavedScholarships;

  /// No description provided for @noSavedPosts.
  ///
  /// In en, this message translates to:
  /// **'No saved posts.'**
  String get noSavedPosts;

  /// No description provided for @variesLabel.
  ///
  /// In en, this message translates to:
  /// **'Varies'**
  String get variesLabel;

  /// No description provided for @openLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
