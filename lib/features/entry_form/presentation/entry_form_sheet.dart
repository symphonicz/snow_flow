import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:snow_flow/core/format/date_format.dart';
import 'package:snow_flow/core/format/money_format.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/l10n/buddhist_material_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/features/entry_form/presentation/amount_input_formatter.dart';
import 'package:snow_flow/features/entry_form/presentation/entry_form_cubit.dart';
import 'package:snow_flow/features/entry_form/presentation/widgets/brand_ring.dart';
import 'package:snow_flow/features/entry_form/presentation/widgets/category_picker.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:snow_flow/shared/presentation/category_name.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';
import 'package:snow_flow/features/entry_form/presentation/widgets/segmented.dart';
import 'package:snow_flow/shared/presentation/toast/toast.dart';

/// Opens the entry form over the current page: a new entry, or [entry] to
/// edit (brief §4.1). It has no route of its own, so back closes it and the
/// page under it stays (#18 Q7, #59 Q1).
Future<void> showEntryForm(BuildContext context, {Entry? entry}) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => BlocProvider(
        create: (_) => GetIt.instance<EntryFormCubit>(param1: entry)..start(),
        child: const EntryFormSheet(),
      ),
    );

/// The mobile entry form (brief §7): a title with Delete when editing, the
/// fields scrolling, and Save always above the keyboard (#61 Q3). Reads an
/// [EntryFormCubit] from above.
class EntryFormSheet extends StatelessWidget {
  const EntryFormSheet({super.key});

  static const amountKey = ValueKey('entryForm.amount');
  static const dateKey = ValueKey('entryForm.date');
  static const noteKey = ValueKey('entryForm.note');

  /// Closes on success and says so; a failure keeps what was typed (#61 Q4).
  void _onStatus(BuildContext context, EntryFormState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EntryFormCubit>();
    void close(String message, ToastKind kind) {
      showToast(context, message, kind: kind);
      Navigator.of(context).pop();
    }

    switch (state.status) {
      case EntryFormStatus.saved:
        close(l10n.entryFormSaved, ToastKind.success);
      case EntryFormStatus.deleted:
        close(l10n.entryFormDeleted, ToastKind.success);
      case EntryFormStatus.gone:
        close(l10n.entryFormGone, ToastKind.error);
      case EntryFormStatus.saveFailed:
        showToast(
          context,
          l10n.entryFormSaveFailed,
          kind: ToastKind.error,
          onRetry: cubit.save,
        );
      case EntryFormStatus.deleteFailed:
        showToast(
          context,
          l10n.entryFormDeleteFailed,
          kind: ToastKind.error,
          onRetry: cubit.delete,
        );
      case EntryFormStatus.editing || EntryFormStatus.busy:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EntryFormCubit, EntryFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatus,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.s12,
                  AppSpacing.screenEdge,
                  AppSpacing.s8,
                ),
                child: _Fields(),
              ),
            ),
            _SaveButton(),
          ],
        ),
      ),
    );
  }
}

/// "จดรายการ" / "แก้ไขรายการ", and Delete when editing (#61 Q3).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final state = context.watch<EntryFormCubit>().state;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.screenEdge,
        end: AppSpacing.s8,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.isEditing ? l10n.entryFormEditTitle : l10n.commonAddEntry,
                style: AppText.sectionTitle.copyWith(color: colors.ink),
              ),
            ),
            if (state.isEditing)
              TextButton(
                onPressed: state.status == EntryFormStatus.busy
                    ? null
                    : () => _confirmDelete(context),
                style: TextButton.styleFrom(
                  foregroundColor: colors.expense,
                  minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
                ),
                child: Text(l10n.commonDelete),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<EntryFormCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(entry: cubit.state.original!),
    );
    if (confirmed ?? false) await cubit.delete();
  }
}

