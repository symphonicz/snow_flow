import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/core/format/money_format.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/add_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/delete_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/get_default_currency.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/update_entry.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

part 'entry_form_state.dart';

/// The entry form (brief §4.1): a new entry, or [entry] to edit or delete.
class EntryFormCubit extends Cubit<EntryFormState> {
  EntryFormCubit(
    this._addEntry,
    this._updateEntry,
    this._deleteEntry,
    this._getDefaultCurrency, {
    Entry? entry,
    required LocalDate Function() today,
    required int Function() now,
    String Function() newId = Entry.newId,
  }) : _now = now,
       _newId = newId,
       super(_initial(entry, today()));

  final AddEntry _addEntry;
  final UpdateEntry _updateEntry;
  final DeleteEntry _deleteEntry;
  final GetDefaultCurrency _getDefaultCurrency;
  final int Function() _now;
  final String Function() _newId;

  static EntryFormState _initial(Entry? entry, LocalDate today) {
    if (entry != null) {
      return EntryFormState(
        original: entry,
        type: entry.type,
        amountText: _shownAmount(entry),
        currency: entry.currency,
        category: entry.category,
        date: entry.date,
        note: entry.note,
        today: today,
      );
    }
    const type = EntryType.expense;
    return EntryFormState(
      original: null,
      type: type,
      amountText: '',
      currency: null,
      category: Categories.forType(type).first,
      date: today,
      note: '',
      today: today,
    );
  }

  /// [entry]'s amount as the list shows it: JPY, KRW, VND and LAK round to
  /// whole (#12).
  static String _shownAmount(Entry entry) =>
      moneyParts(entry.amount, entry.currency).number;

  /// Reads the currency a new entry starts in.
  Future<void> start() async {
    if (state.currency != null) return;
    final currency = (await _getDefaultCurrency()).getOrElse(
      // Unreadable entries or settings: the default of the settings.
      (_) => const AppSettings().currency,
    );
    if (isClosed || state.currency != null) return;
    emit(state.copyWith(currency: currency));
  }

  /// Keeps the category when it fits [type] (`other` fits both), otherwise
  /// picks the first one of [type] (#54).
  void setType(EntryType type) => emit(
    state.copyWith(
      type: type,
      category: state.category.allows(type)
          ? state.category
          : Categories.forType(type).first,
    ),
  );

  void setAmount(String text) =>
      emit(state.copyWith(amountText: text, showAmountError: false));

  /// A currency without decimals cuts off the ones typed (#12).
  void setCurrency(Currency currency) {
    final text = state.amountText;
    final dot = text.indexOf('.');
    emit(
      state.copyWith(
        currency: currency,
        amountText: currency.fractionDigits == 0 && dot >= 0
            ? text.substring(0, dot)
            : text,
      ),
    );
  }

  void setCategory(EntryCategory category) =>
      emit(state.copyWith(category: category));

  void setDate(LocalDate date) => emit(state.copyWith(date: date));

  void setNote(String note) => emit(state.copyWith(note: note));

  /// Adds the entry, or saves the changes to the one being edited, which
  /// keeps its id and `created`. An amount that is not above 0 only shows
  /// the message (brief §4.1).
  Future<void> save() async {
    final currency = state.currency;
    if (state.status == EntryFormStatus.busy || currency == null) return;
    final original = state.original;
    final Money amount;
    if (original != null &&
        currency == original.currency &&
        state.amountText == _shownAmount(original)) {
      // Untouched: an imported ¥500.50 shows as ¥500 but stays exact (#12).
      amount = original.amount;
    } else {
      switch (Money.parse(state.amountText.replaceAll(',', ''))) {
        case Right(:final value):
          amount = value;
        case Left():
          emit(state.copyWith(showAmountError: true));
          return;
      }
    }
    final entry = Entry(
      id: original?.id ?? _newId(),
      type: state.type,
      amount: amount,
      currency: currency,
      category: state.category,
      date: state.date,
      // The model keeps notes as given; trimming is the form's job (#54).
      note: state.note.trim(),
      created: original?.created ?? _now(),
    );
    emit(state.copyWith(status: EntryFormStatus.busy));
    final result = original == null
        ? await _addEntry(entry)
        : await _updateEntry(entry);
    if (isClosed) return;
    emit(
      state.copyWith(
        status: switch (result) {
          Right() => EntryFormStatus.saved,
          Left(value: EntryNotFound()) => EntryFormStatus.gone,
          Left() => EntryFormStatus.saveFailed,
        },
      ),
    );
  }

  /// Deletes the entry being edited.
  Future<void> delete() async {
    final original = state.original;
    if (state.status == EntryFormStatus.busy || original == null) return;
    emit(state.copyWith(status: EntryFormStatus.busy));
    final result = await _deleteEntry(original.id);
    if (isClosed) return;
    emit(
      state.copyWith(
        status: result.isRight()
            ? EntryFormStatus.deleted
            : EntryFormStatus.deleteFailed,
      ),
    );
  }
}
