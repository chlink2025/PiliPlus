class PreloadVideo {
  int? aid;
  int? cid;
  int? id;

  PreloadVideo({
    this.aid,
    this.cid,
    this.id,
  });

  factory PreloadVideo.fromJson(Map<String, dynamic> json) => PreloadVideo(
    aid: json['aid'] as int?,
    cid: json['cid'] as int?,
    id: json['edge_id'] as int?,
  );
}

class PreloadInfo {
  List<PreloadVideo>? videos;

  PreloadInfo({this.videos});

  factory PreloadInfo.fromJson(Map<String, dynamic> json) => PreloadInfo(
    videos: (json['video'] as List<dynamic>?)
        ?.map((e) => PreloadVideo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
