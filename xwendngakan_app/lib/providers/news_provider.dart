import 'package:flutter/material.dart';
import '../data/models/news_model.dart';
import '../data/models/post_model.dart';
import '../data/services/api_service.dart';

class NewsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<NewsModel> _news = [];
  List<PostModel> _posts = [];
  bool _loadingNews = false;
  bool _loadingPosts = false;
  String? _error;

  List<NewsModel> get news => _news;
  List<PostModel> get posts => _posts;
  bool get loading => _loadingNews || _loadingPosts;
  bool get loadingNews => _loadingNews;
  bool get loadingPosts => _loadingPosts;
  String? get error => _error;

  Future<void> fetchAll({bool refresh = false}) async {
    await Future.wait([
      fetchNews(refresh: refresh),
      fetchPosts(refresh: refresh),
    ]);
  }

  Future<void> fetchNews({bool refresh = false}) async {
    if (refresh) {
      _news.clear();
    }
    if (_news.isNotEmpty && !refresh) return;

    _loadingNews = true;
    _error = null;
    notifyListeners();

    final res = await _api.getNews();
    if (res.success && res.data != null) {
      _news = res.data!.map((e) => NewsModel.fromJson(e)).toList();
    } else {
      _error = res.error ?? 'Failed to load news';
    }

    _loadingNews = false;
    notifyListeners();
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _posts.clear();
    }
    if (_posts.isNotEmpty && !refresh) return;

    _loadingPosts = true;
    notifyListeners();

    final res = await _api.getPosts();
    if (res.success && res.data != null) {
      _posts = res.data!.map((e) => PostModel.fromJson(e)).toList();
    }

    _loadingPosts = false;
    notifyListeners();
  }
}
