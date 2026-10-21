import '../../core/riverpod.dart';
import '../models/order.dart';
import 'seed_data.dart';

class OrderRepository extends StateNotifier<List<OrderModel>> {
  OrderRepository()
      : super([
          OrderModel(
            id: 'ORD-77492',
            userId: 'member_demo_001',
            items: [
              OrderItem(
                product: seedProducts[6], // Royal Sapphire Earrings
                quantity: 1,
                priceUsd: seedProducts[6].priceUsd,
              ),
            ],
            customerName: 'Archduchess Gisela',
            customerEmail: 'gisela.habsburg@vienna.at',
            customerPhone: '+43 1 533 1884',
            address: 'Palais Maximilian, Koeniginstrasse 14',
            city: 'Munich',
            country: 'Germany',
            postalCode: '80539',
            shippingMethod: 'White-Glove Art Courier & Armored Escort',
            subtotalUsd: seedProducts[6].priceUsd,
            shippingCostUsd: 150.0,
            totalUsd: seedProducts[6].priceUsd + 150.0,
            status: OrderStatus.packed,
            paymentStatus: OrderPaymentStatus.paid,
            razorpayPaymentId: 'pay_MunichArchive884',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            trackingNumber: 'ORIGIN-SECURE-99421',
          ),
        ]);

  OrderModel createOrder({
    required String userId,
    required List<OrderItem> items,
    required String address,
    required String city,
    required String country,
    required String postalCode,
    required String shippingMethod,
    required double subtotalUsd,
    required double shippingCostUsd,
    String? id,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    OrderPaymentStatus paymentStatus = OrderPaymentStatus.pending,
  }) {
    final orderId = id ?? 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final order = OrderModel(
      id: orderId,
      userId: userId,
      items: List.of(items),
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      address: address,
      city: city,
      country: country,
      postalCode: postalCode,
      shippingMethod: shippingMethod,
      subtotalUsd: subtotalUsd,
      shippingCostUsd: shippingCostUsd,
      totalUsd: subtotalUsd + shippingCostUsd,
      status: paymentStatus == OrderPaymentStatus.paid ? OrderStatus.packed : OrderStatus.placed,
      paymentStatus: paymentStatus,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      createdAt: DateTime.now(),
      trackingNumber: 'ORIGIN-VAULT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );

    state = [order, ...state.where((o) => o.id != orderId)];
    return order;
  }

  void saveOrder(OrderModel order) {
    state = [
      order,
      ...state.where((o) => o.id != order.id),
    ];
  }

  void updatePaymentStatus(
    String orderId,
    OrderPaymentStatus paymentStatus, {
    String? paymentId,
    String? razorpayOrderId,
  }) {
    state = [
      for (final o in state)
        if (o.id == orderId)
          o.copyWith(
            paymentStatus: paymentStatus,
            razorpayPaymentId: paymentId ?? o.razorpayPaymentId,
            razorpayOrderId: razorpayOrderId ?? o.razorpayOrderId,
            status: paymentStatus == OrderPaymentStatus.paid ? OrderStatus.packed : o.status,
          )
        else
          o,
    ];
  }

  void updateStatus(String orderId, OrderStatus status) {
    state = [
      for (final o in state)
        if (o.id == orderId) o.copyWith(status: status) else o,
    ];
  }

  List<OrderModel> getOrdersForUser(String userId) {
    return state.where((o) => o.userId == userId).toList();
  }
}

final orderRepositoryProvider =
    StateNotifierProvider<OrderRepository, List<OrderModel>>((ref) {
  return OrderRepository();
});
