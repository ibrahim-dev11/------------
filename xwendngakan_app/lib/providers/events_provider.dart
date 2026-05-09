import 'package:flutter/material.dart';
import '../data/models/event_model.dart';
import '../data/services/api_service.dart';

class EventsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<EventModel> _events = [];
  bool _loading = false;
  String? _error;

  List<EventModel> get events => _events;
  bool get loading => _loading;
  String? get error => _error;

  // Selected day in calendar
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;

  void setSelectedDay(DateTime day, DateTime focused) {
    _selectedDay = day;
    _focusedDay = focused;
    notifyListeners();
  }

  List<EventModel> get eventsForSelectedDay {
    return _events.where((e) {
      final start = DateTime.tryParse(e.startDate);
      if (start == null) return false;
      return start.year == _selectedDay.year &&
          start.month == _selectedDay.month &&
          start.day == _selectedDay.day;
    }).toList();
  }

  List<EventModel> getEventsForDay(DateTime day) {
    return _events.where((e) {
      final start = DateTime.tryParse(e.startDate);
      if (start == null) return false;
      return start.year == day.year &&
          start.month == day.month &&
          start.day == day.day;
    }).toList();
  }

  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((e) {
      final start = DateTime.tryParse(e.startDate);
      return start != null && start.isAfter(now);
    }).toList()
      ..sort((a, b) => DateTime.parse(a.startDate).compareTo(DateTime.parse(b.startDate)));
  }

  Future<void> fetchEvents({bool refresh = false}) async {
    if (_events.isNotEmpty && !refresh) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final res = await _api.getEvents();

    if (res.success && res.data != null) {
      _events = res.data!.map((e) => EventModel.fromJson(e)).toList();
    } else {
      _error = res.error ?? 'Failed to load events';
    }

    _loading = false;
    notifyListeners();
  }
}
