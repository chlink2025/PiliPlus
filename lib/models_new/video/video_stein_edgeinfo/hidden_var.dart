class HiddenVar {
  String? id;
  String? name;
  double? value;
  int? show;
  int? skipOverwrite;

  HiddenVar({
    this.id,
    this.name,
    this.value,
    this.show,
    this.skipOverwrite,
  });

  factory HiddenVar.fromJson(Map<String, dynamic> json) => HiddenVar(
    id: json['id_v2'] as String?,
    name: json['name'] as String?,
    value: (json['value'] as num?)?.toDouble(),
    show: json['is_show'] as int?,
    skipOverwrite: json['skip_overwrite'] as int?,
  );
}
