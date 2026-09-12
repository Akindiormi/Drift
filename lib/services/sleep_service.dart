import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles the entire streak/log core loop locally on-device.
///
/// Deliberately backend-free: no Firebase project, no auth, no security
/// rules to set up before testers can install and use it today. All state
/// lives in SharedPreferences. If the test validates the hook, this is the
/// one file to swap for a Firestore-backed version later — the API
/// (currentStreak, longestStreak, hasLoggedToday, logTonight) stays the same.
class SleepService extends ChangeNotifier {
  SleepService._();
  static final SleepService instance = SleepService._();

  static const _kStreak = 'drift_streak';
  static const _kLongest = 'drift_longest_streak';
  static const _kLastLogDate = 'drift_last_log_date'; // yyyy-MM-dd
  static const _kBedtimeHour = 'drift_bedtime_hour';
  static const _kBedtimeMinute = 'drift_bedtime_minute';
  static const _kTotalLogs = 'drift_total_logs';

  late SharedPreferences _prefs;

  int _streak = 0;
  int _longestStreak = 0;
  String? _lastLogDate;
  int _totalLogs = 0;
  int bedtimeHour = 22;
  int bedtimeMinute = 30;

  int get currentStreak => _streak;
  int get longestStreak => _longestStreak;
  int get totalLogs => _totalLogs;

  bool get hasLoggedToday => _lastLogDate == _todayKey();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _streak = _prefs.getInt(_kStreak) ?? 0;
    _longestStreak = _prefs.getInt(_kLongest) ?? 0;
    _lastLogDate = _prefs.getString(_kLastLogDate);
    _totalLogs = _prefs.getInt(_kTotalLogs) ?? 0;
    bedtimeHour = _prefs.getInt(_kBedtimeHour) ?? 22;
    bedtimeMinute = _prefs.getInt(_kBedtimeMinute) ?? 30;

    // If a day was missed entirely (not just "not yet today"), reset streak.
    if (_lastLogDate != null && !hasLoggedToday) {
      final last = DateTime.parse(_lastLogDate!);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yKey = _keyFor(yesterday);
      if (_keyFor(last) != yKey) {
        _streak = 0;
        await _prefs.setInt(_kStreak, 0);
      }
    }
    notifyListeners();
  }

  /// Logs tonight's sleep. Returns the new streak count, or null if already
  /// logged today (no-op).
  Future<int?> logTonight() async {
    if (hasLoggedToday) return null;

    final today = _todayKey();
    final yesterdayKey = _keyFor(DateTime.now().subtract(const Duration(days: 1)));

    if (_lastLogDate == yesterdayKey) {
      _streak += 1;
    } else {
      _streak = 1;
    }
    if (_streak > _longestStreak) _longestStreak = _streak;
    _totalLogs += 1;
    _lastLogDate = today;

    await _prefs.setInt(_kStreak, _streak);
    await _prefs.setInt(_kLongest, _longestStreak);
    await _prefs.setString(_kLastLogDate, _lastLogDate!);
    await _prefs.setInt(_kTotalLogs, _totalLogs);

    notifyListeners();
    return _streak;
  }

  Future<void> setBedtime(int hour, int minute) async {
    bedtimeHour = hour;
    bedtimeMinute = minute;
    await _prefs.setInt(_kBedtimeHour, hour);
    await _prefs.setInt(_kBedtimeMinute, minute);
    notifyListeners();
  }

  String _todayKey() => _keyFor(DateTime.now());

  String _keyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
