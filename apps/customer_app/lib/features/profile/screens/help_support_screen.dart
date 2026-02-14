// Help & Support Screen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../../../core/config/constants.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  SupportInfo? _supportInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSupportInfo();
  }

  Future<void> _loadSupportInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ApiClient(
        baseUrl: AppConstants.apiBaseUrl,
        tokenManager: TokenManager(),
      );
      final response = await apiClient.get('/api/v1/support');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _supportInfo = SupportInfo.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load support information';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not open $url')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSupportInfo,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _supportInfo == null
          ? const Center(child: Text('No support information available'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Support Section
                  if (_supportInfo!.shopName != null ||
                      _supportInfo!.shopPhone != null ||
                      _supportInfo!.shopEmail != null ||
                      _supportInfo!.shopWhatsapp != null) ...[
                    _buildSectionHeader('Contact Support'),
                    _buildContactCard(
                      context,
                      title: _supportInfo!.shopName ?? 'Shop Contact',
                      icon: Icons.store,
                      children: [
                        if (_supportInfo!.shopAddress != null)
                          _buildInfoTile(
                            icon: Icons.location_on,
                            label: 'Address',
                            value: _supportInfo!.shopAddress!,
                            onTap: () => _copyToClipboard(
                              _supportInfo!.shopAddress!,
                              'Address',
                            ),
                          ),
                        if (_supportInfo!.shopPhone != null)
                          _buildInfoTile(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: _supportInfo!.shopPhone!,
                            onTap: () =>
                                _launchUrl('tel:${_supportInfo!.shopPhone}'),
                            onLongPress: () => _copyToClipboard(
                              _supportInfo!.shopPhone!,
                              'Phone number',
                            ),
                          ),
                        if (_supportInfo!.shopEmail != null)
                          _buildInfoTile(
                            icon: Icons.email,
                            label: 'Email',
                            value: _supportInfo!.shopEmail!,
                            onTap: () =>
                                _launchUrl('mailto:${_supportInfo!.shopEmail}'),
                            onLongPress: () => _copyToClipboard(
                              _supportInfo!.shopEmail!,
                              'Email',
                            ),
                          ),
                        if (_supportInfo!.shopWhatsapp != null)
                          _buildInfoTile(
                            icon: Icons.chat,
                            label: 'WhatsApp',
                            value: _supportInfo!.shopWhatsapp!,
                            onTap: () => _launchUrl(
                              'https://wa.me/${_supportInfo!.shopWhatsapp!.replaceAll(RegExp(r'[^\d]'), '')}',
                            ),
                            onLongPress: () => _copyToClipboard(
                              _supportInfo!.shopWhatsapp!,
                              'WhatsApp number',
                            ),
                            iconColor: Colors.green,
                          ),
                        if (_supportInfo!.workingHours != null)
                          _buildInfoTile(
                            icon: Icons.access_time,
                            label: 'Working Hours',
                            value: _supportInfo!.workingHours!,
                            onTap: null,
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Report Bugs Section
                  if (_supportInfo!.developerName != null ||
                      _supportInfo!.developerEmail != null ||
                      _supportInfo!.developerWhatsapp != null) ...[
                    _buildSectionHeader('Report Bugs'),
                    _buildContactCard(
                      context,
                      title: _supportInfo!.developerName ?? 'Developer Contact',
                      icon: Icons.bug_report,
                      children: [
                        if (_supportInfo!.developerEmail != null)
                          _buildInfoTile(
                            icon: Icons.email,
                            label: 'Email',
                            value: _supportInfo!.developerEmail!,
                            onTap: () => _launchUrl(
                              'mailto:${_supportInfo!.developerEmail}?subject=Bug Report - Vijaya Xerox App',
                            ),
                            onLongPress: () => _copyToClipboard(
                              _supportInfo!.developerEmail!,
                              'Developer email',
                            ),
                          ),
                        if (_supportInfo!.developerWhatsapp != null)
                          _buildInfoTile(
                            icon: Icons.chat,
                            label: 'WhatsApp',
                            value: _supportInfo!.developerWhatsapp!,
                            onTap: () => _launchUrl(
                              'https://wa.me/${_supportInfo!.developerWhatsapp!.replaceAll(RegExp(r'[^\d]'), '')}?text=Bug Report - Vijaya Xerox App',
                            ),
                            onLongPress: () => _copyToClipboard(
                              _supportInfo!.developerWhatsapp!,
                              'Developer WhatsApp',
                            ),
                            iconColor: Colors.green,
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Additional Info
                  if (_supportInfo!.websiteUrl != null) ...[
                    _buildSectionHeader('More Information'),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.language, color: Colors.blue),
                        title: const Text('Visit Website'),
                        subtitle: Text(_supportInfo!.websiteUrl!),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _launchUrl(_supportInfo!.websiteUrl!),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade700),
      title: Text(label),
      subtitle: Text(value),
      trailing: onTap != null ? const Icon(Icons.touch_app, size: 20) : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
