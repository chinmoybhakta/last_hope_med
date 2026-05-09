import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Header
          _buildAppHeader(context),
          const SizedBox(height: 24),

          // App Description
          _buildSection(
            context,
            title: 'About Qwen-MediCare-BD',
            content: 'Qwen-MediCare-BD is Bangladesh\'s first offline medical AI assistant. '
                'It provides accurate, helpful information about medical conditions, symptoms, '
                'treatments, and medications. The app works completely offline after initial setup, '
                'ensuring your privacy and accessibility even without internet connectivity.\n\n'
                'Built with a fine-tuned Qwen2.5-3B language model trained on 30,523 medical '
                'Q&A pairs including Bangladesh-specific medical data.',
          ),
          const SizedBox(height: 16),

          // Key Features
          _buildSection(
            context,
            title: 'Key Features',
            content: '• 100% Offline after initial setup\n'
                '• Bangla & English language support\n'
                '• Bangladesh-specific medical knowledge\n'
                '• Drug information with local brand names\n'
                '• Medical disclaimer on every response\n'
                '• No data collection or tracking\n'
                '• No internet required for inference',
          ),
          const SizedBox(height: 16),

          // Privacy Policy
          _buildExpandableSection(
            context,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            children: [
              _buildSubSection(
                'Data Collection',
                'Qwen-MediCare-BD does NOT collect, store, or transmit any personal data. '
                    'All processing happens locally on your device. Your conversations, '
                    'medical queries, and personal information never leave your phone.',
              ),
              _buildSubSection(
                'Local Storage',
                'Chat history is stored locally on your device using secure local storage. '
                    'You can delete conversations at any time. No data is backed up to '
                    'external servers or cloud services.',
              ),
              _buildSubSection(
                'Model Downloads',
                'During initial setup, the app downloads the AI model (~1.9 GB) and '
                    'translation models directly from Hugging Face. This is a one-time '
                    'download. No analytics or tracking data is sent during this process.',
              ),
              _buildSubSection(
                'Permissions',
                '• Internet: Required only for initial model download\n'
                    '• Storage: Used to save the AI model and chat history locally\n'
                    '• No camera, microphone, contacts, or location access required',
              ),
              _buildSubSection(
                'Third-Party Services',
                'This app uses Google ML Kit for on-device translation. '
                    'ML Kit processes text entirely on your device. '
                    'No data is sent to Google servers for translation.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Medical Disclaimer
          _buildExpandableSection(
            context,
            title: 'Medical Disclaimer',
            icon: Icons.medical_services_outlined,
            children: [
              _buildSubSection(
                'Not Medical Advice',
                'Qwen-MediCare-BD provides information for EDUCATIONAL PURPOSES ONLY. '
                    'It is NOT a substitute for professional medical advice, diagnosis, '
                    'or treatment. Always seek the advice of your physician or other '
                    'qualified healthcare provider with any questions you may have '
                    'regarding a medical condition.',
              ),
              _buildSubSection(
                'Emergency',
                'In case of a medical emergency, call your local emergency services '
                    'immediately. In Bangladesh, dial 999 for emergency services.',
              ),
              _buildSubSection(
                'Accuracy',
                'While we strive for accuracy, the AI model may occasionally provide '
                    'incomplete or inaccurate information. Always verify medical '
                    'information with qualified healthcare professionals.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Terms of Use
          _buildExpandableSection(
            context,
            title: 'Terms of Use',
            icon: Icons.description_outlined,
            children: [
              _buildSubSection(
                'Acceptance',
                'By using Qwen-MediCare-BD, you acknowledge that you understand and '
                    'agree to these terms. If you do not agree, please do not use the app.',
              ),
              _buildSubSection(
                'User Responsibility',
                'You are solely responsible for your use of the app and any consequences '
                    'thereof. The developers assume no liability for any damages or losses '
                    'resulting from the use of this application.',
              ),
              _buildSubSection(
                'Intellectual Property',
                'The Qwen-MediCare-BD model is based on Qwen2.5-3B-Instruct '
                    '(Apache 2.0 License). The fine-tuned model is available on '
                    'Hugging Face under the MIT License.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Open Source Licenses
          _buildExpandableSection(
            context,
            title: 'Open Source Licenses',
            icon: Icons.code,
            children: [
              _buildLicenseItem('Qwen2.5-3B-Instruct', 'Apache 2.0'),
              _buildLicenseItem('llama.cpp / llama_flutter_android', 'MIT'),
              _buildLicenseItem('Google ML Kit', 'Apache 2.0'),
              _buildLicenseItem('Flutter', 'BSD 3-Clause'),
              _buildLicenseItem('Hive', 'MIT'),
              _buildLicenseItem('Riverpod', 'MIT'),
              const SizedBox(height: 12),
              _buildLinkButton(
                context,
                'View Full Licenses',
                Icons.open_in_new,
                () async {
                  final uri = Uri.parse('https://opensource.org/licenses');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Technical Information
          _buildSection(
            context,
            title: 'Technical Information',
            content: 'Model: Qwen2.5-3B-Instruct (Fine-tuned)\n'
                'Size: 1.9 GB (Q4_K_M Quantized)\n'
                'Training Data: 30,523 medical Q&A pairs\n'
                'Translation: Google ML Kit On-Device\n'
                'Storage: Local Hive Database\n'
                'Architecture: Clean Architecture + Riverpod',
          ),
          const SizedBox(height: 16),

          // Contact & Links
          _buildSection(
            context,
            title: 'Links',
            content: '',
          ),
          _buildLinkButton(
            context,
            'Model on Hugging Face',
            Icons.hub,
            () async {
              final uri = Uri.parse('https://huggingface.co/CBrootA/Qwen-MediCare-BD');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          _buildLinkButton(
            context,
            'Source Code (GitHub)',
            Icons.code,
            () async {
              final uri = Uri.parse('https://github.com/your-repo/qwen-medicare-bd');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: 16),

          // Version
          Center(
            child: Column(
              children: [
                Text(
                  'Qwen-MediCare-BD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2026 Qwen-MediCare-BD Team',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Built with ❤️ for Bangladesh',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medical_services,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Qwen-MediCare-BD',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'স্বাস্থ্য আপনার হাতের মুঠোয়',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseItem(String name, String license) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Text(
              license,
              style: TextStyle(fontSize: 11, color: Colors.green[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}