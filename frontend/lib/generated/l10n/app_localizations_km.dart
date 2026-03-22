// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'Evolve';

  @override
  String get home => 'ទំព័រដើម';

  @override
  String get explore => 'រុករក';

  @override
  String get insight => 'ការយល់ដឹង';

  @override
  String get community => 'សហគមន៍';

  @override
  String get profile => 'ប្រវត្តិរូប';

  @override
  String get postHub => 'មជ្ឈមណ្ឌលបង្ហោះ';

  @override
  String get careerRoadmap => 'ផែនទីអាជីព';

  @override
  String get saveRoadmap => 'រក្សាទុកផែនទី';

  @override
  String get viewMap => 'មើលផែនទី';

  @override
  String get normalDayTitle => 'ថ្ងៃធម្មតាក្នុងវិស័យ';

  @override
  String get developmentTitle => 'ការអភិវឌ្ឍន៍ និងការតម្លើងតំណែង';

  @override
  String get addComment => 'បញ្ចេញមតិ...';

  @override
  String get addReply => 'បន្ថែមកាឆ្លើយតប...';

  @override
  String get send => 'ផ្ញើ';

  @override
  String get like => 'ចូលចិត្ត';

  @override
  String get comment => 'មតិ';

  @override
  String get share => 'ចែករំលែក';

  @override
  String get edit => 'កែសម្រួល';

  @override
  String get delete => 'លុប';

  @override
  String get confirmDelete => 'តើអ្នកប្រាកដជាចង់លុបមែនទេ?';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get yes => 'បាទ/ចាស';

  @override
  String get no => 'ទេ';

  @override
  String get loading => 'កំពុងផ្ទុក...';

  @override
  String error(String error) {
    return 'កំហុស: $error';
  }

  @override
  String get noData => 'មិនមានទិន្នន័យ';

  @override
  String get visionBoard => 'ផ្ទាំងទស្សនវិស័យ';

  @override
  String get visionHub => 'មជ្ឈមណ្ឌលចក្ខុវិស័យ';

  @override
  String get emoticons => 'រូបអារម្មណ៍';

  @override
  String get recents => 'កាលពីថ្មីៗ';

  @override
  String get trendingKawaii => 'រូបអារម្មណ៍ដែលពេញនិយម';

  @override
  String get searchEmoticons => 'ស្វែងរករូបអារម្មណ៍...';

  @override
  String get addVision => 'បន្ថែមទៅក្តារចក្ខុវិស័យ';

  @override
  String visionsCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ចក្ខុវិស័យ',
      one: '១ ចក្ខុវិស័យ',
      zero: 'គ្មានចក្ខុវិស័យ',
    );
    return '$_temp0';
  }

  @override
  String storiesRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count រឿង',
      one: '១ រឿង',
      zero: 'គ្មានរឿង',
    );
    return '$_temp0';
  }

  @override
  String vibesSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count រូបអារម្មណ៍',
      one: '១ រូបអារម្មណ៍',
      zero: 'ស្វែងរកអារម្មណ៍',
    );
    return '$_temp0';
  }

  @override
  String get savedToCache => 'បានរក្សាទុកក្នុងកន្លែងផ្ទុក';

  @override
  String get failedToSave => 'បរាជ័យក្នុងការរក្សាទុកកន្លែងផ្ទុក';

  @override
  String get overview => 'ទិដ្ឋភាពទូទៅ';

  @override
  String get roadmap => 'ផែនទីបង្ហាញផ្លូវ';

  @override
  String get learningResources => 'ធនធានសិក្សា';

  @override
  String get topCompanies => 'ក្រុមហ៊ុនកំពូលៗកំពុងស្វែងរកបុគ្គលិក';

  @override
  String get premiumFeature => 'មុខងារពិសេស';

  @override
  String get unlockRoadmap => 'ដោះសោជាមួយកញ្ចប់ Decisions Pack';

  @override
  String get streakDay => 'ថ្ងៃបន្តបន្ទាប់';

  @override
  String get days => 'ថ្ងៃ';

  @override
  String currentStreakBest(int count) {
    return 'ការតស៊ូបច្ចុប្បន្ន - ល្អបំផុត: $count ថ្ងៃ';
  }

  @override
  String goalDays(int count) {
    return 'គោលដៅ: $count ថ្ងៃ';
  }

  @override
  String get thisWeek => 'សប្តាហ៍នេះ';

  @override
  String get streakMotivation =>
      'សន្ទុះដ៏អស្ចារ្យ! បន្តដំណើរទៅមុខទៀតដើម្បីសម្រេចគោលដៅរបស់អ្នក។';

  @override
  String get scholarshipsForYou => 'អាហារូបករណ៍ផ្អែកលើអ្នក';

  @override
  String get showMore => 'បង្ហាញបន្ថែម';

  @override
  String get noScholarshipsFound =>
      'រកមិនឃើញអាហារូបករណ៍ទេ។ ព្យាយាមបង្ហាញបន្ថែម។';

  @override
  String get applyDetails => 'ពត៌មានលម្អិតសម្រាប់ការដាក់ពាក្យ';

  @override
  String get matchText => 'សមស្រប';

  @override
  String get explorePath => 'រុករកផ្លូវសិក្សា';

  @override
  String get mapText => 'ផែនទី';

  @override
  String get mon => 'ច័ន្ទ';

  @override
  String get tue => 'អង្គារ';

  @override
  String get wed => 'ពុធ';

  @override
  String get thu => 'ព្រហស្បតិ៍';

  @override
  String get fri => 'សុក្រ';

  @override
  String get sat => 'សៅរ៍';

  @override
  String get sun => 'អាទិត្យ';

  @override
  String get studentHub => 'មជ្ឈមណ្ឌលនិស្សិត';

  @override
  String get searchHub => 'ស្វែងរកមនុស្ស ស្លាក ឬការបង្ហោះ...';

  @override
  String get favorites => 'សំណព្វរបស់ខ្ញុំ';

  @override
  String get upgradeToPremium => 'ដំឡើងឡើងទៅ Premium';

  @override
  String get premiumComparison => 'ការប្រៀបធៀប Premium';

  @override
  String get seeAll => 'មើលទាំងអស់';

  @override
  String get yourInterestCategoriesNcomparison =>
      'ការប្រៀបធៀបប្រភេទចំណាប់អារម្មណ៍របស់អ្នក';

  @override
  String get welcomeBack => 'ស្វាគមន៍ការត្រឡប់មកវិញ, ';

  @override
  String get careerPathBasedOnYourCategories => 'អាជីពផ្អែកលើប្រភេទរបស់អ្នក';

  @override
  String get failedToGenerateCareerComparison =>
      'បរាជ័យក្នុងការបង្កើតការប្រៀបធៀបអាជីព';

  @override
  String get coreTechnicalSkills => 'ជំនាញបច្ចេកទេសស្នូល';

  @override
  String get by => 'ដោយ';

  @override
  String get applyNow => 'ដាក់ពាក្យឥឡូវនេះ';

  @override
  String get requirementsChecklist => 'បញ្ជីត្រួតពិនិត្យតម្រូវការ';

  @override
  String get quickFacts => 'ព័ត៌មានរហ័ស';

  @override
  String get applicationRequirement => 'តម្រូវការដាក់ពាក្យ';

  @override
  String get applicationProcess => 'នីតិវិធីដាក់ពាក្យ';

  @override
  String get scholarshipExplorer => 'ស្វែងរកអាហារូបករណ៍';

  @override
  String get noScholarshipsFound1 => 'រកមិនឃើញអាហារូបករណ៍ទេ';

  @override
  String get scoutingScholarships => 'កំពុងស្វែងរកអាហារូបករណ៍...';

  @override
  String get tryRefreshingOrChangingFilters =>
      'ព្យាយាមបើកឡើងវិញ ឬផ្លាស់ប្តូរតម្រង';

  @override
  String get viewMoreScholarships => 'មើលអាហារូបករណ៍បន្ថែមទៀត';

  @override
  String get vs => 'VS';

  @override
  String
  get unlockDeepAiPoweredInsightsIntoDifferentUniversityMajorsAndCareerPathsWithOurPremiumPlan =>
      'ដោះសោការយល់ដឹងស៊ីជម្រៅអំពីជំនាញសាកលវិទ្យាល័យផ្សេងៗ និងផ្លូវអាជីពជាមួយគម្រោង Premium របស់យើង។';

  @override
  String
  get exploreDetailedInsightsAboutYourSelectedFieldsAndDiscoverWhichPathAlignsBestWithYourGoals =>
      'ស្វែងយល់លម្អិតអំពីវិស័យដែលអ្នកបានជ្រើសរើស ហើយស្វែងរកផ្លូវណាដែលសមស្របបំផុត។';

  @override
  String get postCreatedSuccessfully => 'ការបង្ហោះបានបង្កើតដោយជោគជ័យ!';

  @override
  String get addDescriptiveTags => 'បន្ថែមស្លាករៀបរាប់...';

  @override
  String get postUpdatedSuccessfully =>
      'ការបង្ហោះបានធ្វើបច្ចុប្បន្នភាពដោយជោគជ័យ!';

  @override
  String get recommendedTags => 'ស្លាកដែលបានណែនាំ:';

  @override
  String get pleaseFillInTitleAndContent => 'សូមបំពេញចំណងជើង និងខ្លឹមសារ';

  @override
  String get postTitle => 'ចំណងជើងការបង្ហោះ';

  @override
  String get hot => 'ពេញនិយម';

  @override
  String get deletePost => 'លុបការបង្ហោះ';

  @override
  String get postDeletedSuccessfully => 'ការបង្ហោះបានលុបដោយជោគជ័យ!';

  @override
  String get editPost => 'កែសម្រួលការបង្ហោះ';

  @override
  String get areYouSureYouWantToDeleteThisComment =>
      'តើអ្នកប្រាកដជាចង់លុបមតិទិះកៀននេះទេ?';

  @override
  String get save => 'រក្សាទុក';

  @override
  String get commentDeletedSuccessfully => 'មតិទិះកៀនបានលុបដោយជោគជ័យ!';

  @override
  String get failedToLikePost => 'បរាជ័យក្នុងការចុចចូលចិត្ត';

  @override
  String get reply => 'ឆ្លើយតប';

  @override
  String get postNotFound => 'រកមិនឃើញការបង្ហោះ';

  @override
  String get deleteComment => 'លុបមតិទិះកៀន';

  @override
  String get editComment => 'កែសម្រួលមតិទិះកៀន';

  @override
  String get editYourComment => 'កែសម្រួលមតិទិះកៀនរបស់អ្នក...';

  @override
  String get whatsOnYourMind => 'តើអ្នកកំពុងមានគំនិតអ្វី?';

  @override
  String get createPost => 'បង្កើតការបង្ហោះ';

  @override
  String get postAction => 'បង្ហោះ';

  @override
  String get peopleWithTheSameInterest => 'មនុស្សដែលមានចំណាប់អារម្មណ៍ដូចគ្នា';

  @override
  String get addFriend => 'បន្ថែមមិត្តភក្តិ';

  @override
  String get noPostsYetBeTheFirstToPost =>
      'មិនទាន់មានការបង្ហោះនៅឡើយទេ។ សូមក្លាយជាអ្នកដំបូងដែលបង្ហោះ!';

  @override
  String get failedToUpdateLike =>
      'បរាជ័យក្នុងការធ្វើបច្ចុប្បន្នភាពការចូលចិត្ត';

  @override
  String friendRequestSentTo(Object name) {
    return 'បេសកកម្មស្នើសុំណាមិត្តភក្តិត្រូវបានផ្ញើទៅកាន់ $name';
  }

  @override
  String get failedToSendRequest => 'បរាជ័យក្នុងការផ្ញើសំណើ';

  @override
  String get areYouSureYouWantToDeleteThisPostThisActionCannotBeUndone =>
      'តើអ្នកប្រាកដជាចង់លុបការបង្ហោះនេះទេ? សកម្មភាពនេះមិនអាចផ្លាស់ប្តូរវិញបានទេ។';

  @override
  String get noUsersFound => 'រកមិនឃើញអ្នកប្រើប្រាស់ទេ';

  @override
  String get friendRequestSent => 'សំណើសុំជាមិត្តភក្តិត្រូវបានផ្ញើ!';

  @override
  String get pending => 'កំពុងរង់ចាំ';

  @override
  String get friends => 'មិត្តភក្តិ';

  @override
  String get likes => 'ចូលចិត្ត';

  @override
  String viewsWithCount(Object count) {
    return '$count មើល';
  }

  @override
  String commentsWithCount(Object count) {
    return 'មតិទិះកៀន ($count)';
  }

  @override
  String get replyingTo => 'កំពុងឆ្លើយតបទៅកាន់ ';

  @override
  String get addAReply => 'បន្ថែមការឆ្លើយតប...';

  @override
  String get writeAComment => 'សរសេរមតិទិះកៀន...';

  @override
  String errorAddingComment(Object error) {
    return 'កំហុសក្នុងការបន្ថែមមតិទិះកៀន: $error';
  }

  @override
  String get notifications => 'ការជូនដំណឹង';

  @override
  String get markAllAsRead => 'សម្គាល់ទាំងអស់ថាបានអាន';

  @override
  String likedYourPost(Object name) {
    return '$name បានចូលចិត្តការបង្ហោះរបស់អ្នក។';
  }

  @override
  String commentedOnYourPost(Object name) {
    return '$name បានបញ្ចេញមតិលើការបង្ហោះរបស់អ្នក។';
  }

  @override
  String likedYourComment(Object name) {
    return '$name បានចូលចិត្តមតិរបស់អ្នក។';
  }

  @override
  String repliedToYourComment(Object name) {
    return '$name បានឆ្លើយតបនឹងមតិរបស់អ្នក។';
  }

  @override
  String sentYouAFriendRequestTapToRespond(Object name) {
    return '$name បានផ្ញើសំណើសុំជាមិត្តភក្តិ។ ប៉ះដើម្បីឆ្លើយតប។';
  }

  @override
  String acceptedYourFriendRequestYouAreNowFriends(Object name) {
    return '$name បានទទួលយកសំណើសុំជាមិត្តភក្តិរបស់អ្នក។ ឥឡូវនេះអ្នកជាមិត្តភក្តិនឹងគ្នា!';
  }

  @override
  String youAndNameAreNowFriends(Object name) {
    return 'អ្នក និង $name ឥឡូវនេះជាមិត្តភក្តិនឹងគ្នា។';
  }

  @override
  String interactedWithYourProfile(Object name) {
    return '$name បានធ្វើអន្តរកម្មជាមួយប្រវត្តិរូបរបស់អ្នក។';
  }

  @override
  String sentYouANotification(Object name) {
    return '$name បានផ្ញើការជូនដំណឹងដល់អ្នក។';
  }

  @override
  String get messages => 'សារ';

  @override
  String get searchPeople => 'ស្វែងរកមនុស្ស...';

  @override
  String get noConversationsYet => 'មិនទាន់មានការសន្ទនានៅឡើយទេ';

  @override
  String get startAConversation => 'ចាប់ផ្តើមការសន្ទនា';

  @override
  String get photo => 'រូបថត';

  @override
  String get video => 'វីដេអូ';

  @override
  String get voiceMessage => 'សារជាសំឡេង';

  @override
  String get gif => 'GIF';

  @override
  String get sticker => 'ស្ទីគ័រ';

  @override
  String get failedToStartConversation => 'បរាជ័យក្នុងការចាប់ផ្តើមការសន្ទនា';

  @override
  String replyingToName(Object name) {
    return 'កំពុងឆ្លើយតបទៅកាន់ $name';
  }

  @override
  String get media => 'មេឌៀ';

  @override
  String get sending => 'កំពុងផ្ញើ...';

  @override
  String get edited => 'បានកែសម្រួល';

  @override
  String get file => 'ឯកសារ';

  @override
  String get tapToOpen => 'ប៉ះដើម្បីបើក';

  @override
  String get typeAMessage => 'វាយសារ...';

  @override
  String get online => 'អនឡាញ';

  @override
  String get offline => 'អុហ្វឡាញ';

  @override
  String get lastSeenJustNow => 'បានឃើញចុងក្រោយមុននេះបន្តិច';

  @override
  String lastSeenMinsAgo(Object count) {
    return 'បានឃើញចុងក្រោយ $count នាទីមុន';
  }

  @override
  String lastSeenHoursAgo(Object count) {
    return 'បានឃើញចុងក្រោយ $count ម៉ោងមុន';
  }

  @override
  String lastSeenTimeAgo(Object time) {
    return 'បានឃើញចុងក្រោយ $time';
  }

  @override
  String get seen => 'បានឃើញ';

  @override
  String get gallery => 'វិចិត្រសាល';

  @override
  String get camera => 'កាមេរ៉ា';

  @override
  String get editMessage => 'កែសម្រួលសារ...';

  @override
  String get content => 'ខ្លឹមសារ';

  @override
  String get messageDeleted => 'សារត្រូវបានលុប';

  @override
  String get profilePictureUpdated =>
      'រូបភាពប្រវត្តិរូបត្រូវបានធ្វើបច្ចុប្បន្នភាព!';

  @override
  String errorUploadingImage(Object error) {
    return 'កំហុសក្នុងការផ្ទុករូបភាពឡើង: $error';
  }

  @override
  String get userNotFound => 'រកមិនឃើញអ្នកប្រើប្រាស់ទេ';

  @override
  String get posts => 'ការបង្ហោះ';

  @override
  String get editBio => 'កែសម្រួលជីវប្រវត្តិ';

  @override
  String get addBio => 'បន្ថែមជីវប្រវត្តិ';

  @override
  String get requested => 'បានស្នើរសុំ';

  @override
  String get acceptRequest => 'ទទួលយកការស្នើសុំ';

  @override
  String get unfriend => 'ឈប់ធ្វើជាមិត្ត';

  @override
  String get addPost => 'បន្ថែមការបង្ហោះ';

  @override
  String get noPostsYet => 'មិនទាន់មានការបង្ហោះនៅឡើយទេ';

  @override
  String get friendRequestSentExclamation => 'បានផ្ញើសំណើសុំជាមិត្តភក្តិ!';

  @override
  String failedToSendRequestWithError(Object error) {
    return 'ការផ្ញើសំណើមិនបានជោគជ័យ: $error';
  }

  @override
  String get accept => 'ទទួលយក';

  @override
  String get message => 'សារ';

  @override
  String get refreshCache => 'ធ្វើឱ្យស្រស់';

  @override
  String get all => 'ទាំងអស់';

  @override
  String get national => 'ជាតិ';

  @override
  String get international => 'អន្តរជាតិ';

  @override
  String get scholarship => 'អាហារូបករណ៍';

  @override
  String get provider => 'អ្នកផ្តល់អាហារូបករណ៍';

  @override
  String get benefit => 'អត្ថប្រយោជន៍';

  @override
  String get eligibility => 'លក្ខខណ្ឌវិនិច្ឆ័យ';

  @override
  String get deadline => 'កាលបរិច្ឆេទកំណត់';

  @override
  String get awardAmount => 'ទឹកប្រាក់រង្វាន់';

  @override
  String get applicants => 'ចំនួនអ្នកដាក់ពាក្យ';

  @override
  String get pacing => 'ល្បឿន';

  @override
  String get scholarshipType => 'ប្រភេទ';

  @override
  String about(Object name) {
    return 'អំពី $name';
  }

  @override
  String youAreOnStep(Object current, Object total) {
    return 'អ្នកកំពុងស្ថិតនៅជំហានទី $current នៃ $total។';
  }

  @override
  String get addedToFavorites => 'បានបន្ថែមទៅក្នុងចំណូលចិត្ត';

  @override
  String get removedFromFavorites => 'បានដកចេញពីចំណូលចិត្ត';

  @override
  String get stemAndTech => 'វិទ្យាសាស្ត្រ និងបច្ចេកវិទ្យា';

  @override
  String get businessInterest => 'ធុរកិច្ច';

  @override
  String get health => 'សុខភាព';

  @override
  String get education => 'ការអប់រំ';

  @override
  String get craftmanship => 'សិប្បកម្ម';

  @override
  String get publicService => 'សេវាសាធារណៈ';

  @override
  String get artsAndDesign => 'សិល្បៈ និងការរចនា';

  @override
  String get averageSalary => 'ប្រាក់បៀវត្សរ៍មធ្យម';

  @override
  String get marketDemand => 'តម្រូវការទីផ្សារ';

  @override
  String get workLifeBalance => 'តុល្យភាពការងារ និងជីវិត';

  @override
  String get high => 'ខ្ពស់';

  @override
  String get medium => 'មធ្យម';

  @override
  String get low => 'ទាប';

  @override
  String get competitive => 'មានការប្រកួតប្រជែង';

  @override
  String get veryHigh => 'ខ្ពស់ខ្លាំង';

  @override
  String get excellent => 'ល្អឥតខ្ចោះ';

  @override
  String get good => 'ល្អ';

  @override
  String get personalGrowthJourney => 'ដំណើរនៃការលូតលាស់ផ្ទាល់ខ្លួនរបស់អ្នក';

  @override
  String get todayQuote => 'សម្រង់សម្តីសម្រាប់ថ្ងៃនេះ';

  @override
  String get daysStreak => 'ចំនួនថ្ងៃបន្តបន្ទាប់';

  @override
  String get journalEntries => 'កំណត់ហេតុដែលបានកត់ត្រា';

  @override
  String get totalInsights => 'ការយល់ដឹងសរុប';

  @override
  String get growth => 'ការលូតលាស់';

  @override
  String get personalityTest => 'ការសាកល្បងបុគ្គលិកលក្ខណៈ';

  @override
  String get viewFullProfile => 'មើលប្រវត្តិរូបពេញលេញរបស់អ្នក';

  @override
  String get discoverYourTraits => 'ស្វែងយល់ពីលក្ខណៈរបស់អ្នក';

  @override
  String get manifestYourFuture => 'បង្ហាញពីអនាគតរបស់អ្នក';

  @override
  String get reflectionJournal => 'កំណត់ហេតុឆ្លុះបញ្ចាំង';

  @override
  String get documentYourGrowth => 'កត់ត្រាការលូតលាស់របស់អ្នក';

  @override
  String get expressYourself => 'បញ្ចេញមតិរបស់អ្នក';

  @override
  String get journeyMap => 'ផែនទីដំណើរ';

  @override
  String get noGoalsYetTapToAdd => 'មិនទាន់មានគោលដៅនៅឡើយទេ — ចុចដើម្បីបន្ថែម!';

  @override
  String goalsCompleted(Object completed, Object total) {
    return 'សម្រេចបានគោលដៅ $completed ក្នុងចំណោម $total';
  }

  @override
  String get aiMindChat => 'ការជជែកជាមួយ AI Mind';

  @override
  String get getPersonalizedGuidance => 'ទទួលបានការណែនាំដែលសមស្របសម្រាប់អ្នក';

  @override
  String get startChat => 'ចាប់ផ្តើមការជជែក';

  @override
  String get mindfulBreathing => 'ការដកដង្ហើមដោយស្មារតី';

  @override
  String get futureMap => 'ផែនទីអនាគត';

  @override
  String get overallProgress => 'វឌ្ឍនភាពសរុប';

  @override
  String get nextDue => 'កិច្ចការបន្ទាប់';

  @override
  String overdueCount(Object count) {
    return 'ហួសកំណត់ $count';
  }

  @override
  String get statusAll => 'ទាំងអស់';

  @override
  String get statusInProgress => 'កំពុងអនុវត្ត';

  @override
  String get statusCompleted => 'បានសម្រេច';

  @override
  String get statusOverdue => 'ហួសកាលកំណត់';

  @override
  String get categoryFilter => 'ប្រភេទ';

  @override
  String get filterByCategory => 'កំណត់តាមប្រភេទ';

  @override
  String get showGoalsFromSpecificArea => 'បង្ហាញគោលដៅពីតំបន់ជាក់លាក់';

  @override
  String get upcoming => 'ខាងមុខ';

  @override
  String get completedThisWeek => 'បានសម្រេចក្នុងសប្តាហ៍នេះ';

  @override
  String get lastWeek => 'សប្តាហ៍មុន';

  @override
  String get thisMonth => 'ខែនេះ';

  @override
  String get earlier => 'មុននេះ';

  @override
  String get noGoalsFound => 'រកមិនឃើញគោលដៅទេ';

  @override
  String get captureFutureGoalsToGrow =>
      'កត់ត្រាគោលដៅអនាគតរបស់អ្នក និងតាមដានវឌ្ឍនភាពរបស់អ្នកដើម្បីលូតលាស់ជារៀងរាល់ថ្ងៃ។';

  @override
  String get addYourFirstGoal => 'បន្ថែមគោលដៅដំបូងរបស់អ្នក';

  @override
  String get retake => 'ធ្វើម្តងទៀត';

  @override
  String get yourDimensions => 'ទំហំនៃបុគ្គលិកលក្ខណៈរបស់អ្នក';

  @override
  String get strengths => 'ចំណុចខ្លាំង';

  @override
  String get growthAreas => 'ផ្នែកដែលត្រូវអភិវឌ្ឍ';

  @override
  String get careerPaths => 'អាជីពដែលសមស្រប';

  @override
  String get inRelationships => 'ក្នុងទំនាក់ទំនង';

  @override
  String famousPeopleOfType(Object type) {
    return 'បុគ្គលល្បីៗដែលមានប្រភេទ $type';
  }

  @override
  String get backToHome => 'ត្រឡប់ទៅទំព័រដើម';

  @override
  String get extraverted => 'បុគ្គលដែលចូលចិត្តសង្គម';

  @override
  String get introverted => 'បុគ្គលដែលចូលចិត្តភាពឯកជន';

  @override
  String get sensing => 'ការប្រើញ្ញាណ';

  @override
  String get intuitive => 'ការយល់ដឹងដោយវិចារណញ្ញាណ';

  @override
  String get thinking => 'ការគិតដោយផ្អែកលើហេតុផល';

  @override
  String get feeling => 'ការប្រើមនោសញ្ចេតនា';

  @override
  String get judging => 'ការវិនិច្ឆ័យ';

  @override
  String get perceiving => 'ការយល់ឃើញតាមស្ថានភាព';

  @override
  String get addAPicture => 'បន្ថែមរូបភាព';

  @override
  String get chooseHowToAddImage => 'ជ្រើសរើសរបៀបបន្ថែមរូបភាពរបស់អ្នក';

  @override
  String get pickFromPhotos => 'ជ្រើសរើសពីរូបថតរបស់អ្នក';

  @override
  String get takeNewPhoto => 'ថតរូបភាពថ្មី';

  @override
  String get editCard => 'កែសម្រួលកាត';

  @override
  String get width => 'ទទឹង';

  @override
  String get height => 'កម្ពស់';

  @override
  String get rotation => 'ការបង្វិល';

  @override
  String get captionOptional => 'ចំណងជើង (មិនបង្ខំ)';

  @override
  String get searchForInspiration => 'ស្វែងរកការលើកទឹកចិត្ត...';

  @override
  String noResultsFor(Object query) {
    return 'មិនមានលទ្ធផលសម្រាប់ \"$query\"';
  }

  @override
  String get visionBoardEmpty => 'ផ្ទាំងទស្សនវិស័យរបស់អ្នកកំពុងទំនេរ';

  @override
  String get tapToAddFirstImage => 'ចុចសញ្ញា + ដើម្បីបន្ថែមរូបភាពដំបូងរបស់អ្នក';

  @override
  String get poweredByGemini => 'ដំណើរការដោយ Google Gemini 2.0';

  @override
  String get typeYourMessage => 'សរសេរសាររបស់អ្នក...';

  @override
  String get freeLimitReached =>
      'អ្នកបានប្រើប្រាស់ប្រចាំថ្ងៃអស់ហើយ។ សូមតម្លើងគម្រោងដើម្បីបន្ត។';

  @override
  String get aiGreeting =>
      'សួស្តី! ខ្ញុំគឺជាជំនួយការ AI របស់អ្នក។ តើអ្នកមានអារម្មណ៍យ៉ាងណាដែរថ្ងៃនេះ?';

  @override
  String aiError(Object error) {
    return 'ខ្ញុំមានបញ្ហាក្នុងការភ្ជាប់ទំនាក់ទំនងនៅពេលនេះ (កំហុស: $error)។ សូមសាកល្បងម្តងទៀតនៅពេលក្រោយ។';
  }

  @override
  String get emoticon => 'រូបអារម្មណ៍';

  @override
  String get findYourVibe => 'ស្វែងរកអារម្មណ៍របស់អ្នក...';

  @override
  String get searchResults => 'លទ្ធផលស្វែងរក';

  @override
  String get myCustom => 'រូបអារម្មណ៍ផ្ទាល់ខ្លួន';

  @override
  String get clear => 'សម្អាត';

  @override
  String get clearRecents => 'សម្អាតមធ្យោបាយប្រើប្រាស់ថ្មីៗ';

  @override
  String get removeAllRecentEmoticons =>
      'តើអ្នកចង់លុបរូបអារម្មណ៍ដែលបានប្រើថ្មីៗទាំងអស់មែនទេ?';

  @override
  String get customize => 'កែសម្រួល';

  @override
  String get noEmoticonsFound => 'រកមិនឃើញរូបអារម្មណ៍ទេ';

  @override
  String get copiedToClipboard => 'ចម្លងទៅក្នុងក្តារតម្បៀតខ្ទាស់រួចរាល់!';

  @override
  String get deleteCustomEmoticon => 'លុបរូបអារម្មណ៍ផ្ទាល់ខ្លួន';

  @override
  String removeFaceFromCustomList(Object face) {
    return 'លុប \"$face\" ចេញពីបញ្ជីផ្ទាល់ខ្លួនរបស់អ្នក?';
  }

  @override
  String get catAll => 'ទាំងអស់';

  @override
  String get catHappy => 'សប្បាយ';

  @override
  String get catLove => 'ស្រឡាញ់';

  @override
  String get catSad => 'កើតទុក្ខ';

  @override
  String get catAngry => 'ខឹង';

  @override
  String get catSleepy => 'ងងុយដេក';

  @override
  String get catHugging => 'អោប';

  @override
  String get catExcited => 'រំភើប';

  @override
  String get catEmbarrassed => 'អៀន';

  @override
  String get catSurprised => 'ភ្ញាក់ផ្អើល';

  @override
  String get catConfused => 'ច្របូកច្របល់';

  @override
  String get catGreeting => 'ស្វាគមន៍';

  @override
  String get catWinking => 'ញាក់ភ្នែក';

  @override
  String get createEmoticon => 'បង្កើតរូបអារម្មណ៍';

  @override
  String get preview => 'ការមើលជាមុន';

  @override
  String get leftArm => 'ដៃឆ្វេង';

  @override
  String get eyes => 'ភ្នែក';

  @override
  String get mouth => 'មាត់';

  @override
  String get rightArm => 'ដៃស្តាំ';

  @override
  String get extras => 'បន្ថែម';

  @override
  String get category => 'ប្រភេទ';

  @override
  String get saveEmoticon => 'រក្សាទុករូបអារម្មណ៍';

  @override
  String get customEmoticonSaved => 'បានរក្សាទុករូបអារម្មណ៍ផ្ទាល់ខ្លួនរួចហើយ!';

  @override
  String get none => 'គ្មាន';

  @override
  String get myJournal => 'កំណត់ហេតុរបស់ខ្ញុំ';

  @override
  String get searchYourEntries => 'ស្វែងរកកំណត់ហេតុរបស់អ្នក...';

  @override
  String get showingArchivedEntries =>
      'កំពុងបង្ហាញកំណត់ហេតុដែលបានទុកបណ្ដោះអាសន្ន';

  @override
  String get noEntriesFound => 'រកមិនឃើញកំណត់ហេតុទេ';

  @override
  String get noJournalEntriesYet =>
      'មិនទាន់មានកំណត់ហេតុនៅឡើយទេ។\nចាប់ផ្តើមសរសេរ ✨';

  @override
  String get older => 'ចាស់ជាងនេះ';

  @override
  String get hideArchived => 'លាក់កំណត់ហេតុដែលបានទុកបណ្ដោះអាសន្ន';

  @override
  String get showArchived => 'បង្ហាញកំណត់ហេតុដែលបានទុកបណ្ដោះអាសន្ន';

  @override
  String get moodHappy => 'សប្បាយ';

  @override
  String get moodGood => 'ល្អ';

  @override
  String get moodOkay => 'ធម្មតា';

  @override
  String get moodSad => 'កើតទុក្ខ';

  @override
  String get moodBad => 'មិនល្អ';

  @override
  String get nerisTypeExplorer => 'NERIS Type Explorer';

  @override
  String get discoverWhoYouAre => 'ស្វែងយល់ថាអ្នកជានរណា';

  @override
  String get personalityTestDesc =>
      'ឆ្លើយសំណួរចំនួន 70 ដើម្បីស្វែងយល់ពីបុគ្គលិកលក្ខណៈពិសេសរបស់អ្នកពីក្នុងចំណោម 16 ប្រភេទ។ មិនមានចម្លើយណាដែលត្រូវ ឬខុសនោះទេ។';

  @override
  String get beforeYouBegin => 'មុនពេលអ្នកចាប់ផ្តើម';

  @override
  String get beYourself => 'ធ្វើជាខ្លួនអ្នក';

  @override
  String get beYourselfDesc =>
      'ឆ្លើយតាមអ្វីដែលអ្នកជាពិតប្រាកដ មិនមែនតាមអ្វីដែលអ្នកចង់ឱ្យគេមើលឃើញនោះទេ។';

  @override
  String get answerQuickly => 'ឆ្លើយឱ្យបានរហ័ស';

  @override
  String get answerQuicklyDesc =>
      'ប្រើវិចារណញ្ញាណដំបូងរបស់អ្នក។ កុំគិតច្រើនពេកលើសំណួរនីមួយៗ។';

  @override
  String get gainSelfAwareness => 'ទទួលបានការយល់ដឹងពីខ្លួនឯង';

  @override
  String get gainSelfAwarenessDesc =>
      'ស្វែងយល់ពីរបៀបដែលបុគ្គលិកលក្ខណៈរបស់អ្នកកំណត់អាជីព ទំនាក់ទំនង និងចំណុចខ្លាំងរបស់អ្នក។';

  @override
  String get fifteenMinutes => '15 នាទី';

  @override
  String get fifteenMinutesDesc =>
      'សំណួរចំនួន 70 ចែកចេញជា 14 ទំព័រ។ អ្នកអាចត្រឡប់ថយក្រោយដើម្បីប្តូរចម្លើយបាន។';

  @override
  String get questions => 'សំណួរ';

  @override
  String get types => 'ប្រភេទ';

  @override
  String get dimensions => 'វិមាត្រ';

  @override
  String get startTest => 'ចាប់ផ្តើមធ្វើតេស្ត';

  @override
  String get pleaseAnswerAllQuestions => 'សូមឆ្លើយសំណួរទាំងអស់នៅលើទំព័រនេះ';

  @override
  String pageOf(Object current, Object total) {
    return 'ទំព័រ $current នៃ $total';
  }

  @override
  String tasksCompleted(Object count) {
    return '$count/70 ភារកិច្ច';
  }

  @override
  String get exit => 'ចាកចេញ';

  @override
  String get back => 'ថយក្រោយ';

  @override
  String get next => 'បន្ទាប់';

  @override
  String get seeResults => 'មើលលទ្ធផល';

  @override
  String get or => 'ឬ';

  @override
  String get editReflection => 'កែសម្រួលការឆ្លុះបញ្ចាំង';

  @override
  String get myDailyReflection => 'ការឆ្លុះបញ្ចាំងប្រចាំថ្ងៃរបស់ខ្ញុំ';

  @override
  String get howAreYouFeelingToday => 'តើអ្នកមានអារម្មណ៍យ៉ាងណាដែរថ្ងៃនេះ?';

  @override
  String get journalEntry => 'ការសរសេរកំណត់ហេតុ';

  @override
  String get journalEntrySubtitle =>
      'អនុញ្ញាតឱ្យដំណើររបស់អ្នកបំភ្លឺផ្លូវរបស់អ្នក។';

  @override
  String get title => 'ចំណងជើង';

  @override
  String get startWritingYourThoughts => 'ចាប់ផ្តើមសរសេរគំនិតរបស់អ្នក...';

  @override
  String get updateReflection => 'ធ្វើបច្ចុប្បន្នភាពការឆ្លុះបញ្ចាំង';

  @override
  String get saveReflection => 'រក្សាទុកការឆ្លុះបញ្ចាំង';

  @override
  String get pleaseFillBothTitleAndContent => 'សូមបំពេញទាំងចំណងជើង និងខ្លឹមសារ';

  @override
  String get updatedSuccessfully => 'បានធ្វើបច្ចុប្បន្នភាពដោយជោគជ័យ! ✅';

  @override
  String get savedSuccessfully => 'បានរក្សាទុកដោយជោគជ័យ! ✅';

  @override
  String errorSavingEntry(Object error) {
    return 'កំហុសក្នុងការរក្សាទុកកំណត់ហេតុ: $error';
  }

  @override
  String get deleteEntry => 'លុបកំណត់ហេតុ';

  @override
  String get deleteEntryConfirm =>
      'តើអ្នកប្រាកដថាចង់លុបការសរសេរកំណត់ហេតុនេះមែនទេ? សកម្មភាពនេះមិនអាចត្រឡប់ថយក្រោយបានទេ។';

  @override
  String get archive => 'ទុកក្នុងបណ្ណសារ';

  @override
  String get unarchive => 'យកចេញពីបណ្ណសារ';

  @override
  String get entryArchived => 'បានដាក់ចូលក្នុងបណ្ណសារ';

  @override
  String get entryUnarchived => 'បានយកចេញពីក្នុងបណ្ណសារ';

  @override
  String get archived => 'ត្រូវបានរក្សាទុក';

  @override
  String get addGoal => 'បន្ថែមគោលដៅ';

  @override
  String get editGoal => 'កែសម្រួលគោលដៅ';

  @override
  String get saveChanges => 'រក្សាទុកការផ្លាស់ប្តូរ';

  @override
  String get goalTitle => 'ចំណងជើងគោលដៅ';

  @override
  String get description => 'ការពិពណ៌នា';

  @override
  String get pleaseEnterTitle => 'សូមបញ្ចូលចំណងជើង';

  @override
  String get buildFirstWebPageHint => 'ឧទាហរណ៍៖ បង្កើតគេហទំព័រដំបូង';

  @override
  String get whatDoYouWantToAchieveHint => 'តើអ្នកចង់សម្រេចអ្វីខ្លះ?';

  @override
  String get catStudy => 'ការសិក្សា';

  @override
  String get catProject => 'គម្រោង';

  @override
  String get catCareer => 'អាជីព';

  @override
  String get catPersonal => 'ផ្ទាល់ខ្លួន';

  @override
  String get catOther => 'ផ្សេងៗ';

  @override
  String get catEducation => 'ការអប់រំ';

  @override
  String get catHealth => 'សុខភាព';

  @override
  String get studyHint => 'កិច្ចការសាលា, ការប្រឡង, មេរៀន';

  @override
  String get projectHint => 'គម្រោងសាលា, គម្រោងសរសេរកូដ';

  @override
  String get careerHint =>
      'ការអនុវត្តការងារ, ផលប័ត្រ, ការត្រៀមខ្លួនសម្រាប់ការងារ';

  @override
  String get personalHint => 'ទម្លាប់, ការអភិវឌ្ឍខ្លួនឯង, ជំនាញថ្មីៗ';

  @override
  String get otherHint => 'គោលដៅទូទៅ';

  @override
  String get currentProgress => 'វឌ្ឍនភាពបច្ចុប្បន្ន';

  @override
  String get goals => 'គោលដៅ';

  @override
  String get status => 'ស្ថានភាព';

  @override
  String get inProgress => 'កំពុងអនុវត្ត';

  @override
  String get completed => 'បានបញ្ចប់';

  @override
  String get overdue => 'ហួសកំណត់';

  @override
  String get tapToAddGoal => 'ប៉ះសញ្ញា + ដើម្បីបន្ថែមគោលដៅដំបូងរបស់អ្នក';

  @override
  String get stats => 'ស្ថិតិ';

  @override
  String goalsCompletedCount(Object count) {
    return 'បានបញ្ចប់ $count គោលដៅ';
  }

  @override
  String get activeFilter => 'តម្រងសកម្ម';

  @override
  String get clearFilter => 'សម្អាត';

  @override
  String get addMilestone => 'បន្ថែមសមិទ្ធផល';

  @override
  String get noGoalsMatch => 'មិនមានគោលដៅត្រូវគ្នាទេ';

  @override
  String get noGoalsYet => 'មិនទាន់មានគោលដៅទេ';

  @override
  String get tryChangingFilters => 'សាកល្បងផ្លាស់ប្តូរតម្រងរបស់អ្នក។';

  @override
  String get nothingPendingRightNow =>
      'មិនទាន់មានអ្វីដែលត្រូវធ្វើនៅពេលនេះទេ —\nពិនិត្យមើលផ្ទាំងដែលបានបញ្ចប់សម្រាប់ប្រវត្តិរបស់អ្នក។';

  @override
  String get tapAddMilestoneBelow =>
      'ប៉ះ \"បន្ថែមសមិទ្ធផល\" ខាងក្រោម\nដើម្បីកំណត់គោលដៅដំបូងរបស់អ្នក!';

  @override
  String get clearFilters => 'សម្អាតតម្រង';

  @override
  String get done => 'រួចរាល់';

  @override
  String get stickerStudio => 'ស្ទូឌីយោស្ទីគ័រ';

  @override
  String get searchPublicStickers => 'ស្វែងរកស្ទីគ័រសាធារណៈ...';

  @override
  String get publicStore => 'ហាងសាធារណៈ';

  @override
  String get myStickers => 'ស្ទីគ័ររបស់ខ្ញុំ';

  @override
  String get createSticker => 'បង្កើតស្ទីគ័រ';

  @override
  String get failedToLoadStickers => 'មិនអាចផ្ទុកស្ទីគ័របានទេ';

  @override
  String get noPublicStickersFound => 'រកមិនឃើញស្ទីគ័រសាធារណៈទេ';

  @override
  String get haventCreatedStickersYet => 'អ្នកមិនទាន់បានបង្កើតស្ទីគ័រនៅឡើយទេ';

  @override
  String get stickerLinkCopied => 'បានចម្លងតំណស្ទីគ័រ!';

  @override
  String get copyLink => 'ចម្លងតំណ';

  @override
  String createdBy(Object name) {
    return 'បង្កើតដោយ $name';
  }

  @override
  String get backgroundRemovedSuccessfully => 'បានលុបផ្ទៃខាងក្រោយដោយជោគជ័យ!';

  @override
  String get selectImageAndEnterName => 'សូមជ្រើសរើសរូបភាព និងបញ្ចូលឈ្មោះ';

  @override
  String get failedToSaveSticker => 'មិនអាចរក្សាទុកស្ទីគ័របានទេ';

  @override
  String get selectAPhoto => 'ជ្រើសរើសរូបថត';

  @override
  String get objectSelected => 'បានជ្រើសរើសវត្ថុ';

  @override
  String get changePhoto => 'ផ្លាស់ប្តូររូបថត';

  @override
  String get alphaMask => 'ម៉ាសអាល់ហ្វា';

  @override
  String get collectionSettings => 'ការកំណត់ការប្រមូល';

  @override
  String get stickerName => 'ឈ្មោះស្ទីគ័រ';

  @override
  String get stickerNameHint => 'ឧទាហរណ៍៖ ឆ្មារីករាយ, ឡូយណាស់...';

  @override
  String get makePublic => 'ធ្វើជាសាធារណៈ';

  @override
  String get makePublicSubtitle =>
      'ស្ទីគ័រសាធារណៈអាចត្រូវបានស្វែងរក និងប្រើប្រាស់ដោយមនុស្សគ្រប់គ្នា';

  @override
  String get finishAndAddToCollection => 'បញ្ចប់ និងបន្ថែមទៅការប្រមូល';

  @override
  String get analyzingDepth => 'កំពុងវិភាគជម្រៅ...';

  @override
  String typeLabel(Object type) {
    return 'ប្រភេទ៖ $type';
  }

  @override
  String get quote1 => 'ដំណើររបស់អ្នកគឺប្លែក សូមផ្តល់តម្លៃដល់វា។';

  @override
  String get quote1Title => 'សន្តិភាពខាងក្នុង';

  @override
  String get quote2 => 'ការរីកចម្រើនគឺជាដំណើរការ មិនមែនជាគោលដៅទេ។';

  @override
  String get quote2Title => 'ការរីកចម្រើនជាប្រចាំ';

  @override
  String get quote3 => 'ជឿជាក់លើសក្ដានុពលរបស់អ្នកក្នុងការផ្លាស់ប្តូរ។';

  @override
  String get quote3Title => 'ជំនឿលើខ្លួនឯង';

  @override
  String get freeAccess => 'ការចូលប្រើដោយសេរី';

  @override
  String messagesLeftToday(Object count) {
    return 'សល់ $count សារសម្រាប់ថ្ងៃនេះ';
  }

  @override
  String get upgradeForMore => 'ធ្វើបច្ចុប្បន្នភាពសម្រាប់សារបន្ថែម';

  @override
  String get clearChat => 'សម្អាតការសន្ទនា';

  @override
  String get areYouSureYouWantToClearChat =>
      'តើអ្នកប្រាកដថាចង់សម្អាតប្រវត្តិសន្ទនាដែរឬទេ?';

  @override
  String get personalization => 'ការកំណត់ផ្ទាល់ខ្លួន';

  @override
  String get updateInterests => 'ធ្វើបច្ចុប្បន្នភាពចំណាប់អារម្មណ៍';

  @override
  String get updateInterestsSub => 'ផ្លាស់ប្តូរជម្រើសការងារដែលបានផ្តល់ឱ្យ';

  @override
  String get myFavoritesSub => 'អាហារូបករណ៍ និងការបង្ហោះដែលបានរក្សាទុក';

  @override
  String get accountSettings => 'ការកំណត់គណនី';

  @override
  String get editProfileInfo => 'កែសម្រួលព័ត៌មានប្រវត្តិរូប';

  @override
  String get manageSubscription => 'ការជាវ';

  @override
  String get manageSubscriptionSub => 'គ្រប់គ្រងគម្រោងរបស់អ្នក';

  @override
  String get recentActivity => 'សកម្មភាពថ្មីៗ';

  @override
  String get noRecentActivity => 'មិនទាន់មានសកម្មភាពថ្មីៗនៅឡើយទេ។';

  @override
  String get darkMode => 'មុខងារងងឹត';

  @override
  String get darkAesthetic => 'កំពុងប្រើប្រាស់សោភ័ណភាពងងឹត';

  @override
  String get lightAesthetic => 'កំពុងប្រើប្រាស់សោភ័ណភាពភ្លឺ';

  @override
  String get changePassword => 'ផ្លាស់ប្តូរពាក្យសម្ងាត់';

  @override
  String get signOut => 'ចាកចេញពីគណនី';

  @override
  String get premium => 'ប្រីមៀម';

  @override
  String get selectLanguage => 'ជ្រើសរើសភាសា';

  @override
  String get communityPost => 'ការបង្ហោះក្នុងសហគមន៍';

  @override
  String get favoritedItem => 'បានដាក់ជាសំណព្វ';

  @override
  String get viewedScholarship => 'បានមើលអាហារូបករណ៍';

  @override
  String get unknownActivity => 'សកម្មភាពមិនស្គាល់';

  @override
  String get updateAccountInfo => 'ធ្វើបច្ចុប្បន្នភាពព័ត៌មានគណនីរបស់អ្នក។';

  @override
  String get fullName => 'ឈ្មោះពេញ';

  @override
  String get emailAddress => 'អាសយដ្ឋានអ៊ីមែល';

  @override
  String get pleaseFillAllFields => 'សូមបំពេញគ្រប់ព័ត៌មានទាំងអស់';

  @override
  String get profileUpdatedSuccessfully =>
      'ប្រវត្តិរូបត្រូវបានធ្វើបច្ចុប្បន្នភាពដោយជោគជ័យ!';

  @override
  String get changePasswordTitle => 'ផ្លាស់ប្តូរពាក្យសម្ងាត់';

  @override
  String get setNewPassword => 'កំណត់ពាក្យសម្ងាត់ថ្មី';

  @override
  String get updateSecurityCredentials =>
      'ធ្វើបច្ចុប្បន្នភាពព័ត៌មានសម្ងាត់បច្ចុប្បន្នរបស់អ្នក។';

  @override
  String get createSecurePassword =>
      'បង្កើតពាក្យសម្ងាត់ដែលមានសុវត្ថិភាពសម្រាប់គណនីថ្មីរបស់អ្នក។';

  @override
  String get currentPassword => 'ពាក្យសម្ងាត់បច្ចុប្បន្ន';

  @override
  String get newPassword => 'ពាក្យសម្ងាត់ថ្មី';

  @override
  String get confirmNewPassword => 'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី';

  @override
  String get forgotCurrentPassword => 'ភ្លេចពាក្យសម្ងាត់បច្ចុប្បន្នមែនទេ?';

  @override
  String get updatePassword => 'ធ្វើបច្ចុប្បន្នភាពពាក្យសម្ងាត់';

  @override
  String get enterCurrentPassword =>
      'សូមបញ្ជាក់ពាក្យសម្ងាត់បច្ចុប្បន្នរបស់អ្នក';

  @override
  String get enterNewPassword => 'សូមបញ្ចូលពាក្យសម្ងាត់ថ្មី';

  @override
  String get passwordsDoNotMatch => 'ពាក្យសម្ងាត់មិនស៊ីគ្នាទេ';

  @override
  String get passwordUpdatedSuccessfully =>
      'ពាក្យសម្ងាត់ត្រូវបានធ្វើបច្ចុប្បន្នភាពដោយជោគជ័យ!';

  @override
  String get pricingTitle => 'ការកំណត់តម្លៃ';

  @override
  String get chooseBestPlan => 'ជ្រើសរើសគម្រោងដែលល្អបំផុត';

  @override
  String get aiAccessTitle => 'ការចូលប្រើ AI';

  @override
  String get otherAccessTitle => 'ការចូលប្រើផ្សេងទៀត';

  @override
  String get mostPopular => 'ពេញនិយមបំផុត';

  @override
  String get oneTime => 'ទូទាត់តែម្តង';

  @override
  String get pickPlan => 'ជ្រើសរើសយកគម្រោងនេះ';

  @override
  String get youSubscribed => 'អ្នកបានជាវគម្រោងនេះរួចហើយ';

  @override
  String get freePlanSub =>
      'ល្អបំផុតសម្រាប់ការស្វែងយល់ និងការឆ្លុះបញ្ចាំងប្រចាំថ្ងៃ';

  @override
  String get premiumPlanSub =>
      'ល្អបំផុតសម្រាប់ការរកឃើញខ្លួនឯង និងការរីកចម្រើនជាបន្តបន្ទាប់';

  @override
  String get focusedPackSub =>
      'ល្អបំផុតសម្រាប់សិស្សដែលត្រូវការភាពច្បាស់លាស់ឥឡូវនេះ';

  @override
  String get after7Days => 'បន្ទាប់ពី ៧ ថ្ងៃ';

  @override
  String get passwordHint => 'សូមបញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្ន';

  @override
  String get retypePasswordHint => 'សូមបញ្ចូលពាក្យសម្ងាត់ថ្មីឡើងវិញ';

  @override
  String get min6CharsHint => 'យ៉ាងហោចណាស់ ៦ តួអក្សរ';

  @override
  String get currentPasswordHint => 'សូមបញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្ន';
}
