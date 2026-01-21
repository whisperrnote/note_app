import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_constants.dart';
import 'appwrite_service.dart';
import '../models/note_model.dart';

class NotesService {
  final Databases _databases = AppwriteService().databases;

  Future<List<Note>> listNotes(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notesCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents.map((doc) => Note.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to list notes: $e');
    }
  }

  Future<Note> createNote({
    required String userId,
    required String title,
    required String content,
    List<String> tags = const [],
    bool isPublic = false,
    List<String> collaboratorIds = const [],
    String? doodleData,
    List<String> attachmentIds = const [],
    bool isPinned = false,
  }) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notesCollectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'content': content,
          'tags': tags,
          'isPublic': isPublic,
          'userId': userId,
          'collaboratorIds': collaboratorIds,
          'doodleData': doodleData,
          'attachmentIds': attachmentIds,
          'isPinned': isPinned,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
          if (isPublic) Permission.read(Role.any()),
          ...collaboratorIds.map((id) => Permission.read(Role.user(id))),
          ...collaboratorIds.map((id) => Permission.update(Role.user(id))),
        ],
      );
      return Note.fromJson(doc.data);
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Future<void> updateNote({
    required String noteId,
    String? title,
    String? content,
    List<String>? tags,
    bool? isPublic,
    List<String>? collaboratorIds,
    String? doodleData,
    List<String>? attachmentIds,
    bool? isPinned,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (tags != null) data['tags'] = tags;
      if (isPublic != null) data['isPublic'] = isPublic;
      if (collaboratorIds != null) data['collaboratorIds'] = collaboratorIds;
      if (doodleData != null) data['doodleData'] = doodleData;
      if (attachmentIds != null) data['attachmentIds'] = attachmentIds;
      if (isPinned != null) data['isPinned'] = isPinned;

      await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notesCollectionId,
        documentId: noteId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<List<NoteComment>> listComments(String noteId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.commentsCollectionId,
        queries: [Query.equal('noteId', noteId), Query.orderAsc('\$createdAt')],
      );
      return response.documents
          .map((doc) => NoteComment.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to list comments: $e');
    }
  }

  Future<NoteComment> addComment(
    String noteId,
    String userId,
    String content,
  ) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.commentsCollectionId,
        documentId: ID.unique(),
        data: {
          'noteId': noteId,
          'userId': userId,
          'content': content,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      return NoteComment.fromJson(doc.data);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notesCollectionId,
        documentId: noteId,
      );
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}
