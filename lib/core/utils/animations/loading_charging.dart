import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:restic_movil/core/utils/helpers/Constants.dart';

class LoadingCharging extends StatelessWidget {
  const LoadingCharging({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(Constants.CHARGING);
  }
}
