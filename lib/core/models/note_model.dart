class Note {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final bool isPublic;
  final String userId;
  final List<String> collaboratorIds;
  final String? doodleData; // Base64 or JSON for drawing
  final List<String> attachmentIds;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.isPublic,
    required this.userId,
    this.collaboratorIds = const [],
    this.doodleData,
    this.attachmentIds = const [],
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['\$id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? false,
      userId: json['userId'] ?? '',
      collaboratorIds: List<String>.from(json['collaboratorIds'] ?? []),
      doodleData: json['doodleData'],
      attachmentIds: List<String>.from(json['attachmentIds'] ?? []),
      isPinned: json['isPinned'] ?? false,
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'])
          : DateTime.now(),
      updatedAt: json['\$updatedAt'] != null
          ? DateTime.parse(json['\$updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
      'isPublic': isPublic,
      'userId': userId,
      'collaboratorIds': collaboratorIds,
      'doodleData': doodleData,
      'attachmentIds': attachmentIds,
      'isPinned': isPinned,
    };
  }
}

class NoteComment {
  final String id;
  final String noteId;
  final String userId;
  final String content;
  final DateTime createdAt;

  NoteComment({
    required this.id,
    required this.noteId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory NoteComment.fromJson(Map<String, dynamic> json) {
    return NoteComment(
      id: json['\$id'] ?? '',
      noteId: json['noteId'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'])
          : DateTime.now(),
    );
  }
}
