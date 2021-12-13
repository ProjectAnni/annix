import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PlatformStepper extends StatelessWidget {
  const PlatformStepper({
    Key? key,
    required this.steps,
    this.physics,
    this.type = StepperType.vertical,
    this.currentStep = 0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.controlsBuilder,
    this.elevation,
    this.margin,
  }) : super(key: key);

  final List<Step> steps;
  final ScrollPhysics? physics;
  final StepperType type;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;
  final ControlsWidgetBuilder? controlsBuilder;
  final double? elevation;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => Stepper(
        steps: steps,
        type: type,
        currentStep: currentStep,
        onStepTapped: onStepTapped,
        onStepContinue: onStepContinue,
        onStepCancel: onStepCancel,
        controlsBuilder: controlsBuilder,
        elevation: elevation,
        margin: margin,
      ),
      cupertino: (context, platform) => CupertinoStepper(
        steps: steps,
        type: type,
        currentStep: currentStep,
        onStepTapped: onStepTapped,
        onStepContinue: onStepContinue,
        onStepCancel: onStepCancel,
        controlsBuilder: controlsBuilder,
      ),
    );
  }
}
