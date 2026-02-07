import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_drawer.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _maxOrderController = TextEditingController();
  bool _allowCod = false;
  bool _showOutOfStock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _maxOrderController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      await context.read<SettingsProvider>().fetchSettings();
      if (!mounted) return;
      _syncFromProvider();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _syncFromProvider() {
    final provider = context.read<SettingsProvider>();
    setState(() {
      _allowCod = provider.getBool('allow_cod', defaultValue: false);
      _showOutOfStock = provider.getBool(
        'show_out_of_stock',
        defaultValue: true,
      );
      _maxOrderController.text = provider
          .getInt('max_order_quantity', defaultValue: 10)
          .toString();
    });
  }

  Future<void> _saveSettings() async {
    final maxQty = int.tryParse(_maxOrderController.text.trim());
    if (maxQty == null || maxQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Max order quantity must be a positive number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final provider = context.read<SettingsProvider>();
      await provider.updateSetting('allow_cod', {'enabled': _allowCod});
      await provider.updateSetting('max_order_quantity', {'value': maxQty});
      await provider.updateSetting('show_out_of_stock', {
        'enabled': _showOutOfStock,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: RouteNames.settings),
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        actions: [
          TextButton(onPressed: _saveSettings, child: const Text('Save')),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          if (settingsProvider.isLoading && settingsProvider.settings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (settingsProvider.errorMessage != null &&
              settingsProvider.settings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      settingsProvider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    ElevatedButton(
                      onPressed: _loadSettings,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              SwitchListTile(
                title: const Text('Allow Cash on Delivery'),
                subtitle: const Text('Enable or disable COD payments'),
                value: _allowCod,
                onChanged: (value) => setState(() => _allowCod = value),
              ),
              const Divider(),
              ListTile(
                title: const Text('Max Order Quantity'),
                subtitle: const Text('Maximum items allowed per order'),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _maxOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Show Out of Stock Items'),
                subtitle: const Text('Display items even if out of stock'),
                value: _showOutOfStock,
                onChanged: (value) => setState(() => _showOutOfStock = value),
              ),
              const SizedBox(height: AppConstants.largePadding),
              ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
              ),
            ],
          );
        },
      ),
    );
  }
}
