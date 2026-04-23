import 'package:h2s/models/frame_model.dart';
import 'package:h2s/models/match_result_model.dart';
import 'package:h2s/models/video_model.dart';
import 'package:h2s/models/user_model.dart';
import 'package:h2s/services/mock_ai_service.dart';

/// In-memory data store. All data persists for the current browser session.
/// Replace with real Supabase calls by updating the method bodies.
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    _seedDemoData();
  }

  final List<UserModel> _users = [];
  final List<VideoModel> _videos = [];
  final List<FrameModel> _frames = [];
  final List<MatchResultModel> _matchResults = [];
  UserModel? _currentUser;

  // ───────────────────────── Auth ─────────────────────────

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  UserModel? login(String email, String password) {
    try {
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
      _currentUser = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  UserModel signup({
    required String email,
    required String name,
    required String password,
    required String role,
  }) {
    final existing = _users.where(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (existing.isNotEmpty) {
      throw Exception('Email already registered');
    }
    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(),
    );
    _users.add(user);
    _currentUser = user;
    return user;
  }

  void logout() => _currentUser = null;

  List<UserModel> get allUsers => List.unmodifiable(_users);

  // ───────────────────────── Videos ─────────────────────────

  List<VideoModel> get allVideos => List.unmodifiable(_videos);

  List<VideoModel> getVideosByUser(String userId) =>
      _videos.where((v) => v.userId == userId).toList();

  VideoModel? getVideoById(String id) =>
      _videos.where((v) => v.id == id).firstOrNull;

  void addVideo(VideoModel video) => _videos.add(video);

  void updateVideo(VideoModel updated) {
    final idx = _videos.indexWhere((v) => v.id == updated.id);
    if (idx >= 0) _videos[idx] = updated;
  }

  void flagVideo(String videoId) {
    final idx = _videos.indexWhere((v) => v.id == videoId);
    if (idx >= 0) {
      _videos[idx] = _videos[idx].copyWith(status: 'flagged');
    }
  }

  void deleteVideo(String videoId) {
    _videos.removeWhere((v) => v.id == videoId);
    _frames.removeWhere((f) => f.videoId == videoId);
  }

  // ───────────────────────── Frames ─────────────────────────

  void addFrame(FrameModel frame) => _frames.add(frame);

  List<FrameModel> getFramesForVideo(String videoId) =>
      _frames.where((f) => f.videoId == videoId).toList()
        ..sort((a, b) => a.timestampSeconds.compareTo(b.timestampSeconds));

  List<String> getCaptionsForVideo(String videoId) =>
      getFramesForVideo(videoId).map((f) => f.caption).toList();

  // ───────────────────────── Match Results ─────────────────────────

  List<MatchResultModel> get allMatchResults =>
      List.unmodifiable(_matchResults)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  MatchResultModel? getMatchResultById(String id) =>
      _matchResults.where((r) => r.id == id).firstOrNull;

  void addMatchResult(MatchResultModel result) {
    _matchResults.add(result);
    // Auto-flag video if high risk
    if (result.isHighRisk) {
      flagVideo(result.queryVideoId);
    }
  }

  // ───────────────────────── Stats ─────────────────────────

  int get totalVideos => _videos.length;
  int get flaggedVideos => _videos.where((v) => v.isFlagged).length;
  int get processingVideos => _videos.where((v) => v.isProcessing).length;
  int get protectedVideos => _videos.where((v) => v.isReady).length;
  int get totalScans => _matchResults.length;

  Map<String, int> get videosByCategory {
    final map = <String, int>{};
    for (final v in _videos) {
      map[v.category] = (map[v.category] ?? 0) + 1;
    }
    return map;
  }

  List<MatchResultModel> get recentAlerts {
    return _matchResults
        .where((r) => r.riskLevel != 'Low')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ───────────────────────── Seed Data ─────────────────────────

  void _seedDemoData() {
    // Seed users
    _users.addAll([
      UserModel(
        id: 'user_admin_001',
        email: 'admin@sportshield.ai',
        name: 'Admin User',
        role: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'user_001',
        email: 'user@sportshield.ai',
        name: 'Sports Analyst',
        role: 'user',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ]);

    // Seed videos
    final seedVideos = [
      VideoModel(
        id: 'vid_001',
        userId: 'user_admin_001',
        title: 'FIFA World Cup Highlights 2024',
        category: 'Football',
        tags: ['FIFA', 'World Cup', 'Official'],
        status: 'ready',
        uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
        frameCount: 20,
        fileName: 'world_cup_highlights.mp4',
        fileSizeBytes: 24 * 1024 * 1024,
      ),
      VideoModel(
        id: 'vid_002',
        userId: 'user_admin_001',
        title: 'IPL Finals - Match Coverage',
        category: 'Cricket',
        tags: ['IPL', 'Finals', 'Live'],
        status: 'flagged',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        frameCount: 18,
        fileName: 'ipl_finals.mp4',
        fileSizeBytes: 18 * 1024 * 1024,
      ),
      VideoModel(
        id: 'vid_003',
        userId: 'user_001',
        title: 'Wimbledon Quarterfinal Analysis',
        category: 'Tennis',
        tags: ['Wimbledon', 'Grand Slam'],
        status: 'ready',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        frameCount: 15,
        fileName: 'wimbledon_qf.mp4',
        fileSizeBytes: 15 * 1024 * 1024,
      ),
      VideoModel(
        id: 'vid_004',
        userId: 'user_001',
        title: 'NBA Finals Game 7',
        category: 'Basketball',
        tags: ['NBA', 'Finals', 'Playoffs'],
        status: 'ready',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        frameCount: 12,
        fileName: 'nba_game7.mp4',
        fileSizeBytes: 12 * 1024 * 1024,
      ),
      VideoModel(
        id: 'vid_005',
        userId: 'user_admin_001',
        title: 'Olympic 100m Sprint Final',
        category: 'Athletics',
        tags: ['Olympics', 'Sprint', '100m'],
        status: 'flagged',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 12)),
        frameCount: 10,
        fileName: 'olympic_100m.mp4',
        fileSizeBytes: 8 * 1024 * 1024,
      ),
    ];
    _videos.addAll(seedVideos);

    // Seed frames for each video
    for (final video in seedVideos) {
      for (int i = 0; i < video.frameCount; i++) {
        _frames.add(FrameModel(
          id: 'frame_${video.id}_$i',
          videoId: video.id,
          timestampSeconds: i,
          caption: MockAIService.generateCaption(video.category, i),
          frameUrl: 'mock://frame_${video.id}_$i',
          createdAt: video.uploadedAt.add(Duration(seconds: i)),
        ));
      }
    }

    // Seed match results
    _matchResults.addAll([
      MatchResultModel(
        id: 'match_001',
        queryVideoId: 'vid_002',
        queryVideoTitle: 'IPL Finals - Match Coverage',
        matchedVideoId: 'vid_001',
        matchedVideoTitle: 'FIFA World Cup Highlights 2024',
        similarityScore: 0.82,
        riskLevel: 'High',
        matchedScenes: [
          const MatchedScene(
            queryTimestamp: 2,
            targetTimestamp: 3,
            similarity: 0.89,
            queryCaption: 'Crowd cheering enthusiastically in the stadium',
            targetCaption: 'Crowd cheering enthusiastically in the stadium',
          ),
          const MatchedScene(
            queryTimestamp: 5,
            targetTimestamp: 6,
            similarity: 0.75,
            queryCaption: 'Players in a tense tackle on the midfield',
            targetCaption: 'Player celebrating a goal with teammates',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MatchResultModel(
        id: 'match_002',
        queryVideoId: 'vid_005',
        queryVideoTitle: 'Olympic 100m Sprint Final',
        matchedVideoId: 'vid_003',
        matchedVideoTitle: 'Wimbledon Quarterfinal Analysis',
        similarityScore: 0.45,
        riskLevel: 'Medium',
        matchedScenes: [
          const MatchedScene(
            queryTimestamp: 1,
            targetTimestamp: 2,
            similarity: 0.52,
            queryCaption: 'Crowd on their feet applauding a great rally',
            targetCaption: 'Crowd watching intently from the stands',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MatchResultModel(
        id: 'match_003',
        queryVideoId: 'vid_004',
        queryVideoTitle: 'NBA Finals Game 7',
        matchedVideoId: 'vid_003',
        matchedVideoTitle: 'Wimbledon Quarterfinal Analysis',
        similarityScore: 0.22,
        riskLevel: 'Low',
        matchedScenes: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ]);
  }
}
