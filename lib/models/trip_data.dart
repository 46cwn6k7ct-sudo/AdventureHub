import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class TripData {
  final TripInfo trip;
  final List<ItineraryItem> itinerary;
  final List<AccommodationItem> accommodation;
  final List<TransportItem> transport;
  final List<BudgetItem> budget;
  final List<WishlistItem> wishlist;
  final Map<String, List<String>> packing;

  TripData({
    required this.trip,
    required this.itinerary,
    required this.accommodation,
    required this.transport,
    required this.budget,
    required this.wishlist,
    required this.packing,
  });

  static Future<TripData> load() async {
    final raw = await rootBundle.loadString('assets/data/trip_data.json');
    final Map<String, dynamic> json = jsonDecode(raw);

    final trip = TripInfo.fromJson(json['trip'] as Map<String, dynamic>);

    final itinerary = (json['itinerary'] as List<dynamic>)
        .map((e) => ItineraryItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final accommodation = (json['accommodation'] as List<dynamic>)
        .map((e) => AccommodationItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final transport = (json['transport'] as List<dynamic>)
        .map((e) => TransportItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final budget = (json['budget'] as List<dynamic>)
        .map((e) => BudgetItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final wishlist = (json['wishlist'] as List<dynamic>)
        .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final packing = <String, List<String>>{};
    if (json['packing'] is Map<String, dynamic>) {
      (json['packing'] as Map<String, dynamic>).forEach((key, value) {
        packing[key] = (value as List<dynamic>).cast<String>();
      });
    }

    return TripData(
      trip: trip,
      itinerary: itinerary,
      accommodation: accommodation,
      transport: transport,
      budget: budget,
      wishlist: wishlist,
      packing: packing,
    );
  }
}

class TripInfo {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String travellers;
  final String homeCurrency;
  final String tripCurrency;
  final double nzdToGbp;

  TripInfo({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.travellers,
    required this.homeCurrency,
    required this.tripCurrency,
    required this.nzdToGbp,
  });

  factory TripInfo.fromJson(Map<String, dynamic> json) => TripInfo(
        name: json['name'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        travellers: json['travellers'] as String,
        homeCurrency: json['homeCurrency'] as String,
        tripCurrency: json['tripCurrency'] as String,
        nzdToGbp: (json['nzdToGbp'] as num).toDouble(),
      );
}

class ItineraryItem {
  final int day;
  final DateTime date;
  final String location;
  final String title;
  final String details;

  ItineraryItem({
    required this.day,
    required this.date,
    required this.location,
    required this.title,
    required this.details,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) => ItineraryItem(
        day: json['day'] as int,
        date: DateTime.parse(json['date'] as String),
        location: json['location'] as String,
        title: json['title'] as String,
        details: json['details'] as String,
      );
}

class AccommodationItem {
  final String location;
  final String property;
  final String dates;
  final String status;

  AccommodationItem({
    required this.location,
    required this.property,
    required this.dates,
    required this.status,
  });

  factory AccommodationItem.fromJson(Map<String, dynamic> json) =>
      AccommodationItem(
        location: json['location'] as String,
        property: json['property'] as String,
        dates: json['dates'] as String,
        status: json['status'] as String,
      );
}

class TransportItem {
  final String title;
  final String provider;
  final String status;
  final double costGbp;

  TransportItem({
    required this.title,
    required this.provider,
    required this.status,
    required this.costGbp,
  });

  factory TransportItem.fromJson(Map<String, dynamic> json) => TransportItem(
        title: json['title'] as String,
        provider: json['provider'] as String,
        status: json['status'] as String,
        costGbp: (json['costGbp'] as num).toDouble(),
      );
}

class BudgetItem {
  final String category;
  final double budgetGbp;
  final double committedGbp;

  BudgetItem({
    required this.category,
    required this.budgetGbp,
    required this.committedGbp,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem(
        category: json['category'] as String,
        budgetGbp: (json['budgetGbp'] as num).toDouble(),
        committedGbp: (json['committedGbp'] as num).toDouble(),
      );
}

class WishlistItem {
  final String title;
  final String location;
  final String priority;

  WishlistItem({
    required this.title,
    required this.location,
    required this.priority,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        title: json['title'] as String,
        location: json['location'] as String,
        priority: json['priority'] as String,
      );
}
