import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/models/order_pos_data_base.dart';

enum ActivityManagerEventType { added, removed, updated }

class ActivityManager<T extends OrderPosDataBase> {
  final Map<int, T> _activities = <int, T>{};
  final Map<ActivityManagerEventType, List<Function(T)>> _listeners = <ActivityManagerEventType, List<Function(T)>>{};

  int get count => _activities.length;
  Iterable<T> get activities => _activities.values;
  T? activityBy({required int? id}) => _activities[id];
  Iterable<T> activitiesBy({required int symbolId}) {
    return _activities.values.where((T elem) => elem.symbolId == symbolId);
  }

  void _dispatchEvent(ActivityManagerEventType type, T activity) {
    for (final Function(T) l in _listeners[type] ?? <Function(T)>[]) {
      try {
        l(activity);
      } catch (e) {
        Logger.error('Error occurred at executing listener of activity event', e);
      }
    }
  }

  void addListener(ActivityManagerEventType type, Function(T) listener) {
    if (!_listeners.containsKey(type)) _listeners[type] = <Function(T)>[];

    if (!_listeners[type]!.contains(listener)) _listeners[type]?.add(listener);
  }

  void removeListener(ActivityManagerEventType type, Function(T) listener) {
    _listeners[type]?.remove(listener);
  }

  void addActivity(T activity) {
    _activities[activity.id] = activity;
    _dispatchEvent(ActivityManagerEventType.added, activity);
  }

  bool updateActivity(int id, dynamic data) {
    final T? activity = _activities[id];
    if (activity == null) return false;

    activity.update(data);
    _dispatchEvent(ActivityManagerEventType.updated, activity);

    return true;
  }

  bool removeActivity(int id) {
    final T? removed = _activities.remove(id);
    if (removed != null) {
      _dispatchEvent(ActivityManagerEventType.removed, removed);
      return true;
    }

    return false;
  }

  void clear() {
    for (final T a in activities) {
      _dispatchEvent(ActivityManagerEventType.removed, a);
    }

    _activities.clear();
  }

  void dispatchActivityUpdatedEvent(T activity) {
    _dispatchEvent(ActivityManagerEventType.updated, activity);
  }
}
