import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';
import 'package:ai_movie_suggestion/presentation/common/utils/size_config.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/suggest_me/viewmodel/suggest_me_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/styles_manager.dart';
import 'package:lottie/lottie.dart';

class SuggestMeView extends StatefulWidget {
  const SuggestMeView({Key? key}) : super(key: key);

  @override
  _SuggestMeViewState createState() => _SuggestMeViewState();
}

class _SuggestMeViewState extends State<SuggestMeView> {
  final SuggestMeViewmodel _viewModel = instance<SuggestMeViewmodel>();
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isThinking = false;

  // Predefined quick suggestions
  final List<String> _quickSuggestions = [
    AppStrings.sciFi,
    AppStrings.comedy,
    AppStrings.thriller,
    AppStrings.romance,
    AppStrings.action,
  ];

  @override
  void initState() {
    bind();
    _initializeChat();
    super.initState();
  }

  bind() {
    _viewModel.start();
  }

  void _initializeChat() {
    _messages.add(ChatMessage(
      text: AppStrings.initialPrompt,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _promptController.dispose();
    _promptFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.scaleWidth(AppPadding.p16)),
            child: Container(
              height: SizeConfig.scaleHeight(AppSize.s34),
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical: AppPadding.p6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primary.withOpacity(0.15),
                    ColorManager.primary.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSize.s20),
                border: Border.all(
                  color: ColorManager.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.asset(
                      ImagesAssets.appLogo,
                      height: AppSize.s20,
                      width: AppSize.s20,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSize.s8),
                  Text(
                    AppStrings.aiPowered,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ColorManager.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: FontSize.s13,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
        title: Text(
          AppStrings.suggestMe,
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: ColorManager.white,
              ),
        ),
        backgroundColor: ColorManager.background,
        elevation: AppSize.s0,
      ),
      backgroundColor: ColorManager.background,
      body: StreamBuilder<FlowState>(
        stream: _viewModel.outputState,
        builder: (context, snapshot) {
          return _getContentWidget();
        },
      ),
    );
  }

