import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_constants.dart';
import 'appwrite_service.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class NotesService {
  final Databases _databases = AppwriteService().databases;
  final Storage _storage = AppwriteService().storage;
  final Realtime _realtime = AppwriteService().realtime;

  RealtimeSubscription subscribeToNotes(String userId) {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.notesCollectionId}.documents',
    ]);
  }

  RealtimeSubscription subscribeToComments(String noteId) {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.commentsCollectionId}.documents',
    ]);
  }

  Future<List<Note>> listNotes(String userId) async {
    if (AppConstants.useMockMode) {
      return [
        Note(
          id: '1',
          title: 'Welcome to WhisperrNote',
          content: 'This is a mock note for testing.',
          tags: ['welcome', 'mock'],
          isPublic: false,
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Note(
          id: '2',
          title: 'Mock Note 2',
          content: 'Another mock note content.',
          tags: ['test'],
          isPublic: false,
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    }
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

  Future<List<Note>> getSharedNotes(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notesCollectionId,
        queries: [
          Query.contains('collaboratorIds', [userId]),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents.map((doc) => Note.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to get shared notes: $e');
    }
  }

  Future<List<Note>> listPublicNotesByUser(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notesCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('isPublic', true),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents.map((doc) => Note.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to list public notes: $e');
    }
  }

  Future<List<Note>> listNotesBySearch(String userId, String query) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notesCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.or([
            Query.search('title', query),
            Query.search('content', query),
          ]),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents.map((doc) => Note.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to search notes: $e');
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

  Future<String> uploadAttachment(String filePath, String fileName) async {
    try {
      final file = await _storage.createFile(
        bucketId: AppwriteConstants.notesAttachmentsBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath, filename: fileName),
      );
      return file.$id;
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
    }
  }

  String getFilePreview(String fileId) {
    return _storage
        .getFilePreview(
          bucketId: AppwriteConstants.notesAttachmentsBucketId,
          fileId: fileId,
        )
        .toString();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        queries: [
          Query.or([Query.search('name', query), Query.search('email', query)]),
          Query.limit(5),
        ],
      );
      return response.documents
          .map((doc) => UserModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: userId,
      );
      return UserModel.fromJson(doc.data);
    } catch (e) {
      return null;
    }
  }
}
