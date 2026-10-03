import 'package:PiliPlus/models/dynamics/result.dart' show ModuleCollection;
import 'package:PiliPlus/models/model_avatar.dart';
import 'package:PiliPlus/models_new/article/article_view/ops.dart';
import 'package:PiliPlus/models_new/article/article_view/opus.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';

class ArticleViewData {
  int? id;
  String? title;
  Avatar? author;
  int? publishTime;
  List<String>? originImageUrls;
  int? type;
  String? content;
  String? dynIdStr;
  ArticleOpus? opus;
  List<ArticleOps>? ops;

  /// /x/article/view 返回的文集信息(list)
  ModuleCollection? collection;

  ArticleViewData({
    this.id,
    this.author,
    this.publishTime,
    this.originImageUrls,
    this.type,
    this.content,
    this.dynIdStr,
    this.opus,
    this.ops,
    this.collection,
  });

  factory ArticleViewData.fromJson(Map<String, dynamic> json) {
    ModuleCollection? collection;
    if (json['list'] case final Map list) {
      final count = (list['articles_count'] as num?)?.toInt() ?? 0;
      collection = ModuleCollection.fromJson({
        'id': list['id'],
        'name': list['name'],
        'title': '收录于文集',
        'count': count > 0 ? '$count篇' : null,
      });
    }
    return ArticleViewData(
      id: json['id'] as int?,
      author: json['author'] == null
          ? null
          : Avatar.fromJson(json['author'] as Map<String, dynamic>),
      publishTime: json['publish_time'] as int?,
      originImageUrls: (json['origin_image_urls'] as List?)?.fromCast(),
      type: json['type'] as int?,
      content: json['content'] as String?,
      dynIdStr: json['dyn_id_str'] as String?,
      opus: json['opus'] == null
          ? null
          : ArticleOpus.fromJson(json['opus'] as Map<String, dynamic>),
      ops: (json['ops'] as List?)
          ?.map((e) => ArticleOps.fromJson(e))
          .toList(),
      collection: collection,
    );
  }
}
