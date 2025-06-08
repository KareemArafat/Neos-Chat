class RoomModel {
  final String roomId;
  final String? name;
  final String? type;
  final LastMassage? lastMessage;
  final List<String>? usersIds;
  final List<String>? ids;

  RoomModel({
    required this.roomId,
    this.name,
    this.type,
    this.lastMessage,
    this.usersIds,
    this.ids,
  });

  factory RoomModel.fromJson(jsonData) {
    return RoomModel(
      roomId: jsonData['id'],
      name: jsonData['name'],
      type: jsonData['type'],
      usersIds: List<String>.from(jsonData['memberUserIds']),
      ids: List<String>.from(jsonData['memberIds']),
      lastMessage:
          jsonData['lastMessage'] != null
              ? LastMassage.fromJson(jsonData['lastMessage'])
              : null,
    );
  }
}

class LastMassage {
  final String messType;
  final String time;
  final String? text;
  final String? fileName;
  final String? fileType;

  LastMassage({
    required this.messType,
    required this.time,
    this.text,
    this.fileName,
    this.fileType,
  });

  factory LastMassage.fromJson(jsonData) {
    return LastMassage(
      messType: jsonData['type'],
      time: jsonData['createdAt'],
      text: jsonData['content'],
      fileName: jsonData['fileName'],
      fileType: jsonData['fileType'],
    );
  }
}
