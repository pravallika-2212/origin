import 'product.dart';

enum OrderStatus { placed, packed, shipped, delivered }

enum OrderPaymentStatus { pending, paid, failed, cancelled }

class OrderItem {
  const OrderItem({
    required this.product,
    required this.quantity,
    required this.priceUsd,
  });

  final Product product;
  final int quantity;
  final double priceUsd;

  double get total => priceUsd * quantity;
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.city,
    required this.country,
    required this.postalCode,
    required this.shippingMethod,
    required this.subtotalUsd,
    required this.shippingCostUsd,
    required this.totalUsd,
    required this.status,
    required this.createdAt,
    this.trackingNumber,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.paymentStatus = OrderPaymentStatus.pending,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.taxUsd = 0.0,
  });

  final String id;
  final String userId;
  final List<OrderItem> items;
  final String address;
  final String city;
  final String country;
  final String postalCode;
  final String shippingMethod;
  final double subtotalUsd;
  final double shippingCostUsd;
  final double totalUsd;
  final OrderStatus status;
  final DateTime createdAt;
  final String? trackingNumber;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final OrderPaymentStatus paymentStatus;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final double taxUsd;

  String get statusDisplay {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.packed:
        return 'Vault Packed & Verified';
      case OrderStatus.shipped:
        return 'White-Glove Courier Dispatched';
      case OrderStatus.delivered:
        return 'Safely Delivered';
    }
  }

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case OrderPaymentStatus.paid:
        return 'Settled & Verified';
      case OrderPaymentStatus.pending:
        return 'Settlement Pending';
      case OrderPaymentStatus.failed:
        return 'Settlement Failed';
      case OrderPaymentStatus.cancelled:
        return 'Settlement Cancelled';
    }
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? trackingNumber,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    OrderPaymentStatus? paymentStatus,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    double? taxUsd,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      items: items,
      address: address,
      city: city,
      country: country,
      postalCode: postalCode,
      shippingMethod: shippingMethod,
      subtotalUsd: subtotalUsd,
      shippingCostUsd: shippingCostUsd,
      totalUsd: totalUsd,
      status: status ?? this.status,
      createdAt: createdAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      taxUsd: taxUsd ?? this.taxUsd,
    );
  }
}
