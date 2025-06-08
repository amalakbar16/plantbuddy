class ApiConfig {
  // Change this to your local IP address when testing on physical devices
  static const String baseUrl = 'http://10.0.2.2/plantbuddy/plantbuddy_api'; // Untuk emulator Android

  
  // API Endpoints
  static const String register = '$baseUrl/auth/register.php';
  static const String login = '$baseUrl/auth/login.php';
  static const String getPlants = '$baseUrl/plants/get_plants.php';
  static const String addPlant = '$baseUrl/plants/add_plant.php';
  static const String getArticles = '$baseUrl/articles/get_articles.php';
}
