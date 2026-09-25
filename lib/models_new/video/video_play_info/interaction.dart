class Interaction {
  HistoryNode? historyNode;
  int? graphVersion;
  int? isInteraction;

  Interaction({
    this.historyNode,
    this.graphVersion,
    this.isInteraction,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) => Interaction(
    historyNode: json["history_node"] == null
        ? null
        : HistoryNode.fromJson(json["history_node"]),
    graphVersion: json["graph_version"],
    isInteraction: json["is_interaction"],
  );
}

class HistoryNode {
  int? nodeId;
  String? title;
  int? cid;

  HistoryNode({
    this.nodeId,
    this.title,
    this.cid,
  });

  factory HistoryNode.fromJson(Map<String, dynamic> json) => HistoryNode(
    nodeId: json["node_id"],
    title: json["title"],
    cid: json["cid"],
  );
}
