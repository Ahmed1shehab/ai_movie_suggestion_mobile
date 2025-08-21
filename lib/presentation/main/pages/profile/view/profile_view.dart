import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/view/pages/chat_history/chat_history_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/view/pages/contact_us/contact_us.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/view/pages/notifications/notification_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/view/pages/watchlist/view/watchlist_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/view/pages/change_password/change_password_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/viewmodel/profile_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';

import 'package:flutter/material.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewModel viewModel = instance<ProfileViewModel>();
  final AppPreferences _appPreferences = instance<AppPreferences>();

  @override
  void initState() {
    super.initState();
    // Start the ViewModel
    viewModel.start();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.secondaryBlack,
        title: Text(
          'Log Out',
          style: TextStyle(color: ColorManager.white),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: ColorManager.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: ColorManager.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: Text('Log Out', style: TextStyle(color: ColorManager.error)),
          ),
        ],
      ),
    );
  }

  void _performLogout() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorManager.white),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Logging out...'),
            ],
          ),
          backgroundColor: ColorManager.primary,
          duration: const Duration(seconds: 1),
        ),
      );

      // Clear all app preferences data
      await _clearAllAppData();

      // Navigate to login/onboarding screen and clear navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.loginRoute, // Replace with your login route
        (route) => false, // This removes all previous routes
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully logged out'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: $e'),
          backgroundColor: ColorManager.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _clearAllAppData() async {
    try {
      // Clear authentication token
      await _appPreferences.deleteAccessToken();

      // Clear user login status
      await _appPreferences.performCompleteLogout();

      // Clear registration email
      await _appPreferences.removeRegisterEmail();

      // Clear remember me data
      await _appPreferences.clearRememberMe();

      // Clear watchlist data
      await _appPreferences.clearWatchlist();

      // Clear liked movies data
      await _appPreferences.clearLikedMovies();

      // Clear chat history
      await _appPreferences.clearChatHistory();

      // Optional: Clear language preference (uncomment if you want to reset language)
      // await _appPreferences._sharedPreferences.remove('PREFS_KEY_LANG');

      // Optional: Clear onboarding status (uncomment if you want user to see onboarding again)
      // await _appPreferences._sharedPreferences.remove('PREFS_KEY_ONBOARDING_SCREEN_VIEWED');

      print('All app data cleared successfully');
    } catch (e) {
      print('Error clearing app data: $e');
      rethrow;
    }
  }

 void _navigateToWatchlist() async {
    try {
      // Initialize modules before navigation
      initWatchlistModule();
      initMovieDetailsModule();
      
      // Add a small delay to ensure modules are properly initialized
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        await Navigator.pushNamed(
          context,
          Routes.watchListRoute,
        );
      }
    } catch (e) {
      print('Error navigating to watchlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error opening watchlist. Please try again.'),
            backgroundColor: ColorManager.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _refreshProfile() {
    viewModel.inputRefreshProfile.add(null);
  }

  void _navigateToPage(String pageName, UserProfileModel? profileData) {
    Widget? targetPage;

    switch (pageName) {
      case 'Watchlist':
        _navigateToWatchlist();
        return;
      case 'Chat History':
        targetPage = ChatHistoryView(
          chatHistory: profileData?.chatHistory ?? <ChatHistoryModel>[],
        );
        break;
      case 'Notifications':
        targetPage = NotificationView(
          notifications: profileData?.notifications ?? <NotificationEntity>[],
        );
        break;
      case 'Change Password':
        targetPage = const ChangePasswordView();
        break;
      case 'Contact Us':
        targetPage = const ContactUsView();
        break;
      case 'Log Out':
        _showLogoutDialog();
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$pageName - Coming Soon'),
            backgroundColor: ColorManager.primary,
          ),
        );
        return;
    }

    if (targetPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: StreamBuilder<FlowState>(
        stream: viewModel.outputState,
        builder: (context, stateSnapshot) {
          return stateSnapshot.data?.getScreenWidget(
                  context,
                  _getContentWidget(),
                  () => viewModel.inputLoadProfile.add(null)) ??
              _getContentWidget();
        },
      ),
    );
  }

  Widget _getContentWidget() {
    return StreamBuilder<UserProfileModel?>(
      stream: viewModel.outputProfileData,
      builder: (context, profileSnapshot) {
        final profileData = profileSnapshot.data;
        return _buildProfileContent(profileData);
      },
    );
  }

  Widget _buildProfileContent(UserProfileModel? profileData) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(color: ColorManager.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ColorManager.white),
            onPressed: _refreshProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // User Name - from API data
            Text(
              profileData?.user.fullName ?? 'Loading...',
              style: TextStyle(
                color: ColorManager.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              profileData?.user.email ?? 'Loading...',
              style: TextStyle(
                color: ColorManager.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            // Verification Badge
            if (profileData?.user.isVerified == true)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Stats Row - using real data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                    '${profileData?.likes.length ?? 0}', 'Liked Movies'),
                _buildStatColumn(
                    '${profileData?.chatHistory.length ?? 0}', 'Conversations'),
                _buildStatColumn('${profileData?.notifications.length ?? 0}',
                    'Notifications'),
              ],
            ),

            const SizedBox(height: 20),

            // Credits Display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: ColorManager.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Credits',
                          style: TextStyle(
                            color: ColorManager.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${profileData?.credits ?? 0}',
                          style: TextStyle(
                            color: ColorManager.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.chat_bubble_outline,
                    'Chat History',
                    'View your ${profileData?.chatHistory.length ?? 0} conversations',
                    () => _navigateToPage('Chat History', profileData),
                  ),
                  _buildMenuItem(
                    Icons.notifications_outlined,
                    'Notifications',
                    '${profileData?.notifications.length ?? 0} notifications',
                    () => _navigateToPage('Notifications', profileData),
                  ),
                  _buildMenuItem(
                    Icons.bookmark_outline,
                    'Watchlist',
                    'Review your watchlist',
                    () => _navigateToPage('Watchlist', profileData),
                  ),
                  _buildMenuItem(
                    Icons.lock_outline,
                    'Change Password',
                    'Update your account password',
                    () => _navigateToPage('Change Password', profileData),
                  ),
                  _buildMenuItem(
                    Icons.help_outline,
                    'Contact Us',
                    'Get help and support',
                    () => _navigateToPage('Contact Us', profileData),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    Icons.logout,
                    'Log Out',
                    'Sign out of your account',
                    () => _navigateToPage('Log Out', profileData),
                    isLogout: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            color: ColorManager.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: ColorManager.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLogout
                  ? ColorManager.error.withOpacity(0.1)
                  : ColorManager.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLogout
                    ? ColorManager.error.withOpacity(0.3)
                    : ColorManager.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLogout
                        ? ColorManager.error.withOpacity(0.2)
                        : ColorManager.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? ColorManager.error : ColorManager.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isLogout
                              ? ColorManager.error
                              : ColorManager.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: ColorManager.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isLogout ? ColorManager.error : ColorManager.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Only dispose viewModel if needed
    super.dispose();
  }
}
