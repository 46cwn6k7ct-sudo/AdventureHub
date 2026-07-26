class Trip {
  const Trip({
    required this.name,
    required this.subtitle,
    required this.startDate,
    required this.endDate,
    required this.currency,
    required this.itinerary,
    required this.bookings,
    required this.budget,
    required this.packing,
    required this.wishlist,
  });

  final String name;
  final String subtitle;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final List<ItineraryDay> itinerary;
  final List<Booking> bookings;
  final List<BudgetItem> budget;
  final List<PackingGroup> packing;
  final List<WishlistItem> wishlist;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        name: json['name'] as String,
        subtitle: json['subtitle'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        currency: json['currency'] as String? ?? 'GBP',
        itinerary: (json['itinerary'] as List<dynamic>)
            .map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        bookings: (json['bookings'] as List<dynamic>)
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList(),
        budget: (json['budget'] as List<dynamic>)
            .map((e) => BudgetItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        packing: (json['packing'] as List<dynamic>)
            .map((e) => PackingGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
        wishlist: (json['wishlist'] as List<dynamic>)
            .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ItineraryDay {
  const ItineraryDay({
    required this.date,
    required this.city,
    required this.title,
    required this.isTravelDay,
    required this.activities,
  });
  final DateTime date;
  final String city;
  final String title;
  final bool isTravelDay;
  final List<Activity> activities;
  factory ItineraryDay.fromJson(Map<String, dynamic> json) => ItineraryDay(
        date: DateTime.parse(json['date'] as String),
        city: json['city'] as String,
        title: json['title'] as String,
        isTravelDay: json['isTravelDay'] as bool? ?? false,
        activities: (json['activities'] as List<dynamic>)
            .map((e) => Activity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Activity {
  const Activity({required this.time, required this.name, required this.note});
  final String time;
  final String name;
  final String note;
  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        time: json['time'] as String? ?? '',
        name: json['name'] as String,
        note: json['note'] as String? ?? '',
      );
}

class Booking {
  const Booking({
    required this.type,
    required this.name,
    required this.date,
    required this.status,
    required this.note,
  });
  final String type;
  final String name;
  final DateTime date;
  final String status;
  final String note;
  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        type: json['type'] as String,
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String),
        status: json['status'] as String,
        note: json['note'] as String? ?? '',
      );
}

class BudgetItem {
  const BudgetItem({
    required this.category,
    required this.planned,
    required this.actual,
  });
  final String category;
  final double planned;
  final double actual;
  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem(
        category: json['category'] as String,
        planned: (json['planned'] as num).toDouble(),
        actual: (json['actual'] as num).toDouble(),
      );
}

class PackingGroup {
  const PackingGroup({required this.name, required this.items});
  final String name;
  final List<String> items;
  factory PackingGroup.fromJson(Map<String, dynamic> json) => PackingGroup(
        name: json['name'] as String,
        items: List<String>.from(json['items'] as List<dynamic>),
      );
}

class WishlistItem {
  const WishlistItem({
    required this.name,
    required this.city,
    required this.priority,
    required this.status,
    required this.note,
  });
  final String name;
  final String city;
  final String priority;
  final String status;
  final String note;
  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        name: json['name'] as String,
        city: json['city'] as String,
        priority: json['priority'] as String,
        status: json['status'] as String,
        note: json['note'] as String? ?? '',
      );
}
