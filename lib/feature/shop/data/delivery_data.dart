class DeliveryQuote {
  final double amount;
  final Map<String, DateTime>? estimatedTimeline;

  DeliveryQuote({
    required this.amount,
    this.estimatedTimeline,
  });

  factory DeliveryQuote.fromJson(Map<String, dynamic> json) {
    final timeline = json['estimatedTimeline'] as Map<String, dynamic>?;
    return DeliveryQuote(
      amount: (json['amount'] as num).toDouble(),
      estimatedTimeline: timeline != null
          ? {
              'pickup': DateTime.parse(timeline['pickup']),
              'dropoff': DateTime.parse(timeline['dropoff']),
              'completed': DateTime.parse(timeline['completed']),
            }
          : null,
    );
  }
}

enum DeliveryType { NONE, SELF, GRAB }

enum DeliveryStatus {
  ALLOCATING,
  PENDING_PICKUP,
  PICKING_UP,
  PENDING_DROP_OFF,
  IN_DELIVERY,
  COMPLETED,
  IN_RETURN,
  RETURNED,
  CANCELED,
  FAILED,
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    return name.split('_').join(' ');
  }

  String get value {
    return name;
  }

  bool get isFinalStatus {
    switch (this) {
      case DeliveryStatus.COMPLETED:
      case DeliveryStatus.RETURNED:
      case DeliveryStatus.CANCELED:
      case DeliveryStatus.FAILED:
        return true;
      default:
        return false;
    }
  }

  DeliveryStatus? get nextStatus {
    if (isFinalStatus) return null;
    switch (this) {
      case DeliveryStatus.ALLOCATING:
        return DeliveryStatus.PENDING_PICKUP;
      case DeliveryStatus.PENDING_PICKUP:
        return DeliveryStatus.PICKING_UP;
      case DeliveryStatus.PICKING_UP:
        return DeliveryStatus.PENDING_DROP_OFF;
      case DeliveryStatus.PENDING_DROP_OFF:
        return DeliveryStatus.IN_DELIVERY;
      case DeliveryStatus.IN_DELIVERY:
        return DeliveryStatus.COMPLETED;
      default:
        return null;
    }
  }
}

class DeliveryStatusLog {
  final DeliveryStatus deliveryStatus;
  final DateTime deliveryTimestamp;

  DeliveryStatusLog({
    required this.deliveryStatus,
    required this.deliveryTimestamp,
  });

  factory DeliveryStatusLog.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusLog(
      deliveryStatus: DeliveryStatus.values.firstWhere(
        (e) => e.name == json['deliveryStatus'],
        orElse: () => throw ArgumentError('Invalid deliveryStatus value'),
      ),
      deliveryTimestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['deliveryTimestamp'] as num).toInt(),
      ),
    );
  }
}

class OrderDelivery {
  final DeliveryType deliveryType;
  final List<DeliveryStatusLog> statusLogs;
  final String origin;
  final String destination;

  OrderDelivery({
    required this.deliveryType,
    required this.statusLogs,
    required this.origin,
    required this.destination,
  });

  factory OrderDelivery.fromJson(Map<String, dynamic> json) {
    return OrderDelivery(
      deliveryType: DeliveryType.values.firstWhere(
        (e) => e.name == json['deliveryType'],
        orElse: () => throw ArgumentError('Invalid deliveryType value'),
      ),
      statusLogs: (json['deliveryStatusLog'] as List<dynamic>)
          .map((log) => DeliveryStatusLog.fromJson(log as Map<String, dynamic>))
          .toList(),
      origin: json['origin'] as String,
      destination: json['destination'] as String,
    );
  }
}
