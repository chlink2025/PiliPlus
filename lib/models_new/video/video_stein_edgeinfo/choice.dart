import 'package:PiliPlus/models_new/video/video_detail/episode.dart';

class Choice extends BaseEpisodeItem {
  String? option;
  int? cursor;
  int? isCurrent;
  int? startPos;

  Choice({
    super.id,
    super.cid,
    this.option,
    this.cursor,
    this.isCurrent,
    this.startPos,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
    id: json['id'] as int?,
    cid: json['cid'] as int?,
    option: json['option'] as String?,
    cursor: json['cursor'] as int?,
    isCurrent: json['is_current'] as int?,
    startPos: json['start_pos'] as int?,
  );
}
