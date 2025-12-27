import 'dart:convert';

class Item {
  Item({
    required this.id,
    required this.by,
    required this.time,
    required this.text,
    required this.url,
    required this.title,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      by: map['by'] as String?,
      time: map['time'] as int?,
      text: map['text'] as String?,
      url: map['url'] as String?,
      title: map['title'] as String?,
    );
  }

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source) as Map<String, dynamic>);

  final int? id;
  final String? by;
  final int? time;
  final String? text;
  final String? url;
  final String? title;

  Item copyWith({
    int? id,
    String? by,
    int? time,
    String? text,
    String? url,
    String? title,
  }) {
    return Item(
      id: id ?? this.id,
      by: by ?? this.by,
      time: time ?? this.time,
      text: text ?? this.text,
      url: url ?? this.url,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'by': by,
      'time': time,
      'text': text,
      'url': url,
      'title': title,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Item(id: $id, by: $by, time: $time, text: $text, url: $url, title: $title)';
  }

  @override
  bool operator ==(covariant Item other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.by == by &&
        other.time == time &&
        other.text == text &&
        other.url == url &&
        other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^ by.hashCode ^ time.hashCode ^ text.hashCode ^ url.hashCode ^ title.hashCode;
  }
}
