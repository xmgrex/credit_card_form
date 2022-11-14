import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';
import 'components/card_type.dart';
import 'components/card_utils.dart';
import 'components/input_formatters.dart';

class AddNewCardForm extends StatefulWidget {
  const AddNewCardForm({
    Key? key,
    required this.formKey,
    required this.addCard,
    this.scan,
    this.addCardButtonText,
    this.scanCardButtonText,
    this.decoration,
    this.cardNumberHint,
    this.expireDateHint,
    this.cvvHint,
    this.addCardButtonStyle,
    this.scanCardButtonStyle,
    this.padding,
    this.numberFormPrefixIcon,
    this.numberFormSuffixIcon,
    this.cvvFormPrefixIcon,
    this.expiryDateFormPrefixIcon,
    this.buttonColor,
  }) : super(key: key);

  final Function(PaymentCard) addCard;
  final Function()? scan;
  final String? addCardButtonText;
  final String? scanCardButtonText;
  final InputDecoration? decoration;
  final String? cardNumberHint;
  final String? expireDateHint;
  final String? cvvHint;
  final ButtonStyle? addCardButtonStyle;
  final ButtonStyle? scanCardButtonStyle;
  final EdgeInsetsGeometry? padding;
  final Widget? numberFormPrefixIcon;
  final Widget? numberFormSuffixIcon;
  final Widget? cvvFormPrefixIcon;
  final Widget? expiryDateFormPrefixIcon;
  final GlobalKey<FormState> formKey;
  final Color? buttonColor;

  @override
  State<AddNewCardForm> createState() => _AddNewCardFormState();
}

class _AddNewCardFormState extends State<AddNewCardForm> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();

  late PaymentCard _paymentCard;

  @override
  void initState() {
    _paymentCard = PaymentCard();
    cardNumberController.addListener(
      () {
        _getCardTypeFromNumber();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    cvvController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }

  void _getCardTypeFromNumber() {
    if (cardNumberController.text.length <= 6) {
      String input = CardUtils.getCleanedNumber(cardNumberController.text);
      CardType cardType = CardUtils.getCardTypeFromNumber(input);
      if (cardType != _paymentCard.type) {
        _paymentCard.type = cardType;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          const Spacer(),
          Form(
            key: widget.formKey,
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  onSaved: (cardNum) {
                    _paymentCard.number = CardUtils.getCleanedNumber(cardNum!);
                  },
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  validator: CardUtils.validateCardNum,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    CardNumberInputFormatter(),
                  ],
                  decoration: widget.decoration ??
                      InputDecoration(
                        prefixIcon: widget.numberFormPrefixIcon ??
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: SvgPicture.asset("assets/icons/card.svg"),
                            ),
                        suffixIcon: widget.numberFormSuffixIcon ??
                            SizedBox(
                              width: 40,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                child: (_paymentCard.type != null)
                                    ? CardUtils.getCardIcon(_paymentCard.type)
                                    : null,
                              ),
                            ),
                        hintText: widget.cardNumberHint ?? "カード番号",
                      ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: expiryDateController,
                        onSaved: (value) {
                          List<int> expireDate =
                              CardUtils.getExpiryDate(value!);
                          _paymentCard.month = expireDate.first;
                          _paymentCard.year = expireDate[1];
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          CardMonthInputFormatter(),
                        ],
                        validator: CardUtils.validateDate,
                        decoration: widget.decoration ??
                            InputDecoration(
                              prefixIcon: widget.expiryDateFormPrefixIcon ??
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: SvgPicture.asset(
                                        "assets/icons/calender.svg"),
                                  ),
                              hintText: widget.expireDateHint ?? "MM/YY",
                            ),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: TextFormField(
                        controller: cvvController,
                        onSaved: (cvv) {
                          _paymentCard.cvv = int.parse(cvv!);
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        validator: CardUtils.validateCVV,
                        decoration: widget.decoration ??
                            InputDecoration(
                              prefixIcon: widget.cvvFormPrefixIcon ??
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: SvgPicture.asset(
                                        "assets/icons/Cvv.svg"),
                                  ),
                              hintText: widget.cvvHint ?? "CVV",
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.only(top: defaultPadding),
            child: ElevatedButton(
              style: widget.addCardButtonStyle ??
                  OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: widget.buttonColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
              onPressed: () {
                if (widget.formKey.currentState!.validate()) {
                  widget.formKey.currentState?.save();
                  print(_paymentCard.toString());
                  widget.addCard(_paymentCard);
                }
              },
              child: Text(widget.addCardButtonText ?? "Add card"),
            ),
          )
        ],
      ),
    );
  }
}
