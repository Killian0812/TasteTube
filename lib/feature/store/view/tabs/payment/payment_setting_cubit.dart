import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/store/data/payment_card.dart';
import 'package:taste_tube/feature/store/domain/payment_setting_repo.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/utils/user_data.util.dart';

abstract class PaymentSettingState {
  final String selectedCurrency;
  final List<PaymentCard> cards;

  const PaymentSettingState(
    this.selectedCurrency,
    this.cards,
  );
}

class PaymentSettingLoading extends PaymentSettingState {
  PaymentSettingLoading() : super('', []);
}

class PaymentSettingLoaded extends PaymentSettingState {
  const PaymentSettingLoaded(super.selectedCurrency, super.cards);
}

class PaymentSettingSuccess extends PaymentSettingState {
  const PaymentSettingSuccess(super.selectedCurrency, super.cards);
}

class PaymentSettingError extends PaymentSettingState {
  final String message;

  const PaymentSettingError(super.selectedCurrency, super.cards, this.message);
}

class PaymentSettingCubit extends Cubit<PaymentSettingState> {
  final PaymentSettingRepository repository = getIt<PaymentSettingRepository>();

  PaymentSettingCubit() : super(PaymentSettingLoading());

  Future<void> fetchCards() async {
    final result = await repository.getCards();
    result.match(
      (error) => emit(PaymentSettingError(
        state.selectedCurrency,
        state.cards,
        error.message ?? "Error fetching cards",
      )),
      (cards) => emit(PaymentSettingLoaded(UserDataUtil.getCurrency(), cards)),
    );
  }

  Future<void> updateCurrency(String newCurrency) async {
    final result = await repository.changeCurrency(newCurrency);
    result.match(
        (error) => emit(PaymentSettingError(
              state.selectedCurrency,
              state.cards,
              error.message ?? "Error updating currency",
            )), (currency) {
      getIt<AuthBloc>().add(UpdateCurrencyEvent(currency));
      emit(PaymentSettingLoaded(currency, state.cards));
    });
  }

  Future<void> addCard({
    required String type,
    required String expiryDate,
    required String cardNumber,
    required String holderName,
  }) async {
    final result = await repository.addCard(
      type: type,
      expiryDate: expiryDate,
      cardNumber: cardNumber,
      holderName: holderName,
    );
    result.match(
        (error) => emit(PaymentSettingError(
              state.selectedCurrency,
              state.cards,
              error.message ?? "Error adding new card",
            )),
        (newCard) => emit(PaymentSettingSuccess(
            state.selectedCurrency, [...state.cards, newCard])));
  }

  Future<void> setDefaultCard(String cardId) async {
    final result = await repository.setDefaultCard(cardId);
    result.match(
      (error) => emit(PaymentSettingError(
        state.selectedCurrency,
        state.cards,
        error.message ?? "Error setting card as default",
      )),
      (updatedCard) => fetchCards(),
    );
  }

  Future<void> removeCard(String cardId) async {
    final result = await repository.removeCard(cardId);
    result.match(
      (error) => emit(PaymentSettingError(
        state.selectedCurrency,
        state.cards,
        error.message ?? "Error removing card",
      )),
      (_) => emit(PaymentSettingLoaded(
        state.selectedCurrency,
        state.cards.where((c) => c.id != cardId).toList(),
      )),
    );
  }
}
