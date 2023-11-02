import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/local_database_model/attendance_break.dart';
import '../model/local_database_model/attendance_employee.dart';
import '../model/local_database_model/employee.dart';

class DatabaseService {
  static final DatabaseService _databaseService = DatabaseService._internal();

  factory DatabaseService() => _databaseService;

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    String path = join(databasePath, 'eHubt-Mobile.db');

    return await openDatabase(
      path,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        var batch = db.batch();
        if (newVersion > oldVersion) {
          print("New Version : $newVersion");
          print("old Version : $oldVersion");

          await db.execute("ALTER TABLE employee ADD COLUMN empCode TEXT;");

          await db.execute("ALTER TABLE Attendance_Employee ADD COLUMN empCode TEXT;");

          await db.execute("ALTER TABLE Attendance_Break ADD COLUMN empCode TEXT;");

          // // We update existing table and create the new tables
          // _updateTableCompanyV1toV2(batch);
          // _createTableEmployeeV2(batch);
        }
        await batch.commit();
      },
      version: 2,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE {employee} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE employee(id INTEGER PRIMARY KEY,userId TEXT,empCode TEXT,name TEXT, branchId TEXT,tabletId TEXT,jobType TEXT)',
    );

    // Run the CREATE {Attendance_Employee} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE Attendance_Employee(id INTEGER PRIMARY KEY, userId TEXT,empCode TEXT,empName TEXT,attendanceDate TEXT,Cl1 TEXT,Co1 TEXT,Cl2 TEXT,Co2 TEXT,Cl3 TEXT,Co3 TEXT,Cl4 TEXT,Co4 TEXT,Cl5 TEXT,Co5 TEXT,Cl6 TEXT,Co6 TEXT,Cl7 TEXT,Co7 TEXT,Cl8 TEXT,Co8 TEXT,Cl9 TEXT,Co9 TEXT,Cl10 TEXT,Co10 TEXT,Cl11 TEXT,Co11 TEXT,Cl12 TEXT,Co12 TEXT,Cl13 TEXT,Co13 TEXT,Cl14 TEXT,Co14 TEXT,Cl15 TEXT,Co15 TEXT,Cl16 TEXT,Co16 TEXT,Cl17 TEXT,Co17 TEXT,Cl18 TEXT,Co18 TEXT,Cl19 TEXT,Co19 TEXT,Cl20 TEXT,Co20 TEXT,addressIn1 TEXT,addressIn2 TEXT,addressIn3 TEXT,addressIn4 TEXT,addressIn5 TEXT,addressIn6 TEXT,addressIn7 TEXT,addressIn8 TEXT,addressIn9 TEXT,addressIn10 TEXT,addressIn11 TEXT,addressIn12 TEXT,addressIn13 TEXT,addressIn14 TEXT,addressIn15 TEXT,addressIn16 TEXT,addressIn17 TEXT,addressIn18 TEXT,addressIn19 TEXT,addressIn20 TEXT,addressOut1 TEXT,addressOut2 TEXT,addressOut3 TEXT,addressOut4 TEXT,addressOut5 TEXT,addressOut6 TEXT,addressOut7 TEXT,addressOut8 TEXT,addressOut9 TEXT,addressOut10 TEXT,addressOut11 TEXT,addressOut12 TEXT,addressOut13 TEXT,addressOut14 TEXT,addressOut15 TEXT,addressOut16 TEXT,addressOut17 TEXT,addressOut18 TEXT,addressOut19 TEXT,addressOut20 TEXT,image1 TEXT,image2 TEXT,image3 TEXT,image4 TEXT,image5 TEXT,image6 TEXT,image7 TEXT,image8 TEXT,image9 TEXT,image10 TEXT,image11 TEXT,image12 TEXT,image13 TEXT,image14 TEXT,image15 TEXT,image16 TEXT,image17 TEXT,image18 TEXT,image19 TEXT,image20 TEXT,imageOut1 TEXT,imageOut2 TEXT,imageOut3 TEXT,imageOut4 TEXT,imageOut5 TEXT,imageOut6 TEXT,imageOut7 TEXT,imageOut8 TEXT,imageOut9 TEXT,imageOut10 TEXT,imageOut11 TEXT,imageOut12 TEXT,imageOut13 TEXT,imageOut14 TEXT,imageOut15 TEXT,imageOut16 TEXT,imageOut17 TEXT,imageOut18 TEXT,imageOut19 TEXT,imageOut20 TEXT,Clock_In_Out_Counter TEXT,Break_In_Out_Counter TEXT,Last_Status TEXT,lastBreakTableId TEXT,uploadStatus TEXT,tabletUserId TEXT,createAt DATE,jobType TEXT)',
    );

    // Run the CREATE {Attendance_Break} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE Attendance_Break(id INTEGER PRIMARY KEY, userId TEXT,empCode TEXT,empName TEXT, attendanceDate TEXT, breakTime TEXT,breakEndTime TEXT,breakInImage TEXT,breakOutImage TEXT,breakInAddress TEXT,breakOutAddress TEXT,uploadStatus TEXT,tabletUserId TEXT,createAt DATE,jobType TEXT)',
    );
  }

  /// Define a function that inserts Employee into the database
  Future<void> insertEmployee(Employee employee) async {
    final db = await _databaseService.database;
    await db.insert(
      'employee',
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Define a function that inserts Attendance Employee into the database
  Future<void> insertAttendance(AttendanceEmployee attendanceEmployee) async {
    final db = await _databaseService.database;
    await db.insert(
      'Attendance_Employee',
      attendanceEmployee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Define a function that inserts Attendance Break into the database
  insertBreak(AttendanceBreak attendanceBreak) async {
    final db = await _databaseService.database;
    final insertedId = await db.insert(
      'Attendance_Break',
      attendanceBreak.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return insertedId;
  }

  ///Check Employee Available In Database
  Future<Employee?> checkEmp(String empId) async {
    final db = await _databaseService.database;
    var res = await db.rawQuery("SELECT * FROM employee WHERE userId = '$empId'");
    if (res.length > 0) {
      return new Employee.fromMap(res.first);
    }
    return null;
  }

  ///Check Employee Pin In Database
  Future<Employee?> checkEmpPin(String empPin) async {
    final db = await _databaseService.database;
    var res = await db.rawQuery("SELECT * FROM employee WHERE empPin = '$empPin'");
    if (res.length > 0) {
      return new Employee.fromMap(res.first);
    }
    return null;
  }

  ///Get Employee Pin In Database
  Future<Employee?> getEmpPin(String empCode) async {
    final db = await _databaseService.database;
    var res = await db.rawQuery("SELECT * FROM employee WHERE empCode = '$empCode'");
    if (res.length > 0) {
      return new Employee.fromMap(res.first);
    }
    return null;
  }

  ///Check Attendance Table Available In Database
  Future<AttendanceEmployee?> checkAttendanceEmp(String userId, String attendanceDate, String jobType) async {
    final db = await _databaseService.database;
    var res = await db
        .rawQuery("SELECT * FROM Attendance_Employee WHERE userId = '$userId' and attendanceDate = '$attendanceDate' and jobType = '$jobType'");
    if (res.length > 0) {
      return new AttendanceEmployee.fromMap(res.first);
    }
    return null;
  }

  ///Check Attendace Table Available In Database
  Future<AttendanceEmployee?> checkAttendanceEmp1(String empCode, String attendanceDate) async {
    final db = await _databaseService.database;
    var res = await db.rawQuery("SELECT * FROM Attendance_Employee WHERE empCode = '$empCode' and attendanceDate = '$attendanceDate'");
    if (res.length > 0) {
      return new AttendanceEmployee.fromMap(res.first);
    }
    return null;
  }
}
