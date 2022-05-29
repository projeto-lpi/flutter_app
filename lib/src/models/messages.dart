// ignore_for_file: non_constant_identifier_names

class Message {
  late int id;
  late int from_id;
  late int to_id;
  late String content;
  late String file;

  Message(this.id, this.from_id, this.to_id, this.content, this.file);

  factory Message.fromJson(dynamic json) {
    return Message(
        json['ID'] as int,
        json['from_id'] as int,
        json['to_id'] as int,
        json['content'] as String,
        json['file'] as String);
  }
}
