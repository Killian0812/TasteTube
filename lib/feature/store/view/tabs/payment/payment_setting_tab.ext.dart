part of 'payment_setting_tab.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  static Widget provider(PaymentSettingCubit cubit) {
    return BlocProvider.value(
      value: cubit,
      child: AddCardPage(),
    );
  }

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  CardType? selectedCardType = CardType.visa;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final List<CardType> cardTypes = [
    CardType.visa,
    CardType.mastercard,
    CardType.americanExpress,
    CardType.discover,
    CardType.unionpay,
  ];

  final Map<CardType, String> cardTypeNames = {
    CardType.visa: 'Visa',
    CardType.mastercard: 'Mastercard',
    CardType.americanExpress: 'American Express',
    CardType.discover: 'Discover',
    CardType.unionpay: 'UnionPay',
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentSettingCubit, PaymentSettingState>(
      listener: (context, state) {
        if (state is PaymentSettingSuccess) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Card'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CreditCardWidget(
                enableFloatingCard: true,
                glassmorphismConfig:
                    getIt<AppSettings>().getTheme == ThemeMode.light
                        ? null
                        : Glassmorphism.defaultConfig(),
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (CreditCardBrand brand) {},
                isHolderNameVisible: true,
                cardType: selectedCardType,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButton<CardType>(
                      value: selectedCardType,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      hint: const Text('Select Card Type'),
                      items: cardTypes.map((CardType type) {
                        return DropdownMenuItem<CardType>(
                          value: type,
                          child: Text(cardTypeNames[type] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (CardType? newValue) {
                        setState(() {
                          selectedCardType = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: false,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                      onCreditCardModelChange: (CreditCardModel model) {
                        setState(() {
                          cardNumber = model.cardNumber;
                          expiryDate = model.expiryDate;
                          cardHolderName = model.cardHolderName;
                          cvvCode = model.cvvCode;
                          isCvvFocused = model.isCvvFocused;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CommonButton(
                  text: 'Add Card',
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        selectedCardType != null) {
                      context.read<PaymentSettingCubit>().addCard(
                            cardNumber: cardNumber,
                            expiryDate: expiryDate,
                            holderName: cardHolderName,
                            type: cardTypeNames[selectedCardType] ?? 'Card',
                          );
                    } else if (selectedCardType == null) {
                      ToastService.showToast(
                        context,
                        'Please select a card type',
                        ToastType.error,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
