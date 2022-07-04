import 'package:electricbills/widgets/rounded_box.dart';
import 'package:electricbills/widgets/texts.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final IconData icon;
  final String name;
  final TextEditingController controller;
  final bool? obscureText;
  final Widget? suffix;
  final dynamic onChanged;
  final Color? color;
  const MyTextField(
      {Key? key,
      required this.name,
      required this.icon,
      required this.controller,
      this.color,
      this.suffix,
      this.onChanged,
      this.obscureText})
      : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool showSuffix = false;

  chnageShowSuffix() {
    setState(() {
      showSuffix = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(chnageShowSuffix);
  }

  @override
  void dispose() {
    widget.controller.removeListener(chnageShowSuffix);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RounderBox(
      color: widget.color ?? Colors.white.withOpacity(0.9),
      child: TextField(
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged(value);
          }
        },
        obscureText: widget.obscureText ?? false,
        controller: widget.controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(widget.icon),
          suffixIcon: widget.suffix,
          hintText: !showSuffix ? widget.name : null,
          suffix: showSuffix
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: MyText(
                      text: widget.name,
                      textColor: Colors.grey,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class MyDropDownButton extends StatefulWidget {
  final List<String> items;
  final Color? color;
  final String? value;
  final dynamic onChanged;
  final TextEditingController controller;
  final double? itemFontSize;
  const MyDropDownButton({
    Key? key,
    required this.items,
    required this.controller,
    this.onChanged,
    this.value,
    this.color,
    this.itemFontSize,
  }) : super(key: key);

  @override
  State<MyDropDownButton> createState() => _MyDropDownButtonState();
}

class _MyDropDownButtonState extends State<MyDropDownButton> {
  String? value;
  Map<String, IconData> iconData = {
    "editor": Icons.edit_outlined,
    "viewer": Icons.edit_off_outlined
  };

  @override
  void initState() {
    super.initState();
    value = widget.value ?? widget.items.first;
    widget.controller.text = value!;
  }

  @override
  Widget build(BuildContext context) {
    return RounderBox(
      color: widget.color,
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          value: value,
          elevation: 0,
          items: widget.items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: RounderBox(
                  padding: const EdgeInsets.only(left: 10),
                  color: widget.color,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(text: item, fontSize: widget.itemFontSize),
                        Icon(
                          iconData[item.toLowerCase()],
                          color: item == value ? Colors.blue : Colors.black,
                        )
                      ])),
            );
          }).toList(),
          onChanged: (String? newVal) {
            if (newVal != null) {
              setState(() {
                value = newVal;
                widget.controller.text = newVal;
              });
              if (widget.onChanged != null) {
                widget.onChanged(newVal);
              }
            }
          },
        ),
      ),
    );
  }
}
