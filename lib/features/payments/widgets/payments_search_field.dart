import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_state.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Free-text search over the visible counterparty and reference fields. The
/// text controller is ephemeral widget state; the bloc owns the searched
/// query. The field's own clear icon drops only the text; clearing every
/// criterion elsewhere empties the field through the bloc's idle state.
class PaymentsSearchField extends StatefulWidget {
  const PaymentsSearchField({super.key});

  @override
  State<PaymentsSearchField> createState() => _PaymentsSearchFieldState();
}

class _PaymentsSearchFieldState extends State<PaymentsSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearText() {
    _controller.clear();
    context.read<PaymentsSearchBloc>().add(
      const PaymentsSearchEvent.queryChanged(''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocListener<PaymentsSearchBloc, PaymentsSearchState>(
      listenWhen: (PaymentsSearchState previous, PaymentsSearchState current) =>
          previous.isActive && !current.isActive,
      listener: (BuildContext context, PaymentsSearchState _) =>
          _controller.clear(),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (BuildContext context, Widget? _) {
          return Semantics(
            identifier: 'payments.search.field',
            textField: true,
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: (String query) => context
                  .read<PaymentsSearchBloc>()
                  .add(PaymentsSearchEvent.queryChanged(query)),
              decoration: InputDecoration(
                hintText: l10n.paymentsSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Semantics(
                  identifier: 'payments.search.clearText',
                  child: IconButton(
                    tooltip: l10n.paymentsSearchClearLabel,
                    onPressed: _controller.text.isEmpty ? null : _clearText,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
