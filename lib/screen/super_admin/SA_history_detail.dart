import 'package:flutter/material.dart';

class SAHistoryDetailScreen extends StatelessWidget {
  final String status;
  SAHistoryDetailScreen({required this.status});
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
      backgroundColor: const Color.fromARGB(245,245,245, 245),
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
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'History',
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
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
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
                          child: Icon(Icons.apartment,
                              size: 30, color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        Text(ticketNumber,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(companyName,
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.desktop_windows,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 4),
                            Text(assetCount,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildStatusBox(),
                  SizedBox(height: 16),
                  _buildReadOnlyField(ticketNumber),
                  SizedBox(height: 12),
                  _buildReadOnlyField(requestNumber),
                  SizedBox(height: 12),
                  _buildReadOnlyField(category),
                  SizedBox(height: 12),
                  _buildReadOnlyField(description, maxLines: 3),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Uploaded Images",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: uploadedImages.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                  SizedBox(height: 24),
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
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFE6F4EA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.check, color: Colors.green),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("This request has done"),
              ],
            )
          ],
        ),
      );
    } else if (status == "rejected") {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFFFEDE7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Attention", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("This request has been rejected"),
              ],
            )
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
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
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
