import 'package:flutter/material.dart';
import 'package:h2s/models/match_result_model.dart';
import 'package:h2s/models/video_model.dart';
import 'package:h2s/services/mock_data_service.dart';

class DashboardProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();

  String _categoryFilter = 'All';
  String _searchQuery = '';
  String _statusFilter = 'All';

  String get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  // ─── Stats ───

  int get totalVideos => _dataService.totalVideos;
  int get flaggedVideos => _dataService.flaggedVideos;
  int get protectedVideos => _dataService.protectedVideos;
  int get totalScans => _dataService.totalScans;

  Map<String, int> get videosByCategory => _dataService.videosByCategory;

  // ─── Videos ───

  List<VideoModel> get allVideos {
    var videos = _dataService.allVideos.toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    if (_categoryFilter != 'All') {
      videos = videos.where((v) => v.category == _categoryFilter).toList();
    }

    if (_statusFilter != 'All') {
      videos = videos.where((v) => v.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      videos = videos
          .where((v) =>
              v.title.toLowerCase().contains(q) ||
              v.category.toLowerCase().contains(q) ||
              v.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }

    return videos;
  }

  // ─── Match Results ───

  List<MatchResultModel> get recentAlerts => _dataService.recentAlerts;
  List<MatchResultModel> get allMatchResults => _dataService.allMatchResults;

  List<MatchResultModel> get highRiskResults =>
      _dataService.allMatchResults.where((r) => r.isHighRisk).toList();

  // ─── Filters ───

  void setCategoryFilter(String cat) {
    _categoryFilter = cat;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setStatusFilter(String s) {
    _statusFilter = s;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  // ─── Admin actions ───

  void flagVideo(String videoId) {
    _dataService.flagVideo(videoId);
    notifyListeners();
  }

  void deleteVideo(String videoId) {
    _dataService.deleteVideo(videoId);
    notifyListeners();
  }

  List<dynamic> get allUsers => _dataService.allUsers;
}
