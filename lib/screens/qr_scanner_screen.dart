import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:red_llantera_app/screens/tire_detail_screen.dart';
import 'package:red_llantera_app/utils/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _flashOn = false;
  bool _processingCode = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    // En Android es necesario pausar la cámara
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_processingCode) return; // Evitar múltiples escaneos
      
      setState(() {
        _processingCode = true;
      });

      _processQrCode(scanData.code ?? '');
    });
  }

  Future<void> _processQrCode(String code) async {
    // Vibrar o hacer un sonido para indicar que se escaneó un código
    
    // Verificar si el código es válido para nuestro sistema
    if (code.startsWith('REDLLANTERA:')) {
      // Extraer el ID de la llanta del código QR
      final tireId = code.split(':')[1];
      
      // Navegar a la pantalla de detalles
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TireDetailScreen(tireId: tireId),
          ),
        ).then((_) {
          // Cuando regresamos del detalle, permitir escanear otro código
          setState(() {
            _processingCode = false;
          });
        });
      }
    } else {
      // Mostrar error si el código no es válido
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código QR no válido para Red Llantera'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Permitir escanear otro código después de un error
        setState(() {
          _processingCode = false;
        });
      }
    }
  }

  void _toggleFlash() async {
    await controller?.toggleFlash();
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: 'Linterna',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: AppTheme.primaryColor,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
                if (_processingCode)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Procesando código...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text(
                'Coloca el código QR de la llanta dentro del recuadro para escanear',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}