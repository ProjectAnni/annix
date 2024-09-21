import 'package:annix/providers.dart';
import 'package:annix/services/logger.dart';
import 'package:annix/ui/dialogs/loading.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:go_router/go_router.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';

class AnnixIntroductionPage extends StatelessWidget {
  final String heading;
  final String description;
  final Widget? suffix;
  final String? asset;
  final bool card;
  final Color? color;

  const AnnixIntroductionPage({
    super.key,
    required this.heading,
    required this.description,
    this.suffix,
    this.asset,
    this.card = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final image = asset != null
        ? Container(
            child: card
                ? Card(
                    color: color,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox.square(
                        dimension: 280,
                        child: Image.asset(
                          asset!,
                          colorBlendMode: BlendMode.srcOver,
                        ),
                      ),
                    ),
                  )
                : SizedBox.square(
                    dimension: 200,
                    child: Image.asset(
                      asset!,
                      colorBlendMode: BlendMode.srcOver,
                    ),
                  ),
          )
        : null;
    final titleWidget = Container(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      alignment: Alignment.topLeft,
      child: Text(
        heading,
        style: context.textTheme.headlineLarge?.copyWith(
          color: context.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    final bodyWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSecondaryContainer,
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 60),
      child: Column(
        children: [
          if (image != null)
            Flexible(
              flex: 4,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: image,
              ),
            ),
          const Spacer(),
          Flexible(
            flex: image == null ? 5 : 2,
            child: Column(
              children: [
                titleWidget,
                bodyWidget,
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Divider(
              color: context.colorScheme.onSecondaryContainer
                  .withValues(alpha: 0.3),
              height: 0,
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}

final _introKey = GlobalKey<IntroductionScreenState>();

class IntroPage extends HookConsumerWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final selfHost = useState(false);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final serverController = useTextEditingController();
    useListenable(emailController);
    useListenable(passwordController);
    useListenable(serverController);

    return IntroductionScreen(
      safeAreaList: const [false, false, false, false],
      key: _introKey,
      globalBackgroundColor: context.colorScheme.secondaryContainer,
      curve: Curves.easeInOut,
      animationDuration: 150,
      resizeToAvoidBottomInset: false,
      rawPages: [
        AnnixIntroductionPage(
          heading: t.intro.welcome.heading,
          description: t.intro.welcome.description,
          asset: 'assets/icon.png',
          card: false,
        ),
        AnnixIntroductionPage(
          heading: t.intro.enjoy_music.heading,
          description: t.intro.enjoy_music.description,
          asset: 'assets/intro/listen.png',
          color: Colors.white,
        ),
        AnnixIntroductionPage(
          heading: t.intro.host_remotely.heading,
          description: t.intro.host_remotely.description,
          asset: 'assets/intro/cloud.png',
        ),
        AnnixIntroductionPage(
          heading: t.intro.fully_featured.heading,
          description: t.intro.fully_featured.description,
          asset: 'assets/intro/everything.png',
        ),
        AutofillGroup(
          child: AnnixIntroductionPage(
            heading: t.intro.login.heading,
            description: t.intro.login.description,
            suffix: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(labelText: t.intro.login.email),
                  controller: emailController,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: t.intro.login.password),
                  controller: passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 24),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    value: selfHost.value,
                    onChanged: (v) => selfHost.value = v ?? false,
                    title: Text(
                      t.intro.login.self_host,
                      style: context.textTheme.labelLarge,
                    ),
                    secondary: IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(t.intro.about_anniv.heading),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Linkify(
                                      text: t.intro.about_anniv.ribbon_features,
                                    ),
                                    Linkify(
                                      text:
                                          t.intro.about_anniv.how_to_self_host,
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(t.intro.about_anniv.confirm),
                                  onPressed: () => context.pop(),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                if (selfHost.value)
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: t.intro.login.server),
                    controller: serverController,
                    autofillHints: const [AutofillHints.url],
                  ),
              ],
            ),
          ),
        ),
      ],
      skipOrBackFlex: 0,
      controlsPadding: const EdgeInsets.only(bottom: 8),
      customProgress: (position, totalPages) => Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: DotsIndicator(
          dotsCount: totalPages,
          position: position,
          decorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            color: context.theme.colorScheme.secondary,
            activeColor: context.theme.colorScheme.primary,
            activeSize: const Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
        ),
      ),
      overrideNext: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.comfortable,
            ),
            onPressed: () => _introKey.currentState?.skipToEnd(),
            child: Text(t.intro.action.skip),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.comfortable,
            ),
            onPressed: () => _introKey.currentState?.next(),
            child: Text(t.intro.action.next),
          ),
          const SizedBox(width: 24),
        ],
      ),
      overrideDone: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: FilledButton(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.comfortable,
              ),
              onPressed: (emailController.value.text.isNotEmpty &&
                          emailController.value.text.contains('@')) &&
                      passwordController.value.text.isNotEmpty &&
                      (!selfHost.value || serverController.text.isNotEmpty)
                  ? () async {
                      final anniv = ref.read(annivProvider);
                      final delegate = ref.read(goRouterProvider);

                      String url = serverController.text;
                      final email = emailController.text;
                      final password = passwordController.text;

                      if (url.isEmpty) {
                        url = 'https://ribbon.anni.rs';
                      }
                      if (!url.startsWith('http://') &&
                          !url.startsWith('https://')) {
                        url = 'https://$url';
                      }

                      try {
                        showLoadingDialog(context);
                        await anniv.login(url, email.trim(), password);
                      } catch (e) {
                        Logger.error('Login failed', exception: e);
                        if (context.mounted) {
                          final snackBar =
                              SnackBar(content: Text(e.toString()));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      } finally {
                        // hide loading dialog
                        delegate.go('/');
                      }
                    }
                  : null,
              child: Text(t.intro.action.login),
            ),
          ),
        ],
      ),
    );
  }
}
