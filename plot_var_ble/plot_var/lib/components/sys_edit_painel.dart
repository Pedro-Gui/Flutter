import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ble/ble_controller.dart';
import '../../services/ble/ble_uuids.dart';
import 'sys_spinner.dart';

class SysEditPainel extends StatefulWidget {
  final double hState;
  final int mState;
  final double aState;
  final double bState;
  final bool ledState;
  final WidgetRef ref;

  const SysEditPainel({
    super.key,
    required this.hState,
    required this.mState,
    required this.aState,
    required this.bState,
    required this.ledState,
    required this.ref,
  });

  @override
  State<SysEditPainel> createState() => _SysEditPainelState();
}

class _SysEditPainelState extends State<SysEditPainel> {
  bool _isExpanded = false;
  
  late double _currentH;
  late int _currentM;
  late double _currentA;
  late double _currentB;
  late bool _currentLed;

  @override
  void initState() {
    super.initState();
    _currentH = widget.hState;
    _currentM = widget.mState;
    _currentA = widget.aState;
    _currentB = widget.bState;
    _currentLed = widget.ledState;
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bleNotifier = widget.ref.read(bleControllerProvider.notifier);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Ajustes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.keyboard_arrow_up),
                    ),
                    onPressed: _toggleMenu,
                  ),
                ],
              ),
            ),
            
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    Divider(thickness: 0.5, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.5,
                      children: [
                        SysSpinner<double>(
                          value: _currentH,
                          title: BleUUIDs.getDescriptor(BleUUIDs.H_UUID),
                          maxValue: 10,
                          step: 0.1,
                          showAllButton: 1,
                          onSubmitted: (val) {
                            bleNotifier.setCarac<double>(BleUUIDs.CONTROL_UUID, BleUUIDs.H_UUID, val);
                            setState(() => _currentH = val);
                          },
                        ),
                        SysSpinner<int>(
                          value: _currentM,
                          title: BleUUIDs.getDescriptor(BleUUIDs.M_UUID),
                          maxValue: 10,
                          step: 1,
                          showAllButton: 1,
                          onSubmitted: (val) {
                            bleNotifier.setCarac<int>(BleUUIDs.CONTROL_UUID, BleUUIDs.M_UUID, val);
                            setState(() => _currentM = val);
                          },
                        ),
                        SysSpinner<double>(
                          value: _currentA,
                          title: BleUUIDs.getDescriptor(BleUUIDs.A_UUID),
                          maxValue: 10,
                          step: 0.1,
                          showAllButton: 1,
                          onSubmitted: (val) {
                            bleNotifier.setCarac<double>(BleUUIDs.CONTROL_UUID, BleUUIDs.A_UUID, val);
                            setState(() => _currentA = val);
                          },
                        ),
                        SysSpinner<double>(
                          value: _currentB,
                          title: BleUUIDs.getDescriptor(BleUUIDs.B_UUID),
                          maxValue: 10,
                          step: 0.1,
                          showAllButton: 1,
                          onSubmitted: (val) {
                            bleNotifier.setCarac<double>(BleUUIDs.CONTROL_UUID, BleUUIDs.B_UUID, val);
                            setState(() => _currentB = val);
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    Divider(thickness: 0.5, color: Colors.grey[400]),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                            onPressed: () async {
                              final nextLedState = !_currentLed;
                              await bleNotifier.setCarac<bool>(
                                BleUUIDs.LED_ACTUATOR_UUID,
                                BleUUIDs.LED_CARAC_UUID,
                                nextLedState,
                              );
                              setState(() => _currentLed = nextLedState);
                            },
                            icon: Icon(_currentLed ? Icons.light_mode : Icons.light_mode_outlined),
                            label: const Text('Toggle LED'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              await bleNotifier.setCarac<bool>(
                                BleUUIDs.CONTROL_UUID,
                                BleUUIDs.OK_UUID,
                                true,
                              );
                            },
                            icon: const Icon(Icons.send),
                            label: const Text('ENVIAR (OK)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}