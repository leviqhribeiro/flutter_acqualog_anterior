
import 'package:json_annotation/json_annotation.dart';

part 'manager.g.dart';

@JsonSerializable()
class Manager {
  Manager(this.id, this.name);
  int id;
  String name;

  factory Manager.fromJson(Map<String, dynamic> json) =>
      _$ManagerFromJson(json);

  Map<String, dynamic> toJson() => _$ManagerToJson(this);
}