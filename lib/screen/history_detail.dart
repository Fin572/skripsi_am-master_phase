import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  final String status;
  // Add incident_id as a required named parameter
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
      backgroundColor: const Color(0xFFF5F6FA), // From NEW UI
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
                        child: const Icon(Icons.arrow_back, color: Colors.white), // Changed to const
                      ),
                      const SizedBox(width: 16), // Changed to const
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
              padding: const EdgeInsets.symmetric(horizontal: 20), // From NEW UI
              child: Column(
                children: [
                  const SizedBox(height: 16), // Changed to const
                  Container(
                    padding: const EdgeInsets.all(16), // From NEW UI
                    decoration: BoxDecoration(
                      gradient: const LinearGradient( // Changed to const
                        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)], // From NEW UI
                        begin: Alignment.topLeft, // From NEW UI
                        end: Alignment.bottomRight, // From NEW UI
                      ),
                      borderRadius: BorderRadius.circular(16), // From NEW UI
                      boxShadow: const [ // Changed to const
                        BoxShadow(
                          color: Colors.black12, // From NEW UI
                          blurRadius: 6, // From NEW UI
                          offset: Offset(0, 2), // From NEW UI
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24, // From NEW UI
                          backgroundColor: Colors.white, // From NEW UI
                          child: const Icon(Icons.apartment, // Changed to const
                              size: 30, color: Colors.blue), // From NEW UI
                        ),
                        const SizedBox(height: 8), // Changed to const
                        Text(ticketNumber,
                            style: const TextStyle( // Changed to const
                                color: Colors.white, // From NEW UI
                                fontWeight: FontWeight.bold)), // From NEW UI
                        Text(companyName,
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 14)), // Changed to const
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // From NEW UI
                          children: [
                            const Icon(Icons.desktop_windows, // Changed to const
                                color: Colors.white70, size: 16), // From NEW UI
                            const SizedBox(width: 4), // Changed to const
                            Text(assetCount,
                                style: const TextStyle( // Changed to const
                                    color: Colors.white70, fontSize: 14)), // From NEW UI
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Changed to const
                  _buildStatusBox(),
                  const SizedBox(height: 16), // Changed to const
                  _buildReadOnlyField(ticketNumber),
                  const SizedBox(height: 12), // Changed to const
                  _buildReadOnlyField(requestNumber),
                  const SizedBox(height: 12), // Changed to const
                  _buildReadOnlyField(category),
                  const SizedBox(height: 12), // Changed to const
                  _buildReadOnlyField(description, maxLines: 3),
                  const SizedBox(height: 20), // Changed to const
                  const Align( // Changed to const
                    alignment: Alignment.centerLeft,
                    child: Text("Upload Images",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8), // Changed to const
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Changed to const
                    itemCount: uploadedImages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // Changed to const
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
                            borderRadius: BorderRadius.circular(12), // From NEW UI
                            image: DecorationImage(
                              image: AssetImage(uploadedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24), // Changed to const
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
        padding: const EdgeInsets.all(12), // From NEW UI
        decoration: BoxDecoration(
          color: const Color(0xFFE6F4EA), // From NEW UI
          borderRadius: BorderRadius.circular(12), // From NEW UI
        ),
        child: const Row( // Changed to const
          children: [
            Icon(Icons.check, color: Colors.green), // From NEW UI
            SizedBox(width: 12), // From NEW UI
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Done", style: TextStyle(fontWeight: FontWeight.bold)), // From NEW UI
                Text("Your request has done"), // From NEW UI
              ],
            )
          ],
        ),
      );
    } else if (status == "rejected") {
      return Container(
        padding: const EdgeInsets.all(12), // From NEW UI
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDE7), // From NEW UI
          borderRadius: BorderRadius.circular(12), // From NEW UI
        ),
        child: const Row( // Changed to const
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange), // From NEW UI
            SizedBox(width: 12), // From NEW UI
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Attention", style: TextStyle(fontWeight: FontWeight.bold)), // From NEW UI
                Text("Your request has been rejected"), // From NEW UI
              ],
            )
          ],
        ),
      );
    } else {
      return const SizedBox.shrink(); // Changed to const
    }
  }

  Widget _buildReadOnlyField(String text, {int maxLines = 1}) {
    return TextField(
      readOnly: true,
      maxLines: maxLines,
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        filled: true, // From NEW UI
        fillColor: Colors.grey[200], // From NEW UI
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // From NEW UI
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // From NEW UI
          borderSide: BorderSide.none, // From NEW UI
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
                icon: const Icon(Icons.close, color: Colors.white, size: 30), // Changed to const
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}