/// Names the entry as saved, not as being edited (#61 Q5). Delete sits at
/// the bottom right, away from the Delete that opened it.
class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final locale = Localizations.localeOf(context);
    final income = entry.type == EntryType.income;
    final amount = formatMoney(
      income ? entry.amount : const Money(0) - entry.amount,
      entry.currency,
      signed: true,
    );
    return AlertDialog(
      title: Text(
        l10n.entryFormDeleteTitle,
        style: AppText.sectionTitle.copyWith(color: colors.ink),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s8,
        children: [
          Text(
            '${categoryName(l10n, entry.category)} $amount · '
            '${formatDate(entry.date, locale)}',
            style: AppText.body.copyWith(color: colors.ink),
          ),
          Text(
            l10n.entryFormDeleteBody,
            style: AppText.body.copyWith(color: colors.ink2),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colors.expense,
            foregroundColor: colors.onBrand,
          ),
          child: Text(l10n.commonDelete),
        ),
      ],
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EntryFormCubit>();
    final state = context.watch<EntryFormCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s16,
      children: [
        Segmented<EntryType>(
          segments: [
            (EntryType.expense, l10n.commonExpense),
            (EntryType.income, l10n.commonIncome),
          ],
          selected: state.type,
          onChanged: cubit.setType,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s4,
          children: [
            // The amount, then its currency on the same line (#61).
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s12,
              children: [
                Expanded(
                  child: _Labeled(
                    label: l10n.entryFormAmount,
                    child: const _AmountField(),
                  ),
                ),
                IntrinsicWidth(
                  child: _Labeled(
                    label: l10n.entryFormCurrency,
                    child: _CurrencyField(
                      currency: state.currency,
                      onChanged: cubit.setCurrency,
                    ),
                  ),
                ),
              ],
            ),
            if (state.showAmountError)
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.entryFormAmountError,
                  style: AppText.caption.copyWith(
                    color: AppColors.of(context).expense,
                  ),
                ),
              ),
          ],
        ),
        _Labeled(
          label: l10n.entryFormCategory,
          child: CategoryPicker(
            categories: Categories.forType(state.type),
            selected: state.category,
            onSelected: cubit.setCategory,
          ),
        ),
        // Date and note on their own lines on mobile (brief §7).
        _Labeled(
          label: l10n.entryFormDate,
          child: _DateField(
            date: state.date,
            today: state.today,
            onPicked: cubit.setDate,
          ),
        ),
        _Labeled(
          label: l10n.entryFormNote,
          child: _NoteField(note: state.note, onChanged: cubit.setNote),
        ),
      ],
    );
  }
}

/// Every field has a label (brief §8), above it in bold (#61).
class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s8,
      children: [
        Text(
          label,
          style: AppText.labelBold.copyWith(color: AppColors.of(context).ink2),
        ),
        child,
      ],
    );
  }
}

