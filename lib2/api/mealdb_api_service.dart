import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import 'dart:developer';

class MealDbApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<RecipeModel>?> searchRecipes(String foodName) async {
    try {
      // Bersihkan nama makanan untuk pencarian
      String cleanFoodName = _cleanFoodName(foodName);

      log('Mencari resep untuk: $cleanFoodName');

      final url = Uri.parse('$_baseUrl/search.php?s=$cleanFoodName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['meals'] != null) {
          List<RecipeModel> recipes = [];
          for (var meal in data['meals']) {
            recipes.add(RecipeModel.fromJson(meal));
          }
          log('Ditemukan ${recipes.length} resep');
          return recipes;
        } else {
          log('Tidak ada resep ditemukan untuk: $cleanFoodName');
          // Coba pencarian dengan kata kunci yang lebih umum
          return await _searchWithGenericTerms(cleanFoodName);
        }
      } else {
        log('Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error saat mengakses MealDB API: $e');
      return null;
    }
  }

  // Method baru untuk pencarian berdasarkan nama makanan dari Gemini API
  Future<List<RecipeModel>?> searchRecipesByGeminiFoodName(
    String geminiFoodName,
  ) async {
    try {
      log('Mencari resep berdasarkan nama dari Gemini: $geminiFoodName');

      // Ekstrak nama makanan utama dari respons Gemini
      String mainFoodName = _extractMainFoodName(geminiFoodName);

      // Coba pencarian langsung dengan nama yang diekstrak
      List<RecipeModel>? recipes = await _searchDirectly(mainFoodName);

      if (recipes != null && recipes.isNotEmpty) {
        return recipes;
      }

      // Jika tidak ditemukan, coba dengan kata kunci yang lebih umum
      return await _searchWithKeywords(mainFoodName);
    } catch (e) {
      log('Error saat mencari resep dengan nama Gemini: $e');
      return await _getRandomRecipes();
    }
  }

  String _extractMainFoodName(String geminiFoodName) {
    // Bersihkan dan ekstrak nama makanan utama dari respons Gemini
    String cleaned = geminiFoodName.toLowerCase().trim();

    // Hapus kata-kata umum yang tidak relevan untuk pencarian resep
    List<String> wordsToRemove = [
      'makanan',
      'food',
      'dish',
      'teridentifikasi',
      'dikenali',
      'adalah',
      'merupakan',
      'berupa',
      'jenis',
      'kategori',
    ];

    for (String word in wordsToRemove) {
      cleaned = cleaned.replaceAll(word, ' ');
    }

    // Bersihkan spasi berlebih
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Ambil maksimal 2-3 kata pertama yang bermakna
    List<String> words = cleaned.split(' ');
    if (words.length > 3) {
      words = words.take(3).toList();
    }

    return words.join(' ');
  }

  Future<List<RecipeModel>?> _searchDirectly(String foodName) async {
    try {
      final url = Uri.parse('$_baseUrl/search.php?s=$foodName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['meals'] != null) {
          List<RecipeModel> recipes = [];
          for (var meal in data['meals']) {
            recipes.add(RecipeModel.fromJson(meal));
          }
          return recipes;
        }
      }
      return null;
    } catch (e) {
      log('Error dalam pencarian langsung: $e');
      return null;
    }
  }

  Future<List<RecipeModel>?> _searchWithKeywords(String foodName) async {
    // Ekstrak kata kunci utama dari nama makanan
    List<String> keywords = _extractKeywords(foodName);

    for (String keyword in keywords) {
      try {
        final url = Uri.parse('$_baseUrl/search.php?s=$keyword');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data['meals'] != null) {
            List<RecipeModel> recipes = [];
            // Ambil maksimal 3 resep
            int count = 0;
            for (var meal in data['meals']) {
              if (count >= 3) break;
              recipes.add(RecipeModel.fromJson(meal));
              count++;
            }
            if (recipes.isNotEmpty) {
              log('Ditemukan resep dengan kata kunci: $keyword');
              return recipes;
            }
          }
        }
      } catch (e) {
        log('Error saat mencari dengan kata kunci $keyword: $e');
      }
    }

    return null;
  }

  List<String> _extractKeywords(String foodName) {
    List<String> keywords = [];
    String lowerName = foodName.toLowerCase();

    // Mapping kata kunci Indonesia ke English
    Map<String, String> keywordMapping = {
      'ayam': 'chicken',
      'sapi': 'beef',
      'ikan': 'fish',
      'udang': 'shrimp',
      'nasi': 'rice',
      'mie': 'noodle',
      'bakmi': 'noodle',
      'pasta': 'pasta',
      'pizza': 'pizza',
      'burger': 'burger',
      'salad': 'salad',
      'sup': 'soup',
      'soto': 'soup',
      'curry': 'curry',
      'rendang': 'beef',
      'satay': 'chicken',
      'sate': 'chicken',
      'goreng': 'fried',
      'bakar': 'grilled',
      'rebus': 'boiled',
      'telur': 'egg',
      'tahu': 'tofu',
      'tempe': 'tempeh',
    };

    // Cari kata kunci yang cocok
    for (String indonesian in keywordMapping.keys) {
      if (lowerName.contains(indonesian)) {
        keywords.add(keywordMapping[indonesian]!);
      }
    }

    // Jika tidak ada kata kunci spesifik, gunakan kata umum
    if (keywords.isEmpty) {
      List<String> commonKeywords = [
        'chicken',
        'beef',
        'rice',
        'pasta',
        'soup',
      ];
      keywords.addAll(commonKeywords);
    }

    return keywords;
  }

  Future<List<RecipeModel>?> _searchWithGenericTerms(String foodName) async {
    // Daftar kata kunci umum untuk makanan Indonesia/Asia
    List<String> genericTerms = [
      'chicken',
      'beef',
      'rice',
      'noodle',
      'soup',
      'curry',
      'fried',
      'fish',
      'pork',
      'vegetable',
      'pasta',
      'bread',
      'egg',
    ];

    String lowerFoodName = foodName.toLowerCase();

    for (String term in genericTerms) {
      if (lowerFoodName.contains(term) ||
          _containsIndonesianEquivalent(lowerFoodName, term)) {
        try {
          final url = Uri.parse('$_baseUrl/search.php?s=$term');
          final response = await http.get(url);

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);

            if (data['meals'] != null) {
              List<RecipeModel> recipes = [];
              // Ambil maksimal 3 resep pertama
              int count = 0;
              for (var meal in data['meals']) {
                if (count >= 3) break;
                recipes.add(RecipeModel.fromJson(meal));
                count++;
              }
              log(
                'Ditemukan ${recipes.length} resep alternatif dengan kata kunci: $term',
              );
              return recipes;
            }
          }
        } catch (e) {
          log('Error saat mencari dengan kata kunci $term: $e');
        }
      }
    }

    return await _getRandomRecipes();
  }

  bool _containsIndonesianEquivalent(String foodName, String englishTerm) {
    Map<String, List<String>> equivalents = {
      'chicken': ['ayam', 'unggas'],
      'beef': ['sapi', 'daging'],
      'rice': ['nasi', 'beras'],
      'noodle': ['mie', 'bakmi', 'kwetiau'],
      'fish': ['ikan', 'lele', 'gurame', 'bandeng'],
      'egg': ['telur', 'telor'],
      'soup': ['soto', 'sup', 'kuah'],
      'fried': ['goreng', 'bakar'],
    };

    if (equivalents[englishTerm] != null) {
      for (String equivalent in equivalents[englishTerm]!) {
        if (foodName.contains(equivalent)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<List<RecipeModel>?> _getRandomRecipes() async {
    try {
      log('Mengambil resep acak...');
      List<RecipeModel> randomRecipes = [];

      // Ambil 3 resep acak
      for (int i = 0; i < 3; i++) {
        final url = Uri.parse('$_baseUrl/random.php');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data['meals'] != null && data['meals'].isNotEmpty) {
            randomRecipes.add(RecipeModel.fromJson(data['meals'][0]));
          }
        }
      }

      log('Ditemukan ${randomRecipes.length} resep acak');
      return randomRecipes.isNotEmpty ? randomRecipes : null;
    } catch (e) {
      log('Error saat mengambil resep acak: $e');
      return null;
    }
  }

  String _cleanFoodName(String foodName) {
    // Hapus prefix "Makanan Teridentifikasi" jika ada
    String cleaned = foodName
        .replaceAll(RegExp(r'^Makanan Teridentifikasi \d+'), '')
        .trim();

    // Jika masih kosong atau tidak bermakna, gunakan kata kunci umum
    if (cleaned.isEmpty || cleaned.length < 3) {
      return 'chicken'; // Default fallback
    }

    // Translasi beberapa kata umum Indonesia ke English untuk pencarian yang lebih baik
    Map<String, String> translations = {
      'ayam': 'chicken',
      'sapi': 'beef',
      'ikan': 'fish',
      'nasi': 'rice',
      'mie': 'noodle',
      'telur': 'egg',
      'sayur': 'vegetable',
    };

    for (String indonesian in translations.keys) {
      if (cleaned.toLowerCase().contains(indonesian)) {
        return translations[indonesian]!;
      }
    }

    return cleaned;
  }

  Future<RecipeModel?> getRecipeById(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/lookup.php?i=$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return RecipeModel.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      log('Error saat mengambil resep berdasarkan ID: $e');
      return null;
    }
  }
}
