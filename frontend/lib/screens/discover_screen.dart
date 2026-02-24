import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String apiResult = '';
  bool loading = false;

  Future<void> fetchApi() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });
    final result = await ApiService.fetchExample();
    if (!mounted) return;
    setState(() {
      apiResult = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: loading ? null : fetchApi,
            child: loading
                ? const CircularProgressIndicator()
                : const Icon(Icons.cloud_download),
          ),
          const SizedBox(height: 24),
          Text(apiResult, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
