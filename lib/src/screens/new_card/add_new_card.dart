
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';
import 'components/card_type.dart';
import 'components/card_utils.dart';
import 'components/input_formatters.dart';

class AddNewCardScreen extends StatefulWidget {
  const AddNewCardScreen({Key? key}) : super(key: key);

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("New Card"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              const Spacer(),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      onSaved: (cardNum) {
                        _paymentCard.number =
                            CardUtils.getCleanedNumber(cardNum!);
                      },
                      controller: creditCardController,
                      keyboardType: TextInputType.number,
                      validator: CardUtils.validateCardNum,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(19),
                        CardNumberInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SvgPicture.asset("assets/icons/card.svg"),
                        ),
                        suffixIcon: SizedBox(
                          width: 40,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            child: (_paymentCard.type != null)
                                ? CardUtils.getCardIcon(_paymentCard.type)
                                : null,
                          ),
                        ),
                        hintText: "Card number",
                      ),
                    ),
                    // Padding(
                    //   padding:
                    //       const EdgeInsets.symmetric(vertical: defaultPadding),
                    //   child: TextFormField(
                    //     onSaved: (name) {
                    //       _paymentCard.name = name;
                    //     },
                    //     textInputAction: TextInputAction.next,
                    //     decoration: InputDecoration(
                    //       prefixIcon: Padding(
                    //         padding: const EdgeInsets.symmetric(vertical: 10),
                    //         child: SvgPicture.asset("assets/icons/user.svg"),
                    //       ),
                    //       hintText: "Full name",
                    //     ),
                    //   ),
                    // ),
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
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: SvgPicture.asset("assets/icons/Cvv.svg"),
                              ),
                              hintText: "CVV",
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
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: SvgPicture.asset(
                                    "assets/icons/calender.svg"),
                              ),
                              hintText: "MM/YY",
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
                onPressed: () {},
                icon: SvgPicture.asset("assets/icons/scan.svg"),
                label: const Text("Scan card"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: defaultPadding),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Add card"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
