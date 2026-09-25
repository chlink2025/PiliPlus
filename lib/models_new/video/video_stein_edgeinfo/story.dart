import 'package:PiliPlus/models_new/video/video_detail/episode.dart';

class Story extends BaseEpisodeItem {
  int? cursor;
  int? isCurrent;
  int? startPos;

  Story({
    super.id,
    super.cid,
    super.title,
    super.cover,
    this.cursor,
    this.isCurrent,
    this.startPos,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
    id: json['edge_id'] as int?,
    cid: json['cid'] as int?,
    title: json['title'] as String?,
    cover: json['cover'] as String?,
    cursor: json['cursor'] as int?,
    isCurrent: json['is_current'] as int?,
    startPos: json['start_pos'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'edge_id': id,
    'cid': cid,
    'title': title,
    'cover': cover,
    'cursor': cursor,
    'is_current': isCurrent,
    'start_pos': startPos,
  };
}
