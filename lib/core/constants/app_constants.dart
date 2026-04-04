class AppConstants {
  AppConstants._();

  static const String appName = 'PetFinder';
  static const String appVersion = '1.0.0';

  // ⚠️ Replace with your Cloudinary credentials
  static const String cloudinaryCloudName = 'YOUR_CLOUD_NAME';
  static const String cloudinaryUploadPreset = 'YOUR_UPLOAD_PRESET';
  static String get cloudinaryUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

  // Firestore collections
  static const String colUsers = 'users';
  static const String colPosts = 'posts';
  static const String colNotifications = 'notifications';

  // Hive boxes
  static const String boxUsers = 'users_box';
  static const String boxPosts = 'posts_box';
  static const String boxPendingPosts = 'pending_posts_box';
  static const String boxSettings = 'settings_box';

  // Hive type IDs
  static const int typeIdUser = 0;
  static const int typeIdPost = 1;

  // SharedPreferences keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyLanguage = 'language';

  // Map defaults — Hanoi centre
  static const double defaultLat = 21.0285;
  static const double defaultLng = 105.8542;
  static const double defaultZoom = 13.0;

  // Business rules
  static const int maxImages = 5;
  static const int postActiveDays = 30;
  static const double defaultNotifRadius = 5.0; // km
}
