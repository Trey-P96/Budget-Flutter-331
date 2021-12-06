import "package:flutter/material.dart";

class ApiButton extends StatelessWidget {
  final String label;
  final Future<void> Function() apiCall;

  const ApiButton({
    Key? key,
    required this.label,
    required this.apiCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await apiCall();
        } catch (e) {
          print(e);
        }
      },
      child: Text(label),
    );
  }
}
