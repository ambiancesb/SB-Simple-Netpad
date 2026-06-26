import 'package:netpad/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class InstanceConfig {
  InstanceConfig(this._prefs);

  final SharedPreferences _prefs;
  static const _keyId = 'instance_id';
  static const _keyName = 'display_name';
  static const _keyRoom = 'room_id';

  String? _id;
  String? _name;
  String? _room;

  String get instanceId {
    _id ??= _prefs.getString(_keyId);
    if (_id == null || _id!.isEmpty) {
      _id = const Uuid().v4();
      _prefs.setString(_keyId, _id!);
    }
    return _id!;
  }

  String get displayName {
    _name ??= _prefs.getString(_keyName);
    if (_name == null || _name!.isEmpty) {
      _name = _defaultName();
      _prefs.setString(_keyName, _name!);
    }
    return _name!;
  }

  Future<void> setDisplayName(String name) async {
    _name = name.trim().isEmpty ? _defaultName() : name.trim();
    await _prefs.setString(_keyName, _name!);
  }

  String get roomId {
    _room ??= _prefs.getString(_keyRoom);
    if (_room == null || _room!.isEmpty) {
      _room = kDefaultRoom;
      _prefs.setString(_keyRoom, _room!);
    }
    return _room!;
  }

  Future<void> setRoomId(String room) async {
    _room = room.trim().isEmpty ? kDefaultRoom : room.trim();
    await _prefs.setString(_keyRoom, _room!);
  }

  String _defaultName() {
    final short = instanceId.substring(0, 8);
    return 'Netpad-$short';
  }
}
