import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  final String status;
  final int incident_id;

  HistoryDetailScreen({Key? key, required this.status, required this.incident_id}) : super(key: key);
  final String ticketNumber = "#000001";
  final String requestNumber = "#001001";
  final String companyName = "PT Dunia Persada";
  final String assetCount = "120 Aset";
  final String category = "CCTV";
  final String description =
      "Terdapat satu saluran cctv yang tidak muncul di layar TV";

  final List<String> uploadedImages = [
    'assets/laci.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), 
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/bg_image.png',
                height: 95,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white), 
                      ),
                      const SizedBox(width: 16), 
                      const Text(
                        'Incident',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16), 
                  Container(
                    padding: const EdgeInsets.all(16), 
                    decoration: BoxDecoration(
                      gradient: const LinearGradient( 
                        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)], 
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight, 
                      ),
                      borderRadius: BorderRadius.circular(16), 
                      boxShadow: const [ 
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6, 
                          offset: Offset(0, 2), 
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24, 
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.apartment, 
                              size: 30, color: Colors.blue),
                        ),
                        const SizedBox(height: 8), 
                        Text(ticketNumber,
                            style: const TextStyle( 
                                color: Colors.white,
                                fontWeight: FontWeight.bold)), 
                        Text(companyName,
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 14)), 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            const Icon(Icons.desktop_windows, 
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4), 
                            Text(assetCount,
                                style: const TextStyle( 
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), 
                  _buildStatusBox(),
                  const SizedBox(height: 16), 
                  _buildReadOnlyField(ticketNumber),
                  const SizedBox(height: 12), 
                  _buildReadOnlyField(requestNumber),
                  const SizedBox(height: 12), 
                  _buildReadOnlyField(category),
                  const SizedBox(height: 12), 
                  _buildReadOnlyField(description, maxLines: 3),
                  const SizedBox(height: 20), 
                  const Align( 
                    alignment: Alignment.centerLeft,
                    child: Text("Upload Images",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8), 
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: uploadedImages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => showImageFullscreen(context, index, uploadedImages),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(uploadedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox() {
    if (status == "done") {
      return Container(
        padding: const EdgeInsets.all(12), 
        decoration: BoxDecoration(
          color: const Color(0xFFE6F4EA),
          borderRadius: BorderRadius.circular(12), 
        ),
        child: const Row( 
          children: [
            Icon(Icons.check, color: Colors.green), 
            SizedBox(width: 12), 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Your request has done"),
              ],
            )
          ],
        ),
      );
    } else if (status == "rejected") {
      return Container(
        padding: const EdgeInsets.all(12), 
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDE7), 
          borderRadius: BorderRadius.circular(12), 
        ),
        child: const Row( 
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange), 
            SizedBox(width: 12), // 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Attention", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Your request has been rejected"), 
              ],
            )
          ],
        ),
      );
    } else {
      return const SizedBox.shrink(); 
    }
  }

  Widget _buildReadOnlyField(String text, {int maxLines = 1}) {
    return TextField(
      readOnly: true,
      maxLines: maxLines,
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        filled: true, 
        fillColor: Colors.grey[200], 
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: BorderSide.none, 
        ),
      ),
    );
  }
}

void showImageFullscreen(
    BuildContext context, int startIndex, List<String> uploadedImages) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: startIndex),
              itemCount: uploadedImages.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.asset(
                      uploadedImages[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30), 
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}