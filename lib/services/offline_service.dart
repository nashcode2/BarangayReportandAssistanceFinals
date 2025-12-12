import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/report_model.dart';
import '../models/announcement_model.dart';
import '../models/event_model.dart';
import '../models/service_request_model.dart';

/// Service for offline data storage and synchronization
class OfflineService {
  static Database? _database;
  static const String _databaseName = 'barangay_offline.db';
  static const int _databaseVersion = 1;

  /// Initialize offline database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Reports table
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        userId TEXT,
        userName TEXT,
        issueType TEXT,
        description TEXT,
        photoUrl TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        status TEXT,
        createdAt INTEGER,
        updatedAt INTEGER,
        assignedStaffId TEXT,
        assignedStaffName TEXT,
        notes TEXT,
        resolution TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Announcements table
    await db.execute('''
      CREATE TABLE announcements (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        fullDescription TEXT,
        imageUrl TEXT,
        createdBy TEXT,
        createdByName TEXT,
        createdAt INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        eventType TEXT,
        startDate INTEGER,
        endDate INTEGER,
        location TEXT,
        imageUrl TEXT,
        createdBy TEXT,
        createdByName TEXT,
        createdAt INTEGER,
        rsvpUserIds TEXT,
        isActive INTEGER DEFAULT 1,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Service requests table
    await db.execute('''
      CREATE TABLE service_requests (
        id TEXT PRIMARY KEY,
        userId TEXT,
        userName TEXT,
        serviceType TEXT,
        description TEXT,
        preferredDate INTEGER,
        address TEXT,
        status TEXT,
        createdAt INTEGER,
        scheduledDate INTEGER,
        completedDate INTEGER,
        assignedStaffId TEXT,
        assignedStaffName TEXT,
        notes TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Pending operations table (for sync)
    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT,
        collection_name TEXT,
        document_id TEXT,
        data TEXT,
        created_at INTEGER
      )
    ''');
  }

  // Reports offline methods
  static Future<void> saveReportOffline(ReportModel report) async {
    final db = await database;
    await db.insert(
      'reports',
      {
        'id': report.id,
        'userId': report.userId,
        'userName': report.userName,
        'issueType': report.issueType,
        'description': report.description,
        'photoUrl': report.photoUrl,
        'latitude': report.latitude,
        'longitude': report.longitude,
        'address': report.address,
        'status': report.status,
        'createdAt': report.createdAt.millisecondsSinceEpoch,
        'updatedAt': report.updatedAt?.millisecondsSinceEpoch,
        'assignedStaffId': report.assignedStaffId,
        'assignedStaffName': report.assignedStaffName,
        'notes': report.notes?.join(','),
        'resolution': report.resolution,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ReportModel>> getReportsOffline(String userId) async {
    final db = await database;
    final maps = await db.query(
      'reports',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) {
      return ReportModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        userName: map['userName'] as String,
        issueType: map['issueType'] as String,
        description: map['description'] as String,
        photoUrl: map['photoUrl'] as String?,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        address: map['address'] as String?,
        status: map['status'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updatedAt: map['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
            : null,
        assignedStaffId: map['assignedStaffId'] as String?,
        assignedStaffName: map['assignedStaffName'] as String?,
        notes: map['notes'] != null
            ? (map['notes'] as String).split(',').where((s) => s.isNotEmpty).toList()
            : null,
        resolution: map['resolution'] as String?,
      );
    }).toList();
  }

  // Announcements offline methods
  static Future<void> saveAnnouncementOffline(AnnouncementModel announcement) async {
    final db = await database;
    await db.insert(
      'announcements',
      {
        'id': announcement.id,
        'title': announcement.title,
        'description': announcement.description,
        'fullDescription': announcement.fullDescription,
        'imageUrl': announcement.imageUrl,
        'createdBy': announcement.createdBy,
        'createdByName': announcement.createdByName,
        'createdAt': announcement.createdAt.millisecondsSinceEpoch,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<AnnouncementModel>> getAnnouncementsOffline() async {
    final db = await database;
    final maps = await db.query(
      'announcements',
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) {
      return AnnouncementModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        fullDescription: map['fullDescription'] as String?,
        imageUrl: map['imageUrl'] as String?,
        createdBy: map['createdBy'] as String,
        createdByName: map['createdByName'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
    }).toList();
  }

  // Events offline methods
  static Future<void> saveEventOffline(EventModel event) async {
    final db = await database;
    await db.insert(
      'events',
      {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'eventType': event.eventType,
        'startDate': event.startDate.millisecondsSinceEpoch,
        'endDate': event.endDate.millisecondsSinceEpoch,
        'location': event.location,
        'imageUrl': event.imageUrl,
        'createdBy': event.createdBy,
        'createdByName': event.createdByName,
        'createdAt': event.createdAt.millisecondsSinceEpoch,
        'rsvpUserIds': event.rsvpUserIds.join(','),
        'isActive': event.isActive ? 1 : 0,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<EventModel>> getEventsOffline() async {
    final db = await database;
    final maps = await db.query(
      'events',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'startDate ASC',
    );

    return maps.map((map) {
      return EventModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        eventType: map['eventType'] as String,
        startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
        endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
        location: map['location'] as String?,
        imageUrl: map['imageUrl'] as String?,
        createdBy: map['createdBy'] as String,
        createdByName: map['createdByName'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        rsvpUserIds: map['rsvpUserIds'] != null
            ? (map['rsvpUserIds'] as String).split(',').where((s) => s.isNotEmpty).toList()
            : [],
        isActive: (map['isActive'] as int) == 1,
      );
    }).toList();
  }

  // Service requests offline methods
  static Future<void> saveServiceRequestOffline(ServiceRequestModel request) async {
    final db = await database;
    await db.insert(
      'service_requests',
      {
        'id': request.id,
        'userId': request.userId,
        'userName': request.userName,
        'serviceType': request.serviceType,
        'description': request.description,
        'preferredDate': request.preferredDate.millisecondsSinceEpoch,
        'address': request.address,
        'status': request.status,
        'createdAt': request.createdAt.millisecondsSinceEpoch,
        'scheduledDate': request.scheduledDate?.millisecondsSinceEpoch,
        'completedDate': request.completedDate?.millisecondsSinceEpoch,
        'assignedStaffId': request.assignedStaffId,
        'assignedStaffName': request.assignedStaffName,
        'notes': request.notes,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ServiceRequestModel>> getServiceRequestsOffline(String userId) async {
    final db = await database;
    final maps = await db.query(
      'service_requests',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) {
      return ServiceRequestModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        userName: map['userName'] as String,
        serviceType: map['serviceType'] as String,
        description: map['description'] as String,
        preferredDate: DateTime.fromMillisecondsSinceEpoch(map['preferredDate'] as int),
        address: map['address'] as String?,
        status: map['status'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        scheduledDate: map['scheduledDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['scheduledDate'] as int)
            : null,
        completedDate: map['completedDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'] as int)
            : null,
        assignedStaffId: map['assignedStaffId'] as String?,
        assignedStaffName: map['assignedStaffName'] as String?,
        notes: map['notes'] as String?,
      );
    }).toList();
  }

  /// Mark data as synced
  static Future<void> markAsSynced(String table, String id) async {
    final db = await database;
    await db.update(
      table,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all offline data
  static Future<void> clearAllOfflineData() async {
    final db = await database;
    await db.delete('reports');
    await db.delete('announcements');
    await db.delete('events');
    await db.delete('service_requests');
    await db.delete('pending_operations');
  }

  /// Get sync status
  static Future<Map<String, int>> getSyncStatus() async {
    final db = await database;
    final reports = await db.rawQuery('SELECT COUNT(*) as count FROM reports WHERE synced = 0');
    final announcements = await db.rawQuery('SELECT COUNT(*) as count FROM announcements WHERE synced = 0');
    final events = await db.rawQuery('SELECT COUNT(*) as count FROM events WHERE synced = 0');
    final requests = await db.rawQuery('SELECT COUNT(*) as count FROM service_requests WHERE synced = 0');

    return {
      'reports': reports.first['count'] as int,
      'announcements': announcements.first['count'] as int,
      'events': events.first['count'] as int,
      'service_requests': requests.first['count'] as int,
    };
  }
}

