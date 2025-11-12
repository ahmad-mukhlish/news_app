class SourceDto {
  final String? id;
  final String? name;

  SourceDto({
    this.id,
    this.name,
  });

  factory SourceDto.fromJson(Map<String, dynamic> json) {
    return SourceDto(
      id: json['id'],
      name: json['name'],
    );
  }
}
