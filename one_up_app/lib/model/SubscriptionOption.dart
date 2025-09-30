
class SubscriptionOption {
  final String title;
  final String description;
  final bool isPaid;
  final double? price;
  bool isSelected;

  SubscriptionOption({
    required this.title,
    required this.description,
    required this.isPaid,
    this.price,
    this.isSelected = false,
  });

  static List<SubscriptionOption> subscriptionOptions = [
    SubscriptionOption(
      title: "Paid Subscription",
      description: "Register in any event without extra fees.",
      isPaid: true,
      price: 100,
    ),
    SubscriptionOption(
      title: "Free Subscription",
      description: "You must pay event registration fees per event.",
      isPaid: false,
    ),
  ];

}
