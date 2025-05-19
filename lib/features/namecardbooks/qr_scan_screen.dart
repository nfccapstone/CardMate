import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cardmate/features/namecardbooks/card_controller.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final CardController cardController = Get.find<CardController>();
  MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;

  Future<void> _processQRCode(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      // URL에서 cardId 추출
      final uri = Uri.parse(code);
      final cardId = uri.pathSegments.last;
      
      // 명함 추가
      await cardController.addCardById(cardId);
      
      // 스캔 중지
      await controller.stop();
      
      // 성공 메시지 표시
      Get.snackbar(
        '성공',
        '명함이 추가되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 명함첩 화면으로 돌아가기
      Get.until((route) => route.settings.name == '/home');
    } catch (e) {
      Get.snackbar(
        '오류',
        '명함 추가 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 코드 스캔'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _processQRCode(barcode.rawValue!);
                    return;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'QR 코드를 카메라에 비춰주세요',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
} 