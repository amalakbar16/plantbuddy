import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plantbuddy/services/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Authentication
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true &&
            responseData.containsKey('user')) {
          return responseData['user'];
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Article Management
  static Future<List<Map<String, dynamic>>> getArticles() async {
    try {
      final url = '$baseUrl/articles/get_articles.php';
      print('Fetching articles from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Article API Response Status: ${response.statusCode}');
      print('Article API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        print('Error: Non-200 status code received');
        return [];
      }

      if (response.body.isEmpty) {
        print('Error: Empty response body');
        return [];
      }

      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Parsed JSON response: $jsonResponse');

        if (jsonResponse['success'] != true || jsonResponse['data'] == null) {
          print('Error: Invalid response format or unsuccessful response');
          return [];
        }

        final List<dynamic> articlesData = jsonResponse['data'];
        return articlesData.map((article) {
          return {
            'id': article['id']?.toString() ?? '',
            'title': article['title']?.toString() ?? 'No Title',
            'content': article['content']?.toString() ?? 'No content available',
            'published_date': article['published_date']?.toString() ?? '',
            'created_at': article['created_at']?.toString() ?? '',
            'image_data': article['image_data']?.toString() ?? '',
            'image_type': article['image_type']?.toString() ?? '',
          };
        }).toList();
      } catch (e) {
        print('JSON parsing error: $e');
        return [];
      }
    } catch (e) {
      print('Network or other error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getArticle(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/articles/get_article.php?id=$id'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load article');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> createArticle(
    Map<String, dynamic> articleData,
  ) async {
    try {
      print('Sending request to: $baseUrl/articles/add_article.php');
      print('Request data: ${json.encode(articleData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/articles/add_article.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(articleData),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          responseData['error'] ??
              responseData['message'] ??
              'Failed to create article',
        );
      }

      if (responseData['error'] != null) {
        throw Exception(responseData['error']);
      }

      return responseData;
    } catch (e) {
      print('Error creating article: $e');
      throw Exception('Failed to create article: $e');
    }
  }

  static Future<Map<String, dynamic>> updateArticle(
    int id,
    Map<String, dynamic> articleData,
  ) async {
    try {
      print('Updating article with ID: $id');
      print('Update data: ${json.encode(articleData)}');

      final Map<String, dynamic> requestData = {
        ...articleData,
        'id': id.toString(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/articles/update_article.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update article');
      }

      final responseData = json.decode(response.body);
      if (!responseData['success']) {
        throw Exception(responseData['error'] ?? 'Failed to update article');
      }

      return responseData;
    } catch (e) {
      print('Error updating article: $e');
      throw Exception('Failed to update article: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteArticle(int id) async {
    try {
      print('Deleting article with ID: $id');
      final response = await http.post(
        Uri.parse('$baseUrl/articles/delete_article.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'id': id.toString(), // Ensure ID is sent as string
        }),
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        throw Exception(responseData['error'] ?? 'Failed to delete article');
      }

      if (!responseData['success']) {
        throw Exception(responseData['error'] ?? 'Failed to delete article');
      }

      return responseData;
    } catch (e) {
      print('Error deleting article: $e');
      throw Exception('Failed to delete article: $e');
    }
  }

  // Plant Management
  static Future<Map<String, dynamic>> addPlant({
    required int userId,
    required String name,
    required String species,
    String? imageDataBase64,
  }) async {
    try {
      final Map<String, dynamic> plantData = {
        'user_id': userId,
        'name': name,
        'species': species,
        'image_data': imageDataBase64 ?? '',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/plants/add_plant.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(plantData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add plant');
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to add plant');
      }

      return responseData;
    } catch (e) {
      print('Error adding plant: $e');
      throw Exception('Failed to add plant: $e');
    }
  }

  static Future<Map<String, dynamic>> updatePlant({
    required int id,
    required int userId,
    required String name,
    required String species,
    String? imageDataBase64,
  }) async {
    try {
      final Map<String, dynamic> plantData = {
        'id': id,
        'user_id': userId,
        'name': name,
        'species': species,
        'image_data': imageDataBase64 ?? '',
      };

      // DEBUG PRINT
      print('[updatePlant] data: $plantData');

      final response = await http.post(
        Uri.parse('$baseUrl/plants/update_plant.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(plantData),
      );

      // PRINT STATUS & BODY UNTUK DEBUG
      print('[updatePlant] Status code: ${response.statusCode}');
      print('[updatePlant] Body: ${response.body}');

      if (response.statusCode != 200) {
        final body = response.body;
        throw Exception(
          'Failed to update plant: ${body.isNotEmpty ? body : "Unknown error"}',
        );
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to update plant');
      }

      return responseData;
    } catch (e) {
      print('Error updating plant: $e');
      throw Exception('Failed to update plant: $e');
    }
  }

  // New method to fetch plants for a user
  static Future<List<Map<String, dynamic>>> getPlantsForUser(int userId) async {
    try {
      final Map<String, dynamic> requestData = {'user_id': userId};

      final response = await http.post(
        Uri.parse('$baseUrl/plants/get_plants.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode != 200) {
        print('Failed to fetch plants: Status code ${response.statusCode}');
        return [];
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] != true || responseData['data'] == null) {
        print('Failed to fetch plants: Invalid response');
        return [];
      }

      final List<dynamic> plantsData = responseData['data'];
      return plantsData.map((plant) {
        return {
          'id': plant['id']?.toString() ?? '',
          'name': plant['name']?.toString() ?? 'No Name',
          'species': plant['species']?.toString() ?? 'Unknown',
          'image_data': plant['image_data']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching plants: $e');
      return [];
    }
  }

  //method delete plant
  static Future<Map<String, dynamic>> deletePlant({
    required int id,
    required int userId,
  }) async {
    try {
      final Map<String, dynamic> plantData = {'id': id, 'user_id': userId};

      final response = await http.post(
        Uri.parse('$baseUrl/plants/delete_plant.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(plantData),
      );

      // Debug print
      print('[deletePlant] Status code: ${response.statusCode}');
      print('[deletePlant] Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete plant');
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to delete plant');
      }

      return responseData;
    } catch (e) {
      print('Error deleting plant: $e');
      throw Exception('Failed to delete plant: $e');
    }
  }
}
