import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/app/functions.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/movie_detail/viewmodel/movie_detail_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/movie_detail/widget/horizontal_movie_grid.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/constants_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:ai_movie_suggestion/presentation/send_notifcations/viewmodel/send_notifications_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/send_notifcations/service/notification_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovieDetailsView extends StatefulWidget {
  final int movieId;
  final String routeName;
  const MovieDetailsView(
      {Key? key, required this.movieId, required this.routeName})
      : super(key: key);

  @override
  State<MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<MovieDetailsView>
    with TickerProviderStateMixin {
  late final MovieDetailsViewModel _viewModel;
  late final SendNotificationViewModel _notificationViewModel;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final TextEditingController _notificationMessageController;

  bool _isNotificationExpanded = false;
  bool _notificationsEnabled = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  MovieDetail? _currentMovie;

  final GlobalKey _notificationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _viewModel = instance<MovieDetailsViewModel>();
    _notificationViewModel = instance<SendNotificationViewModel>();
    _scrollController = ScrollController();
    _notificationMessageController = TextEditingController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: AppConstants.sliderAnimation),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _bind();
    _checkNotificationPermissions();
    debugPrint(AppStrings.movieDetailsViewInitState);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _notificationViewModel.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _notificationMessageController.dispose();
    super.dispose();
  }

  void _bind() {
    _viewModel.start();
    _notificationViewModel.start();

    // Set default date and time
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);

    // Listen for message changes
    _notificationMessageController.addListener(() {
      _notificationViewModel.setMessage(_notificationMessageController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getMovieDetails(widget.movieId);
    });
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
      _notificationViewModel.setDate(combinedDateTime);
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
          content: const Text(AppStrings.notificationPermissionRequired),
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

  void _updateNotificationMessage(String movieTitle) {
    final defaultMessage = "Reminder to watch $movieTitle";
    _notificationMessageController.text = defaultMessage;
    _notificationViewModel.setMessage(defaultMessage);
  }

  void _scrollToNotification() {
    final RenderObject? renderObject =
        _notificationKey.currentContext?.findRenderObject();
    if (renderObject != null) {
      final RenderBox renderBox = renderObject as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);

      _scrollController.animateTo(
        position.dy - AppSize.s100,
        duration: const Duration(milliseconds: AppConstants.sliderAnimation),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgMovie,
      body: Stack(
        children: [
          // Main content
          StreamBuilder<FlowState>(
            stream: _viewModel.outputState,
            builder: (context, snapshot) {
              return snapshot.data?.getScreenWidget(
                    context,
                    _buildContent(),
                    () => _viewModel.getMovieDetails(widget.movieId),
                  ) ??
                  _buildContent();
            },
          ),
          Positioned(
            top: AppSize.s10,
            left: AppSize.s5,
            child: SafeArea(
              child: IconButton(
                icon: Container(
                  height: AppSize.s40,
                  width: AppSize.s40,
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.black,
                        blurRadius: AppSize.s8,
                        spreadRadius: AppSize.s1,
                        offset: const Offset(AppSize.s2, AppSize.s2),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: ColorManager.white,
                    size: AppSize.s20,
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    widget.routeName,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<MovieDetail>(
      stream: _viewModel.outputMovieDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorManager.primary,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSize.s20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppSize.s60,
                    color: ColorManager.primary,
                  ),
                  const SizedBox(height: AppSize.s16),
                  Text(
                    '${AppStrings.error}: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ColorManager.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSize.s16),
                  ElevatedButton(
                    onPressed: () => _viewModel.getMovieDetails(widget.movieId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      foregroundColor: ColorManager.white,
                    ),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text(
              AppStrings.noMovieData,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ColorManager.white,
                  ),
            ),
          );
        }

        final movie = snapshot.data!;
        if (_currentMovie?.id != movie.id) {
          _currentMovie = movie;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateNotificationMessage(movie.title);
          });
        }

        return _buildMovieDetails(movie);
      },
    );
  }

  Widget _buildMovieDetails(MovieDetail movie) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeaderWithOverlay(movie),
          _buildMovieContent(movie),
        ],
      ),
    );
  }

  Widget _buildHeaderWithOverlay(MovieDetail movie) {
    return SizedBox(
      height: AppSize.s500,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: AppSize.s500,
            child: _buildNetworkImage(
              imageUrl: movie.backdropUrl,
              width: double.infinity,
              height: AppSize.s500,
              fit: BoxFit.cover,
              placeholder: Container(
                color: ColorManager.grey,
                child: const Center(
                    child: Icon(Icons.movie,
                        size: AppSize.s80, color: Colors.white54)),
              ),
            ),
          ),
          Container(
            height: AppSize.s500,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.6, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black26,
                  Colors.black87,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: AppSize.s20,
            right: AppSize.s20,
            left: AppSize.s20,
            child: _buildMovieInfoOverlay(movie),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieInfoOverlay(MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3.0,
                color: Colors.black,
              ),
            ],
          ),
          maxLines: AppSize.s2.toInt(),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSize.s8),
        Wrap(
          spacing: AppSize.s16,
          runSpacing: AppSize.s4,
          children: [
            if (movie.releaseDate != null)
              _buildInfoChip(
                  '${movie.releaseDate!.year}', Icons.calendar_today),
            _buildInfoChip(AppStrings.rating, Icons.star_rate_rounded),
            if (movie.runtime > AppSize.s0)
              _buildInfoChip(
                  '${movie.runtime} ${AppStrings.minutes}', Icons.access_time),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSize.s8, vertical: AppSize.s4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSize.s16,
            color: ColorManager.cardColor,
          ),
          const SizedBox(width: AppSize.s4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorManager.cardColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieContent(MovieDetail movie) {
    return Container(
      color: ColorManager.bgMovie,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGenresAndRating(movie),
            const SizedBox(height: AppSize.s18),
            if (movie.overview.isNotEmpty) _buildSynopsisSection(movie),
            const SizedBox(height: AppSize.s24),
            _buildActionButtons(movie),
            const SizedBox(height: AppSize.s24),
            _buildNotificationSchedulingSection(movie),
            const SizedBox(height: AppSize.s24),
            if (movie.productionCompanies.isNotEmpty)
              _buildCompaniesSection(movie),
            _buildAdditionalInfo(movie),
            _buildSimilarMoviesSection(),
            const SizedBox(height: AppSize.s24),
          ],
        ),
      ),
    );
  }

 Widget _buildNotificationSchedulingSection(MovieDetail movie) {
  return Column(
    key: _notificationKey,
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSize.s12),
          onTap: () {
            setState(() {
              _isNotificationExpanded = !_isNotificationExpanded;
            });
            if (_isNotificationExpanded) {
              _animationController.forward();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToNotification();
              });
            } else {
              _animationController.reverse();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: ColorManager.genreBg,
              borderRadius: BorderRadius.circular(AppSize.s12),
              border: Border.all(
                color: ColorManager.primary,
                width: AppSize.s1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Important: prevents infinite height
              children: [
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: ColorManager.primary,
                    size: AppSize.s24,
                  ),
                  title: Text(
                    AppStrings.scheduleReminder,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ColorManager.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    AppStrings.reminderMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ColorManager.cardColor,
                        ),
                  ),
                  trailing: Icon(
                    _isNotificationExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: ColorManager.primary,
                    size: AppSize.s24,
                  ),
                ),
                // Use SizeTransition instead of AnimatedBuilder for better constraint handling
                SizeTransition(
                  sizeFactor: _animation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSize.s16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_notificationsEnabled) _buildPermissionWarning(),
                        _buildNotificationMessageSection(),
                        const SizedBox(height: AppSize.s20),
                        _buildNotificationDateTimeSection(),
                        const SizedBox(height: AppSize.s20),
                        _buildScheduleNotificationButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildPermissionWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.s16),
      child: Card(
        color: ColorManager.error,
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
                      AppStrings.notificationsDisabled,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: ColorManager.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSize.s4),
                    Text(
                      AppStrings.enableNotification,
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
                  AppStrings.enable,
                  style: TextStyle(color: ColorManager.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationMessageSection() {
    return Card(
      color: ColorManager.background,
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
                  AppStrings.notificationMessgae,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColorManager.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSize.s12),
            TextField(
              controller: _notificationMessageController,
              maxLines: 1,
              style: TextStyle(color: ColorManager.white),
              decoration: InputDecoration(
                hintText: AppStrings.enterYourMovieReminderMessage,
                hintStyle: TextStyle(color: ColorManager.cardColor),
                filled: true,
                fillColor: ColorManager.genreBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.s8),
                  borderSide:
                      BorderSide(color: ColorManager.primary),
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

  Widget _buildNotificationDateTimeSection() {
    return Card(
      color: ColorManager.background,
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
                  AppStrings.scheduleReminder,
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
                        : AppStrings.selectDate,
                    onTap: () => _selectDate(),
                  ),
                ),
                const SizedBox(width: AppSize.s12),
                Expanded(
                  child: _buildDateTimeSelector(
                    icon: Icons.access_time,
                    text: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : AppStrings.selectTime,
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
          color: ColorManager.genreBg,
          borderRadius: BorderRadius.circular(AppSize.s8),
          border: Border.all(
            color: ColorManager.primary,
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

  Widget _buildScheduleNotificationButton() {
    return StreamBuilder<FlowState>(
      stream: _notificationViewModel.outputState,
      builder: (context, stateSnapshot) {
        return StreamBuilder<bool>(
          stream: _notificationViewModel.outputIsFormValid,
          builder: (context, validSnapshot) {
            final isFormValid = validSnapshot.data ?? false;
            final isLoading = stateSnapshot.data is LoadingState;

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isFormValid && !isLoading)
                    ? () => _handleScheduleNotification()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  foregroundColor: ColorManager.white,
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.p14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.s8),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? SizedBox(
                        height: AppSize.s20,
                        width: AppSize.s20,
                        child: CircularProgressIndicator(
                          color: ColorManager.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.schedule_send, size: AppSize.s20),
                          const SizedBox(width: AppSize.s8),
                          Text(
                            AppStrings.scheduleReminder,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
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
      },
    );
  }

  Future<void> _handleScheduleNotification() async {
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
            'Notifications are disabled. Would you like to enable them to receive your scheduled movie reminder?',
            style: TextStyle(color: ColorManager.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
                  Text('Skip', style: TextStyle(color: ColorManager.cardColor)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  Text('Enable', style: TextStyle(color: ColorManager.primary)),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        await _requestNotificationPermissions();
        if (!_notificationsEnabled) return;
      } else {
        return;
      }
    }

    // Update the view model with the current date/time
    _updateDateTime();

    // Send the notification
    await _notificationViewModel.sendNotification();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Movie reminder scheduled successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: ColorManager.white,
          onPressed: () {
            // Could navigate to notifications list
          },
        ),
      ),
    );

    // Collapse the notification section
    setState(() {
      _isNotificationExpanded = false;
    });
    _animationController.reverse();
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

  // Keep all the existing methods from the original MovieDetailsView
  Widget _buildGenresAndRating(MovieDetail movie) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: movie.genres.take(AppSize.s3.toInt()).map((genre) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSize.s8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.s12, vertical: AppSize.s6),
                  decoration: BoxDecoration(
                    color: ColorManager.genreBg,
                    borderRadius: BorderRadius.circular(AppSize.s20),
                    border: Border.all(
                      color: ColorManager.primary,
                      width: AppSize.s1,
                    ),
                  ),
                  child: Text(
                    genre.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ColorManager.cardColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: AppSize.s8),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSize.s12, vertical: AppSize.s6),
          decoration: BoxDecoration(
            color: ColorManager.star,
            borderRadius: BorderRadius.circular(AppSize.s16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rate_rounded,
                  color: ColorManager.white, size: AppSize.s20),
              const SizedBox(width: AppSize.s4),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: FontSize.s14,
                      color: ColorManager.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarMoviesSection() {
    return StreamBuilder<List<MovieEntity>>(
      stream: _viewModel.outputSimilarMovies,
      builder: (context, snapshot) {
        final movies = snapshot.data ?? [];

        return StreamBuilder<bool>(
          stream: _viewModel.outputSimilarMoviesLoading,
          builder: (context, loadingSnapshot) {
            final isLoading = loadingSnapshot.data ?? false;
            if (movies.isEmpty && !isLoading) {
              return const SizedBox.shrink();
            }
            return HorizontalMoviesGrid.similarMovies(
              movies: movies,
              isLoading: isLoading,
              onMovieTap: _navigateToMovieDetails,
            );
          },
        );
      },
    );
  }

  void _navigateToMovieDetails(MovieEntity movie) {
    Navigator.pushReplacementNamed(
      context,
      Routes.movieDetailsRoute,
      arguments: MovieDetailsArguments(
        movieId: movie.id,
        routeName: Routes.mainRoute,
      ),
    );
  }

  Widget _buildSynopsisSection(MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.synopsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ColorManager.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSize.s8),
        Text(
          movie.overview,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ColorManager.cardColor,
                height: AppSize.s1_5,
                letterSpacing: 0.5,
              ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildActionButtons(MovieDetail movie) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _viewModel.launchMovieUrl(movie.homepage),
            icon: const Icon(Icons.play_arrow, size: AppSize.s20),
            label: const Text(AppStrings.watchNow),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primary,
              foregroundColor: ColorManager.white,
              padding: const EdgeInsets.symmetric(vertical: AppSize.s14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s12),
              ),
              elevation: 4,
              shadowColor: ColorManager.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSize.s16),
        Expanded(
          child: StreamBuilder<bool>(
            stream: _viewModel.outputIsInWatchlist,
            builder: (context, snapshot) {
              final isInWatchlist = snapshot.data ?? false;
              return ElevatedButton.icon(
                onPressed: () => _viewModel.toggleWatchlist(movie),
                icon: Icon(
                  isInWatchlist ? Icons.check : Icons.add,
                  size: AppSize.s20,
                ),
                label: Text(isInWatchlist
                    ? AppStrings.inWatchlist
                    : AppStrings.addToWatchlist),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isInWatchlist ? Colors.green : ColorManager.primary,
                  foregroundColor: ColorManager.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSize.s14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.s12),
                  ),
                  elevation: 4,
                  shadowColor:
                      (isInWatchlist ? Colors.green : ColorManager.primary)
                          ,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompaniesSection(MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.productionCompanies,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorManager.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSize.s12),
        SizedBox(
          height: AppSize.s100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movie.productionCompanies.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSize.s16),
            itemBuilder: (context, index) {
              final company = movie.productionCompanies[index];
              return Container(
                width: AppSize.s80,
                padding: const EdgeInsets.all(AppSize.s8),
                decoration: BoxDecoration(
                  color: ColorManager.genreBg,
                  borderRadius: BorderRadius.circular(AppSize.s8),
                  border: Border.all(
                    color: ColorManager.primary,
                    width: AppSize.s1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNetworkImage(
                      imageUrl: company.logoUrl,
                      width: AppSize.s50,
                      height: AppSize.s40,
                      fit: BoxFit.contain,
                      placeholder: Container(
                        width: AppSize.s50,
                        height: AppSize.s40,
                        color: Colors.transparent,
                        child: Icon(
                          Icons.business,
                          size: AppSize.s20,
                          color: ColorManager.cardColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.s8),
                    Flexible(
                      child: Text(
                        company.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ColorManager.cardColor,
                              fontSize: AppSize.s10,
                            ),
                        maxLines: AppSize.s2.toInt(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSize.s24),
      ],
    );
  }

  Widget _buildAdditionalInfo(MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movie.budget > 0 || movie.revenue > 0) ...[
          Text(
            'Financial Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSize.s12),
        ],
        if (movie.budget > 0) ...[
          _buildInfoRow(
            '${AppStrings.budget}:',
            "${_formatCurrency(movie.budget.toDouble())}",
            Icons.attach_money,
          ),
          const SizedBox(height: AppSize.s8),
        ],
        if (movie.revenue > 0) ...[
          _buildInfoRow(
            '${AppStrings.revenue}:',
            '${_formatCurrency(movie.revenue.toDouble())}',
            Icons.trending_up,
          ),
          const SizedBox(height: AppSize.s8),
        ],
        if (movie.budget > 0 && movie.revenue > 0) ...[
          _buildInfoRow(
            'Profit:',
            '${_formatCurrency((movie.revenue - movie.budget).toDouble())}',
            Icons.account_balance_wallet,
            color:
                (movie.revenue - movie.budget) > 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: AppSize.s16),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(AppSize.s12),
      decoration: BoxDecoration(
        color: ColorManager.genreBg,
        borderRadius: BorderRadius.circular(AppSize.s8),
        border: Border.all(
          color: ColorManager.primary,
          width: AppSize.s1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? ColorManager.primary,
            size: AppSize.s20,
          ),
          const SizedBox(width: AppSize.s12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorManager.cardColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: AppSize.s8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color ?? ColorManager.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount.isNaN || amount.isInfinite || amount < 0) {
      return '0';
    }

    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 1,
    );

    if (amount >= 1000000000) {
      return '${formatter.format(amount / 1000000000)}B';
    } else if (amount >= 1000000) {
      return '${formatter.format(amount / 1000000)}M';
    } else if (amount >= 1000) {
      return '${formatter.format(amount / 1000)}K';
    } else {
      return NumberFormat.currency(
        symbol: '',
        decimalDigits: 0,
      ).format(amount);
    }
  }



  Widget _buildNetworkImage({
    required String? imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.fitHeight,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (!isValidUrl(imageUrl)) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: ColorManager.grey,
              borderRadius: BorderRadius.circular(AppSize.s8),
            ),
            child: Icon(
              Icons.image_not_supported,
              color: ColorManager.cardColor,
              size: width * 0.3,
            ),
          );
    }

    int? memCacheWidth;
    int? memCacheHeight;

    try {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      if (width.isFinite && devicePixelRatio.isFinite && width > 0) {
        memCacheWidth = (width * devicePixelRatio).round();
      }
      if (height.isFinite && devicePixelRatio.isFinite && height > 0) {
        memCacheHeight = (height * devicePixelRatio).round();
      }
    } catch (e) {
      debugPrint('Error calculating cache dimensions: $e');
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.s8),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: ColorManager.grey,
                borderRadius: BorderRadius.circular(AppSize.s8),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: ColorManager.primary,
                  strokeWidth: 2.0,
                ),
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: ColorManager.grey,
                borderRadius: BorderRadius.circular(AppSize.s8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: ColorManager.cardColor,
                    size: width * 0.2,
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    AppStrings.imageNotAvailable,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ColorManager.cardColor,
                          fontSize: AppSize.s10,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
