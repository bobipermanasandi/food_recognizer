class AppConstants {
  static const String appName = 'Food Recognizer';
  static const String appDescription = 'Advanced Food Recognition with AI';

  static const String mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static const int imageSize = 224;
  static const int maxImageSize = 1024;
  static const double cropAspectRatio = 1.0;

  static const int confidenceThreshold = 50;
  static const int maxRecentPredictions = 20;

  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];

  static const Map<String, String> errorMessages = {
    'cameraPermission': 'Camera permission is required to take photos',
    'storagePermission': 'Storage permission is required to save images',
    'networkError': 'Network error. Please check your connection',
    'modelLoadError': 'Failed to load AI model',
    'imageProcessError': 'Failed to process image',
    'unknownError': 'An unexpected error occurred',
  };

  static const List<String> nutritionInfo = [
    'calories',
    'carbohydrates',
    'fat',
    'fiber',
    'protein',
  ];
}
