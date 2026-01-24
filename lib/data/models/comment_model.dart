// File: comment_model.dart
// Model untuk comment pada prediction session

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userRole: json['userRole'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