  Widget _getContentWidget() {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside the text field
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // Chat messages
          Expanded(
            child: _getChatSection(),
          ),
          _getPromptInputSection(),
        ],
      ),
    );
  }

  Widget _getChatSection() {
    return StreamBuilder<MovieDetail?>(
      stream: _viewModel.outMovieDetail,
      builder: (context, movieSnapshot) {
        if (movieSnapshot.hasData && movieSnapshot.data != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isThinking) {
              setState(() {
                _isThinking = false;
                _messages.add(ChatMessage(
                  text: AppStrings.defaultPrompt,
                  isUser: false,
                  timestamp: DateTime.now(),
                  movieDetail: movieSnapshot.data,
                ));
              });
              _scrollToBottom();
            }
          });
        }

        return StreamBuilder<String?>(
          stream: _viewModel.outErrorResponse,
          builder: (context, errorSnapshot) {
            if (errorSnapshot.hasData &&
                errorSnapshot.data != null &&
                errorSnapshot.data!.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_isThinking) {
                  setState(() {
                    _isThinking = false;
                    _messages.add(ChatMessage(
                      text: errorSnapshot.data!,
                      isUser: false,
                      timestamp: DateTime.now(),
                      isError: true,
                    ));
                  });
                  _scrollToBottom();
                }
              });
            }

            return StreamBuilder<bool>(
              stream: _viewModel.outIsLoading,
              builder: (context, loadingSnapshot) {
                bool isLoading = loadingSnapshot.data ?? false;

                if (isLoading && !_isThinking) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _isThinking = true;
                    });
                  });
                }

                return Container(
                  padding: const EdgeInsets.all(AppPadding.p16),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length + (_isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_messages.length == 1 && index == 0) {
                        return _getInitialPromptAndSuggestions();
                      }

                      if (_isThinking && index == _messages.length) {
                        return _getThinkingBubble();
                      }

                      return _getChatBubble(_messages[index]);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _getChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: AppSize.s36,
              height: AppSize.s36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: message.isError ?? false
                    ? ColorManager.error.withOpacity(0.15)
                    : ColorManager.white,
                border: Border.all(
                  color: message.isError ?? false
                      ? ColorManager.error
                      : ColorManager.primary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (message.isError ?? false
                            ? ColorManager.error
                            : ColorManager.primary)
                        .withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isError ?? false
                  ? Icon(
                      Icons.error_outline,
                      color: ColorManager.error,
                      size: AppSize.s20,
                    )
                  : ClipOval(
                      child: Image.asset(
                        ImagesAssets.appLogo,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: AppSize.s10),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p14,
                vertical: AppPadding.p12,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? ColorManager.primary
                    : (message.isError ?? false)
                        ? ColorManager.error.withOpacity(0.15)
                        : ColorManager.secondaryBlack,
                borderRadius: message.isUser
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(AppSize.s18),
                        topRight: Radius.circular(AppSize.s18),
                        bottomLeft: Radius.circular(AppSize.s18),
                        bottomRight: Radius.circular(AppSize.s4),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(AppSize.s4),
                        topRight: Radius.circular(AppSize.s18),
                        bottomLeft: Radius.circular(AppSize.s18),
                        bottomRight: Radius.circular(AppSize.s18),
                      ),
                border: message.isUser
                    ? null
                    : Border.all(
                        color: (message.isError ?? false)
                            ? ColorManager.error.withOpacity(0.3)
                            : ColorManager.greyfield.withOpacity(0.2),
                        width: 1,
                      ),
                boxShadow: message.isUser
                    ? [
                        BoxShadow(
                          color: ColorManager.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: getRegularStyle(
                      color: message.isUser
                          ? ColorManager.white
                          : (message.isError ?? false)
                              ? ColorManager.error
                              : ColorManager.white,
                      fontSize: FontSize.s14,
                    ),
                  ),
                  if (message.movieDetail != null) ...[
                    const SizedBox(height: AppSize.s12),
                    _getMovieCard(message.movieDetail!),
                  ],
                  const SizedBox(height: AppSize.s4),
                  Text(
                    _formatTime(message.timestamp),
                    style: getRegularStyle(
                      color: message.isUser
                          ? ColorManager.white.withOpacity(0.8)
                          : ColorManager.grey,
                      fontSize: FontSize.s10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppSize.s10),
            Container(
              width: AppSize.s36,
              height: AppSize.s36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primary,
                    ColorManager.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                color: ColorManager.white,
                size: AppSize.s20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.s36,
            height: AppSize.s36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorManager.white,
              border: Border.all(
                color: ColorManager.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                ImagesAssets.appLogo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSize.s10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p14,
                vertical: AppPadding.p8,
              ),
              decoration: BoxDecoration(
                color: ColorManager.secondaryBlack,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSize.s4),
                  topRight: Radius.circular(AppSize.s18),
                  bottomLeft: Radius.circular(AppSize.s18),
                  bottomRight: Radius.circular(AppSize.s18),
                ),
                border: Border.all(
                  color: ColorManager.greyfield.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Lottie.asset(
                JsonAssets.loadingDots,
                width: AppSize.s60,
                height: AppSize.s30,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getInitialPromptAndSuggestions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.s36,
            height: AppSize.s36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorManager.white,
              border: Border.all(
                color: ColorManager.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                ImagesAssets.appLogo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSize.s10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p14,
                vertical: AppPadding.p14,
              ),
              decoration: BoxDecoration(
                color: ColorManager.secondaryBlack,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSize.s4),
                  topRight: Radius.circular(AppSize.s18),
                  bottomLeft: Radius.circular(AppSize.s18),
                  bottomRight: Radius.circular(AppSize.s18),
                ),
                border: Border.all(
                  color: ColorManager.greyfield.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.initialPrompt,
                    style: getRegularStyle(
                      color: ColorManager.white,
                      fontSize: FontSize.s14,
                    ),
                  ),
                  const SizedBox(height: AppSize.s12),
                  Wrap(
                    spacing: AppSize.s8,
                    runSpacing: AppSize.s8,
                    children: _quickSuggestions
                        .map((suggestion) => _getQuickSuggestionChip(suggestion))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getQuickSuggestionChip(String suggestion) {
    return GestureDetector(
      onTap: () => _sendQuickSuggestion(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p14,
          vertical: AppPadding.p8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorManager.primary.withOpacity(0.2),
              ColorManager.primary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSize.s20),
          border: Border.all(
            color: ColorManager.primary.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.primary.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          suggestion,
          style: getMediumStyle(
            color: ColorManager.white,
            fontSize: FontSize.s13,
          ),
        ),
      ),
    );
  }

  Widget _getMovieCard(MovieDetail movie) {
    return Container(
      margin: const EdgeInsets.only(top: AppSize.s8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.s12),
        color: ColorManager.white,
        boxShadow: [
          BoxShadow(
            color: ColorManager.secondaryPrimary,
            blurRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie backdrop/poster
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSize.s12),
              topRight: Radius.circular(AppSize.s12),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                movie.backdropUrl.isNotEmpty
                    ? movie.backdropUrl
                    : movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: ColorManager.greyfield,
                    child: Icon(
                      Icons.movie,
                      size: AppSize.s40,
                      color: ColorManager.genreBg,
                    ),
                  );
                },
              ),
            ),
          ),
          // Movie details
          Padding(
            padding: const EdgeInsets.all(AppPadding.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and year
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        movie.title,
                        style: getBoldStyle(
                          color: ColorManager.black,
                          fontSize: FontSize.s16,
                        ),
                      ),
                    ),
                    if (movie.year.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p6,
                          vertical: AppPadding.p2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.buttonForChat,
                          borderRadius: BorderRadius.circular(AppSize.s8),
                        ),
                        child: Text(
                          movie.year,
                          style: getMediumStyle(
                            color: ColorManager.white,
                            fontSize: FontSize.s10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSize.s8),
                // Rating and runtime
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: AppSize.s14,
                    ),
                    const SizedBox(width: AppSize.s4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: getMediumStyle(
                        color: ColorManager.genreBg,
                        fontSize: FontSize.s12,
                      ),
                    ),
                    const SizedBox(width: AppSize.s16),
                    Icon(
                      Icons.access_time,
                      color: ColorManager.genreBg,
                      size: AppSize.s14,
                    ),
                    const SizedBox(width: AppSize.s4),
                    Text(
                      movie.runtimeFormatted.isNotEmpty
                          ? movie.runtimeFormatted
                          : '${movie.runtime}min',
                      style: getMediumStyle(
                        color: ColorManager.genreBg,
                        fontSize: FontSize.s12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.s8),
                // Genres
                if (movie.genres.isNotEmpty)
                  Wrap(
                    spacing: AppSize.s4,
                    runSpacing: AppSize.s4,
                    children: movie.genres
                        .take(3)
                        .map((genre) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p6,
                                vertical: AppPadding.p2,
                              ),
                              decoration: BoxDecoration(
                                color: ColorManager.cardColor,
                                borderRadius:
                                    BorderRadius.circular(AppSize.s12),
                              ),
                              child: Text(
                                genre.name,
                                style: getRegularStyle(
                                  color: ColorManager.primary,
                                  fontSize: FontSize.s10,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: AppSize.s8),
                // Overview (truncated)
                if (movie.overview.isNotEmpty)
                  Text(
                    movie.overview.length > 100
                        ? '${movie.overview.substring(0, 100)}...'
                        : movie.overview,
                    style: getRegularStyle(
                      color: ColorManager.genreBg,
                      fontSize: FontSize.s12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: AppSize.s12),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _viewModel.launchMovieUrl(movie.homepage),
                        icon: const Icon(Icons.play_arrow, size: AppSize.s20),
                        label: const Text(AppStrings.watchNow),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.buttonForChat,
                          foregroundColor: ColorManager.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSize.s14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.s12),
                          ),
                          elevation: 4,
                          shadowColor: ColorManager.buttonForChat,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.s16),
                    Expanded(
                      flex: 1,
                      child: StreamBuilder<bool>(
                        stream: _viewModel.outputIsInWatchlist,
                        builder: (context, snapshot) {
                          final isInWatchlist = snapshot.data ?? false;
                          return ElevatedButton(
                            onPressed: () => _viewModel.toggleWatchlist(movie),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInWatchlist
                                  ? ColorManager.error
                                  : ColorManager.white,
                              foregroundColor: isInWatchlist
                                  ? ColorManager.white
                                  : ColorManager.aiText,
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSize.s14),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSize.s12),
                              ),
                              elevation: 4,
                              shadowColor: isInWatchlist
                                  ? ColorManager.error
                                  : ColorManager.white,
                            ),
                            child: Icon(
                              isInWatchlist ? Icons.remove : Icons.add,
                              size: AppSize.s20,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPromptInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p16,
        vertical: AppPadding.p12,
      ),
      decoration: BoxDecoration(
        color: ColorManager.secondaryBlack,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(AppSize.s28),
          border: Border.all(
            color: ColorManager.greyfield.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: _promptController,
          focusNode: _promptFocusNode,
          style: TextStyle(
            color: ColorManager.black,
            fontSize: FontSize.s14,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.enterYourPrompt,
            hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: ColorManager.greyfield,
                  fontSize: FontSize.s14,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.s28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.s28),
              borderSide: BorderSide(
                color: ColorManager.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.s28),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p20,
              vertical: AppPadding.p14,
            ),
            filled: true,
            fillColor: ColorManager.white,
            suffixIcon: Container(
              margin: const EdgeInsets.all(AppPadding.p6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorManager.primary,
                    ColorManager.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: ColorManager.white,
                  size: AppSize.s20,
                ),
                onPressed: _sendPrompt,
              ),
            ),
          ),
          maxLines: 1,
          textInputAction: TextInputAction.send,
          onFieldSubmitted: (value) => _sendPrompt(),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else {
      return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    }
  }

  void _sendPrompt() {
    String prompt = _promptController.text.trim();
    if (prompt.isNotEmpty && !_isThinking) {
      setState(() {
        _messages.add(ChatMessage(
          text: prompt,
          isUser: true,
          timestamp: DateTime.now(),
        ));
      });

      _promptController.clear();
      _promptFocusNode.unfocus();
      _viewModel.sendPrompt(prompt);
      _scrollToBottom();
    }
  }

  void _sendQuickSuggestion(String suggestion) {
    if (!_isThinking) {
      setState(() {
        _messages.add(ChatMessage(
          text: suggestion,
          isUser: true,
          timestamp: DateTime.now(),
        ));
      });

      _viewModel.sendPrompt(suggestion);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
