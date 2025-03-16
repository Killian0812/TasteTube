import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentOption {
  final String id;
  final String type;
  final String lastFour;
  final String holderName;
  final String expiryDate;
  final bool isDefault;

  PaymentOption({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.holderName,
    required this.expiryDate,
    this.isDefault = false,
  });
}

class PaymentSettingState {
  final String selectedCurrency;
  final List<PaymentOption> cards;
  final bool isLoading;

  PaymentSettingState({
    required this.selectedCurrency,
    required this.cards,
    this.isLoading = false,
  });

  PaymentSettingState copyWith({
    String? selectedCurrency,
    List<PaymentOption>? cards,
    bool? isLoading,
  }) {
    return PaymentSettingState(
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PaymentSettingCubit extends Cubit<PaymentSettingState> {
  PaymentSettingCubit()
      : super(PaymentSettingState(
          selectedCurrency: 'USD',
          cards: [],
        ));

  void loadInitialData() {
    emit(state.copyWith(isLoading: true));
    // Simulate API call
    final initialCards = [
      PaymentOption(
        id: '1',
        type: 'Visa',
        lastFour: '4242',
        holderName: 'John Doe',
        expiryDate: '12/27', // Added expiryDate
        isDefault: true,
      ),
    ];
    emit(state.copyWith(cards: initialCards, isLoading: false));
  }

  void updateCurrency(String newCurrency) {
    emit(state.copyWith(selectedCurrency: newCurrency));
  }

  void addCard(PaymentOption card) {
    emit(state.copyWith(cards: [...state.cards, card]));
  }

  void setDefaultCard(String cardId) {
    final updatedCards = state.cards.map((card) {
      return PaymentOption(
        id: card.id,
        type: card.type,
        lastFour: card.lastFour,
        holderName: card.holderName,
        expiryDate: card.expiryDate,
        isDefault: card.id == cardId,
      );
    }).toList();
    emit(state.copyWith(cards: updatedCards));
  }

  void removeCard(String cardId) {
    final updatedCards =
        state.cards.where((card) => card.id != cardId).toList();
    emit(state.copyWith(cards: updatedCards));
  }
}
