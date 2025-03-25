// To parse this JSON data, do
//
//     final addRemoveLikeDifood_appModel = addRemoveLikeDifood_appModelFromJson(jsonString);

import 'dart:convert';

AddRemoveLikeDifood_appModel addRemoveLikeDifood_appModelFromJson(String str) =>
    AddRemoveLikeDifood_appModel.fromJson(json.decode(str));

String addRemoveLikeDifood_appModelToJson(AddRemoveLikeDifood_appModel data) =>
    json.encode(data.toJson());

class AddRemoveLikeDifood_appModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddRemoveLikeDifood_appModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddRemoveLikeDifood_appModel.fromJson(Map<String, dynamic> json) =>
      AddRemoveLikeDifood_appModel(
        status: json["status"],
        message: json["message"],
        result: List<dynamic>.from(json["result"]?.map((x) => x) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x) ?? []),
      };
}
