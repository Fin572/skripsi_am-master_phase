import 'package:asset_management/screen/models/organization.dart';
import 'package:asset_management/screen/super_admin/SA_asset_devices_screen.dart';
import 'package:asset_management/screen/super_admin/SA_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:asset_management/widgets/add_organization_dialog.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

class SuperAdminAddOrganization extends StatefulWidget {
  const SuperAdminAddOrganization({Key? key}) : super(key: key);

  @override
  State<SuperAdminAddOrganization> createState() => _SuperAdminAddOrganizationState();
}

class _SuperAdminAddOrganizationState extends State<SuperAdminAddOrganization> {
  final TextEditingController _searchController = TextEditingController();
  final List<Organization> _organizations = [];
  bool _isEditing = false; 
  Set<String> _selectedOrganizations = {};
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _fetchOrganizations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrganizations() async { 
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://assetin.my.id/skripsi/fetch_organizations.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _organizations.clear();
          _organizations.addAll(data.map((item) => Organization(
                id: item['organization_id'].toString(),
                name: item['organization_name'],
              )));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch organizations: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching organizations: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addOrganization() async {
    final String? orgName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const AddOrganizationDialog(),
    );

    if (orgName != null && orgName.isNotEmpty) {
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organization "$orgName" added successfully!')),
      );
    }
  }

  void _toggleEditMode() { 
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedOrganizations.clear(); 
      }
    });
  }

  void _toggleSelectOrganization(String orgId) { 
    setState(() {
      if (_selectedOrganizations.contains(orgId)) {
        _selectedOrganizations.remove(orgId);
      } else {
        _selectedOrganizations.add(orgId);
      }
    });
  }

  Future<void> _deleteOrganizations() async { 
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://assetin.my.id/skripsi/delete_organization.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'organization_ids': _selectedOrganizations.toList()}),
      );

      if (response.statusCode == 200) {
        await _fetchOrganizations(); 
        setState(() {
          _selectedOrganizations.clear();
          _isEditing = false; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected organization(s) deleted.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete organizations: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting organizations: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmAndDeleteOrganizations() async { 
    if (_selectedOrganizations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No organizations selected for deletion.')),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${_selectedOrganizations.length} selected organization(s)?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteOrganizations(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Organization> filteredOrganizations = _organizations;
    if (_searchController.text.isNotEmpty) {
      filteredOrganizations = _organizations
          .where((org) => org.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(245, 245, 245, 245),
      appBar: AppBar(
        toolbarHeight: 95,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Organizations', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, 
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_image.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.done_all : Icons.edit, color: Colors.white), 
            onPressed: _toggleEditMode, 
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : filteredOrganizations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/nodata.png',
                              width: 100,
                            ),
                            const SizedBox(height: 20), 
                            const Text( 
                              'No organizations found.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredOrganizations.length,
                        itemBuilder: (context, index) {
                          final org = filteredOrganizations[index];
                          final isSelected = _selectedOrganizations.contains(org.id); 
                          return GestureDetector(
                            onLongPress: () { 
                              if (!_isEditing) {
                                _toggleEditMode();
                              }
                              _toggleSelectOrganization(org.id);
                            },
                            onTap: () {
                              if (_isEditing) {
                                _toggleSelectOrganization(org.id);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SuperAdminDevicesScreen(),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: _isEditing && isSelected
                                    ? const BorderSide(color: Colors.blue, width: 2.0)
                                    : BorderSide.none,
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (_isEditing) 
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              _toggleSelectOrganization(org.id);
                                            },
                                          ),
                                        const CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.transparent,
                                          child: Icon(Icons.business, size: 40, color: Color.fromARGB(255, 4, 79, 141)),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '#${org.id}', 
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(221, 131, 131, 131)),
                                              ),
                                              Text(
                                                org.name,
                                                style: const TextStyle(
                                                    fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20, thickness: 1, color: Colors.grey),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.laptop_mac, size: 20, color: Colors.black54),
                                            SizedBox(width: 5),
                                            Text(
                                              '0 Device', 
                                              style: TextStyle(fontSize: 14, color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                        if (!_isEditing) 
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const SuperAdminDevicesScreen(),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: const [
                                                Text('Detail', style: TextStyle(color: Colors.blue)),
                                                Icon(Icons.arrow_circle_right, size: 18, color: Colors.blue),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: _isEditing 
                  ? ElevatedButton(
                      onPressed: _confirmAndDeleteOrganizations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Delete', 
                        style: TextStyle(color: Color.fromARGB(255, 201, 99, 99), fontSize: 16), 
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _addOrganization,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Add Organization', // Text for add button
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}