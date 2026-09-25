class SteinNode {
  int? edgeId;
  int? cid;
  String? title;
  int? cursor;

  SteinNode({
    this.edgeId,
    this.cid,
    this.title,
    this.cursor,
  });

  factory SteinNode.fromJson(Map<String, dynamic> json) => SteinNode(
    edgeId: json['edge_id'] as int?,
    cid: json['cid'] as int?,
    title: json['title'] as String?,
    cursor: json['cursor'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'edge_id': edgeId,
    'cid': cid,
    'title': title,
    'cursor': cursor,
  };
}
