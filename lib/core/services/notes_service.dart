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

  Future<Note> createNote(String userId, String title, String content, List<String> tags, bool isPublic) async {
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
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
          if (isPublic) Permission.read(Role.any()),
        ],
      );
      return Note.fromJson(doc.data);
    } catch (e) {
      throw Exception('Failed to create note: $e');
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