/// 68 high inside the brand ring, the currency symbol always in front, and
/// a 34 bold number that shrinks rather than overflow (brief §8, #37, #61).
/// Focused as soon as the form opens, with the decimal keypad (brief §4.1).
class _AmountField extends StatefulWidget {
  const _AmountField();

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  late final _controller = TextEditingController(
    text: context.read<EntryFormCubit>().state.amountText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cubit = context.read<EntryFormCubit>();
    final currency = context.select<EntryFormCubit, Currency?>(
      (cubit) => cubit.state.currency,
    );
    final symbol = currency == null ? '' : currencySymbol(currency);
    return BlocListener<EntryFormCubit, EntryFormState>(
      // A currency without decimals cuts them off in the Cubit (#12).
      listenWhen: (_, current) => current.amountText != _controller.text,
      listener: (_, state) => _controller.value = TextEditingValue(
        text: state.amountText,
        selection: TextSelection.collapsed(offset: state.amountText.length),
      ),
      child: BrandRing(
        radius: AppRadius.md,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.amountField),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: LayoutBuilder(
            builder: (context, constraints) => ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) {
                final style = _fitted(
                  context,
                  '$symbol${value.text.isEmpty ? '0' : value.text}',
                  constraints.maxWidth - AppSpacing.s8,
                );
                // Both lines take Quicksand's height and baseline. Without
                // it "฿", which only Noto Sans Thai has, brings that font's
                // much deeper line and sits higher than the digits (#61).
                final strut = StrutStyle.fromTextStyle(
                  style,
                  forceStrutHeight: true,
                );
                // Not the field's prefix, which hides while it is empty and
                // unfocused.
                return Row(
                  spacing: AppSpacing.s8,
                  children: [
                    Text(
                      symbol,
                      style: style.copyWith(color: colors.ink3),
                      strutStyle: strut,
                    ),
                    Expanded(
                      child: TextField(
                        key: EntryFormSheet.amountKey,
                        controller: _controller,
                        strutStyle: strut,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          AmountInputFormatter(currency ?? Currency.thb),
                        ],
                        onChanged: cubit.setAmount,
                        style: style.copyWith(color: colors.ink),
                        cursorColor: colors.brand,
                        decoration: InputDecoration(
                          filled: false,
                          isCollapsed: true,
                          hintText: '0',
                          hintStyle: style.copyWith(color: colors.ink3),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// [AppText.amountInput], made smaller when [text] is wider than
  /// [maxWidth], so every digit stays visible (#37).
  TextStyle _fitted(BuildContext context, String text, double maxWidth) {
    final full = AppText.amountInput;
    final painter = TextPainter(
      text: TextSpan(text: text, style: full),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width + AppSizes.cursorRoom;
    painter.dispose();
    if (width <= maxWidth) return full;
    final size = full.fontSize! * maxWidth / width;
    return full.copyWith(
      fontSize: size < AppText.amountInputMinSize
          ? AppText.amountInputMinSize
          : size,
    );
  }
}

/// The 14 currencies of brief §4.5 by code in bold, the symbol being in the
/// amount field (#61); as high as the amount field with its ring, and
/// opening the app's own chevron (brief §8).
class _CurrencyField extends StatelessWidget {
  const _CurrencyField({required this.currency, required this.onChanged});

  final Currency? currency;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return _FieldBox(
      minHeight: AppSizes.amountField + 2 * AppSizes.selectedRing,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: currency,
          onChanged: (currency) {
            if (currency != null) onChanged(currency);
          },
          icon: LineIcon(
            AppIcons.chevronDown,
            size: AppSizes.iconSmall,
            color: colors.ink2,
          ),
          style: AppText.bodyBold.copyWith(color: colors.ink),
          dropdownColor: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          items: [
            for (final currency in Currency.values)
              DropdownMenuItem(value: currency, child: Text(currency.code)),
          ],
        ),
      ),
    );
  }
}

/// Today or before; an imported future day stays until changed, but the
/// picker opens on today (#17, #61 Q2).
class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.today,
    required this.onPicked,
  });

  final LocalDate date;

  /// The last day that may be picked (brief §4.1).
  final LocalDate today;
  final ValueChanged<LocalDate> onPicked;

  Future<void> _pick(BuildContext context) async {
    DateTime dateTime(LocalDate date) =>
        DateTime(date.year, date.month, date.day);
    final last = dateTime(today);
    final initial = date > today ? last : dateTime(date);
    final earliest = DateTime(1900);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.isBefore(earliest) ? initial : earliest,
      lastDate: last,
      // Typing a date would read and show Common Era years.
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) => withBuddhistYears(context, child!),
    );
    if (picked != null) onPicked(LocalDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return _FieldBox(
      key: EntryFormSheet.dateKey,
      onTap: () => _pick(context),
      child: Row(
        spacing: AppSpacing.s8,
        children: [
          Expanded(
            child: Text(
              formatDate(date, Localizations.localeOf(context)),
              style: AppText.body.copyWith(color: colors.ink),
            ),
          ),
          LineIcon(
            AppIcons.calendar,
            size: AppSizes.iconSmall,
            color: colors.ink2,
          ),
        ],
      ),
    );
  }
}

/// At most 100 characters as people see them (#17); trimmed on save.
class _NoteField extends StatefulWidget {
  const _NoteField({required this.note, required this.onChanged});

  final String note;
  final ValueChanged<String> onChanged;

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final _controller = TextEditingController(text: widget.note);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: TextField(
        key: EntryFormSheet.noteKey,
        controller: _controller,
        onChanged: widget.onChanged,
        // Flutter counts grapheme clusters, as Entry.noteFits does.
        maxLength: Entry.maxNoteLength,
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        minLines: 1,
        maxLines: 3,
        textInputAction: TextInputAction.done,
        style: AppText.body.copyWith(color: colors.ink),
        cursorColor: colors.brand,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).entryFormNoteHint,
          hintStyle: AppText.body.copyWith(color: colors.ink3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
        ),
      ),
    );
  }
}

/// A surface-2 field without a border, 48 high, corners md (brief §8).
/// With [onTap] the whole box is the touch target.
class _FieldBox extends StatelessWidget {
  const _FieldBox({
    super.key,
    required this.child,
    this.onTap,
    this.minHeight = AppSizes.field,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final box = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.s16,
          end: AppSpacing.s12,
        ),
        child: Align(alignment: AlignmentDirectional.centerStart, child: child),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Material(
        color: AppColors.of(context).surface2,
        child: onTap == null ? box : InkWell(onTap: onTap, child: box),
      ),
    );
  }
}

/// Full width in brand, below the fields and above the keyboard (#61 Q3).
/// Off while saving, so a double tap adds nothing twice.
class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EntryFormCubit>();
    final state = context.watch<EntryFormCubit>().state;
    final ready =
        state.status != EntryFormStatus.busy && state.currency != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          AppSpacing.s8,
          AppSpacing.screenEdge,
          AppSpacing.s16,
        ),
        child: FilledButton(
          onPressed: ready ? cubit.save : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.button),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: Text(AppLocalizations.of(context).commonSave),
        ),
      ),
    );
  }
}
