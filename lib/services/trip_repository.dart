import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/trip.dart';

class TripRepository {
  const TripRepository();

  Future<Trip> load() async {
    final source = await rootBundle.loadString('assets/data/trip_data.json');
    return Trip.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
