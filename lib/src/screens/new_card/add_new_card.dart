import 'package:card_scanner/card_scanner.dart';
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
    required this.addCard,
    this.scan,
    this.addCardButtonText,
    this.scanCardButtonText,
    this.decoration,
    this.hintText,
    this.addCardButtonStyle,
    this.scanCardButtonStyle,
    this.padding,
    this.numberFormPrefixIcon,
    this.numberFormSuffixIcon,
    this.cvvFormPrefixIcon,
    this.mmyyFormPrefixIcon,
    this.scanButtonIcon,
    this.fromKey,
  }) : super(key: key);

  final Function(PaymentCard) addCard;
  final Function()? scan;
  final String? addCardButtonText;
  final String? scanCardButtonText;
  final InputDecoration? decoration;
  final String? hintText;
  final ButtonStyle? addCardButtonStyle;
  final ButtonStyle? scanCardButtonStyle;
  final EdgeInsetsGeometry? padding;
  final Widget? numberFormPrefixIcon;
  final Widget? numberFormSuffixIcon;
  final Widget? cvvFormPrefixIcon;
  final Widget? mmyyFormPrefixIcon;
  final Widget? scanButtonIcon;
  final Key? fromKey;
  @override
  State<AddNewCardForm> createState() => _AddNewCardFormState();
}

class _AddNewCardFormState extends State<AddNewCardForm> {
  TextEditingController creditCardController = TextEditingController();
  final PaymentCard _paymentCard = PaymentCard();

  @override
  void initState() {
    creditCardController.addListener(
      () {
        _getCardTypeFrmNumber();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    creditCardController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    if (creditCardController.text.length <= 6) {
      String input = CardUtils.getCleanedNumber(creditCardController.text);
      CardType cardType = CardUtils.getCardTypeFrmNumber(input);
      if (cardType != _paymentCard.type) {
        setState(() {
          _paymentCard.type = cardType;
        });
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
            key: widget.fromKey,
            child: Column(
              children: [
                TextFormField(
                  onSaved: (cardNum) {
                    _paymentCard.number = CardUtils.getCleanedNumber(cardNum!);
                  },
                  controller: creditCardController,
                  keyboardType: TextInputType.number,
                  validator: CardUtils.validateCardNum,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
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
                        hintText: widget.hintText ?? "Card number",
                      ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onSaved: (cvv) {
                          _paymentCard.cvv = int.parse(cvv!);
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
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
                              hintText: widget.hintText ?? "CVV",
                            ),
                      ),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                      child: TextFormField(
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
                              prefixIcon: widget.mmyyFormPrefixIcon ??
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: SvgPicture.asset(
                                        "assets/icons/calender.svg"),
                                  ),
                              hintText: widget.hintText ?? "MM/YY",
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          OutlinedButton.icon(
            onPressed: widget.scan ??
                () async {
                  final card = await CardScanner.scanCard();
                  final expiryDate = card!.expiryDate.split('/');
                  final paymentCard = PaymentCard(
                    name: card.cardHolderName,
                    number: card.cardNumber,
                    month: int.parse(expiryDate[0]),
                    year: int.parse(expiryDate[1]),
                  );
                },
            icon: widget.scanButtonIcon ??
                SvgPicture.asset("assets/icons/scan.svg"),
            label: Text(widget.scanCardButtonText ?? "Scan card"),
            style: widget.scanCardButtonStyle ??
                ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: defaultPadding),
            child: ElevatedButton(
              style: widget.addCardButtonStyle ??
                  OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
              onPressed: () {
                widget.addCard(_paymentCard);
              },
              child: Text(widget.addCardButtonText ?? "Add card"),
            ),
          )
        ],
      ),
    );
  }
}
