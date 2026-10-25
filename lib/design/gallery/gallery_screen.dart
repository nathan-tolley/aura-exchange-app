import 'package:flutter/widgets.dart';

import '../tokens.dart';
import '../widgets/aura_nav_card.dart';
import '../widgets/aura_section_header.dart';
import 'component_states.dart';
import 'screen_states.dart';

/// One state of a component, built with fixture data.
class GalleryState {
  const GalleryState(this.label, this.build);

  /// What this state is: "Disabled, inside a sheet".
  final String label;
  final WidgetBuilder build;
}

/// A component and every state it supports.
class GallerySection {
  const GallerySection(this.name, this.states);

  final String name;
  final List<GalleryState> states;
}

/// The State Gallery: every component in every state, with fixtures. A
/// debug-only route (`/gallery`, or `aura://gallery` on the phone). Screens
/// and their states join it as they're built (CLAUDE.md → Every state
/// exists).
class AuraGalleryScreen extends StatelessWidget {
  const AuraGalleryScreen({super.key, this.sections, this.onOpenScreen});

  /// Defaults to every component.
  final List<GallerySection>? sections;

  /// Opens a screen state full size (`/gallery/screens/W09`). Without it the
  /// gallery lists components only.
  final ValueChanged<String>? onOpenScreen;

  @override
  Widget build(BuildContext context) {
    final all = sections ?? componentStates;
    return ColoredBox(
      color: AuraColors.bg,
      child: SafeArea(
        bottom: false,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: all.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const Text('State Gallery', style: AuraType.title),
                    Text(
                      '${all.length} components · debug builds only',
                      style: AuraType.footnote.copyWith(
                        color: AuraColors.inkTertiary,
                      ),
                    ),
                    if (onOpenScreen case final open?) ...[
                      const SizedBox(height: 24),
                      const AuraSectionHeader('Screens'),
                      const SizedBox(height: 4),
                      AuraNavCard(
                        children: [
                          for (final screen in screenStates)
                            AuraNavRow(
                              title: '${screen.id} · ${screen.label}',
                              onTap: () => open(screen.id),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }
            return _Section(all[i - 1]);
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.section);

  final GallerySection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          AuraSectionHeader(section.name),
          for (final state in section.states)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  state.label,
                  style: AuraType.footnote.copyWith(
                    color: AuraColors.inkTertiary,
                  ),
                ),
                Builder(builder: state.build),
              ],
            ),
        ],
      ),
    );
  }
}
