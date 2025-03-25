import 'package:hive/hive.dart';

part 'download_item.g.dart'; // Ensure this is correctly placed

@HiveType(typeId: 0)
class DownloadItem extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final String videoPath;

  @HiveField(4)
  final String channelName;

  @HiveField(5)
  final String videoUploadType;

  DownloadItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.videoPath,
    required this.channelName,
    required this.videoUploadType,
  });
}
