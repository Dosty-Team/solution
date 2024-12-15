import 'package:flowmi/pages/set_commute_source_and_destination.dart';
import 'package:flowmi/state_manage/map_state/map_provider.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:developer' as dev;

class DatabaseService {
  // Assuming you have these variables defined globally:
  late mongo.Db db;
  late mongo.DbCollection coll;
  // Changed type to allow different data types (double and string)
  List<List<dynamic>> _coordinates = [];

  Future<void> connect() async {
    db = await mongo.Db.create(
        "mongodb+srv://giver_kdk:giverdb123@cluster0.lfo9ghw.mongodb.net/flowmi_db?retryWrites=true&w=majority&appName=Cluster0");
    await db.open();
    coll = db.collection('latest_lat_long_collection'); // Replace with your collection name
  }

  Future<void> insertSourceCoordinates(double latitude, double longitude, String sourceName) async {
    try {
      await connect(); // Call the connect function to establish connection
      var document = {
        'source_latitude': latitude,
        'source_longitude': longitude,
        'source_name': sourceName,
        'timestamp': DateTime.now().toIso8601String()
      };
      await coll.insertOne(document);
      print('Coordinates inserted: $document');
    } catch (e) {
      print('Error inserting coordinates: $e');
      rethrow;
    } finally {
      print('Database connection closed after insert');
    }
  }

  Future<void> insertDestinationCoordinates(double latitude, double longitude, String destName) async {
    try {
      await connect(); // Call the connect function to establish connection
      var document = {
        'destination_latitude': latitude,
        'destination_longitude': longitude,
        'destination_name': destName,
        'timestamp': DateTime.now().toIso8601String()
      };
      await coll.insertOne(document);
      print('Coordinates inserted: $document');
    } catch (e) {
      print('Error inserting coordinates: $e');
      rethrow;
    } finally {
      await db.close();
      print('Database connection closed after insert');
    }
  }

  Future<List<List<dynamic>>> fetchData() async {
    try {
      var db = await mongo.Db.create(
          "mongodb+srv://giver_kdk:giverdb123@cluster0.lfo9ghw.mongodb.net/flowmi_db?retryWrites=true&w=majority&appName=Cluster0");
      await db.open();
      var collection = db.collection('latest_lat_long_collection');
      var cursor = await collection
          .find(mongo.where.sortBy('timestamp', descending: true).limit(2));

      await cursor.forEach((v) {
        SourceAndDestinationCoordinates coordinates = SourceAndDestinationCoordinates();
        List<dynamic> sourceCoordinates = [];
        
        List<dynamic> destinationCoordinates = [];

        if (v.containsKey('source_latitude') && v.containsKey('source_longitude') && v.containsKey('source_name')) {
          coordinates.sourceLat = v['source_latitude'].toDouble();
          coordinates.sourceLong = v['source_longitude'].toDouble();

          // Add latitude and name to the sourceCoordinates list
          sourceCoordinates.add(v['source_latitude'].toDouble());
          sourceCoordinates.add(v['source_longitude'].toDouble());
          sourceCoordinates.add(v['source_name'].toString());
          _coordinates.add(sourceCoordinates);

        } else if (v.containsKey('destination_latitude') && v.containsKey('destination_longitude') && v.containsKey('destination_name')) {
          coordinates.destLat = v['destination_latitude'].toDouble();
          coordinates.destLong = v['destination_longitude'].toDouble();

          // Add latitude, longitude, and name to the destinationCoordinates list
          destinationCoordinates.add(v['destination_latitude'].toDouble());
          destinationCoordinates.add(v['destination_longitude'].toDouble());
          destinationCoordinates.add(v['destination_name'].toString());
          _coordinates.add(destinationCoordinates);
        } else {
          // Handle cases where latitude or longitude keys are missing
          print('Missing latitude or longitude in document: $v');
        }
        print('source ko coordinate in database server is $sourceCoordinates');
        print('destination ko coordinate in database server is $destinationCoordinates');
      });

      if(_coordinates.length == 2){
        return _coordinates;
      }
      await db.close();
      print(_coordinates);
      return _coordinates;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }
}
