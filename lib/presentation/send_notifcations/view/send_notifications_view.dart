import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:ai_movie_suggestion/presentation/send_notifcations/viewmodel/send_notifications_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/send_notifcations/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SendNotificationView extends StatefulWidget {
  const SendNotificationView({Key? key}) : super(key: key);

  @override
  _SendNotificationViewState createState() => _SendNotificationViewState();
}

class _SendNotificationViewState extends State<SendNotificationView> {
  final SendNotificationViewModel _viewModel = instance<SendNotificationViewModel>();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _bind();
    _checkNotificationPermissions();
  }

  void _bind() {
    _viewModel.start();
    _messageController.addListener(() {
      _viewModel.setMessage(_messageController.text);
    });

    // Set default date and time
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
    _updateDateTime();
  }

  void _updateDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      final combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      _viewModel.setDate(combinedDateTime);
    }
  }

  Future<void> _checkNotificationPermissions() async {
    final enabled = await NotificationService.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _requestNotificationPermissions() async {
    final granted = await NotificationService.requestNotificationPermissions();
    setState(() {
      _notificationsEnabled = granted;
    });
    
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification permissions are required for scheduling notifications'),
          backgroundColor: ColorManager.error,
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              // You can open app settings here if needed
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
        backgroundColor: ColorManager.primary,
        foregroundColor: ColorManager.white,
        actions: [
          if (!_notificationsEnabled)
            IconButton(
              icon: Icon(Icons.notifications_off),
              onPressed: _requestNotificationPermissions,
              tooltip: 'Enable Notifications',
            ),
        ],
      ),
      body: StreamBuilder<FlowState>(
        stream: _viewModel.outputState,
        builder: (context, snapshot) {
          return snapshot.data?.getScreenWidget(context, _getContentWidget(),
                  () {
                _viewModel.inputState.add(ContentState());
              }) ??
              _getContentWidget();
        },
      ),
    );
  }

  Widget _getContentWidget() {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p20),
      color: ColorManager.black,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_notificationsEnabled) _buildPermissionWarning(),
            _buildMessageSection(),
            const SizedBox(height: AppSize.s20),
            _buildDateTimeSection(),
            const SizedBox(height: AppSize.s30),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Card(
      color: ColorManager.error.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: ColorManager.error,
              size: AppSize.s24,
            ),
            const SizedBox(width: AppSize.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications Disabled',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: ColorManager.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    'Enable notifications to receive scheduled movie suggestions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ColorManager.white.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _requestNotificationPermissions,
              child: Text(
                'Enable',
                style: TextStyle(color: ColorManager.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSection() {
    return Card(
      color: ColorManager.genreBg,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.message,
                  color: ColorManager.primary,
                  size: AppSize.s24,
                ),
                const SizedBox(width: AppSize.s8),
                Text(
                  'Notification Message',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSize.s12),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: TextStyle(color: ColorManager.white),
              decoration: InputDecoration(
                hintText: 'Enter your movie suggestion notification...',
                hintStyle: TextStyle(color: ColorManager.cardColor),
                filled: true,
                fillColor: ColorManager.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.s8),
                  borderSide: BorderSide(color: ColorManager.primary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.s8),
                  borderSide: BorderSide(color: ColorManager.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      color: ColorManager.genreBg,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: ColorManager.primary,
                  size: AppSize.s24,
                ),
                const SizedBox(width: AppSize.s8),
                Text(
                  'Schedule Notification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSize.s16),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeSelector(
                    icon: Icons.calendar_today,
                    text: _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select Date',
                    onTap: () => _selectDate(),
                  ),
                ),
                const SizedBox(width: AppSize.s12),
                Expanded(
                  child: _buildDateTimeSelector(
                    icon: Icons.access_time,
                    text: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    onTap: () => _selectTime(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.s8),
      child: Container(
        padding: const EdgeInsets.all(AppPadding.p12),
        decoration: BoxDecoration(
          color: ColorManager.black,
          borderRadius: BorderRadius.circular(AppSize.s8),
          border: Border.all(
            color: ColorManager.primary.withOpacity(0.3),
            width: AppSize.s1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: ColorManager.primary,
              size: AppSize.s18,
            ),
            const SizedBox(width: AppSize.s8),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorManager.white,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return StreamBuilder<bool>(
      stream: _viewModel.outputIsFormValid,
      builder: (context, snapshot) {
        final isFormValid = snapshot.data ?? false;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isFormValid ? () => _handleSendNotification() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primary,
              foregroundColor: ColorManager.white,
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s8),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, size: AppSize.s20),
                const SizedBox(width: AppSize.s8),
                Text(
                  'Send Notification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSendNotification() async {
    if (!_notificationsEnabled) {
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: ColorManager.genreBg,
          title: Text(
            'Enable Notifications',
            style: TextStyle(color: ColorManager.white),
          ),
          content: Text(
            'Notifications are disabled. Would you like to enable them to receive your scheduled movie suggestions?',
            style: TextStyle(color: ColorManager.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Skip', style: TextStyle(color: ColorManager.cardColor)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Enable', style: TextStyle(color: ColorManager.primary)),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        await _requestNotificationPermissions();
      }
    }

    await _viewModel.sendNotification();
  }

  Future<void> _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: ColorManager.primary,
              surface: ColorManager.genreBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _updateDateTime();
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: ColorManager.primary,
              surface: ColorManager.genreBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
        _updateDateTime();
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _messageController.dispose();
    super.dispose();
  }
}