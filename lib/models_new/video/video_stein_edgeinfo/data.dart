import 'package:PiliPlus/models_new/video/video_stein_edgeinfo/edges.dart';
import 'package:PiliPlus/models_new/video/video_stein_edgeinfo/hidden_var.dart';
import 'package:PiliPlus/models_new/video/video_stein_edgeinfo/preload_info.dart';
import 'package:PiliPlus/models_new/video/video_stein_edgeinfo/story.dart';

class EdgeInfoData {
  Edges? edges;
  int? edgeId;
  String? title;
  List<Story>? storyList;
  int? isLeaf;
  int? noBacktracking;
  int? noTutorial;
  int? noEvaluation;
  List<HiddenVar>? hiddenVars;
  PreloadInfo? preload;

  EdgeInfoData({
    this.edges,
    this.edgeId,
    this.title,
    this.storyList,
    this.isLeaf,
    this.noBacktracking,
    this.noTutorial,
    this.noEvaluation,
    this.hiddenVars,
    this.preload,
  });

  factory EdgeInfoData.fromJson(Map<String, dynamic> json) => EdgeInfoData(
    edges: json['edges'] == null
        ? null
        : Edges.fromJson(json['edges'] as Map<String, dynamic>),
    edgeId: json['edge_id'] as int?,
    title: json['title'] as String?,
    storyList: (json['story_list'] as List<dynamic>?)
        ?.map((e) => Story.fromJson(e as Map<String, dynamic>))
        .toList(),
    isLeaf: json['is_leaf'] as int?,
    noBacktracking: json['no_backtracking'] as int?,
    noTutorial: json['no_tutorial'] as int?,
    noEvaluation: json['no_evaluation'] as int?,
    hiddenVars: (json['hidden_vars'] as List<dynamic>?)
        ?.map((e) => HiddenVar.fromJson(e as Map<String, dynamic>))
        .toList(),
    preload: json['preload'] == null
        ? null
        : PreloadInfo.fromJson(json['preload'] as Map<String, dynamic>),
  );
}
