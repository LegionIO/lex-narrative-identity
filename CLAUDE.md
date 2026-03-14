# lex-narrative-identity

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-narrative-identity`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::NarrativeIdentity`

## Purpose

Personal narrative construction and identity coherence for LegionIO agents. Records significant episodes (achievements, failures, discoveries, transformations, etc.) organized into chapters and themed arcs. Computes narrative coherence as a measure of identity stability. Builds a life story from the accumulated episode record. Theme weights evolve with each episode, decaying toward zero and reinforced when engaged. Provides the agent's autobiographical "who am I" answer.

## Gem Info

- **Require path**: `legion/extensions/narrative_identity`
- **Ruby**: >= 3.4
- **License**: MIT
- **Registers with**: `Legion::Extensions::Core`

## File Structure

```
lib/legion/extensions/narrative_identity/
  version.rb
  helpers/
    constants.rb          # Episode types, theme types, significance labels, coherence labels
    episode.rb            # Episode value object
    theme.rb              # Theme value object with weight
    chapter.rb            # Chapter value object with open/close lifecycle
    narrative_engine.rb   # NarrativeEngine with story construction + coherence
  actors/
    narrative_decay.rb    # Theme decay actor
  runners/
    narrative_identity.rb # Runner module (uses extend self pattern)

spec/
  legion/extensions/narrative_identity/
    helpers/
      constants_spec.rb
      episode_spec.rb
      theme_spec.rb
      chapter_spec.rb
      narrative_engine_spec.rb
    actors/narrative_decay_spec.rb
    runners/narrative_identity_spec.rb
  spec_helper.rb
```

## Key Constants

```ruby
MAX_EPISODES  = 500
MAX_THEMES    = 50
MAX_CHAPTERS  = 20

EPISODE_TYPES = %i[
  achievement failure discovery relationship challenge transformation routine
]

THEME_TYPES = %i[
  growth agency communion redemption contamination stability exploration
]

SIGNIFICANCE_LABELS = {
  (0.8..)     => :pivotal,
  (0.6...0.8) => :significant,
  (0.4...0.6) => :notable,
  (0.2...0.4) => :minor,
  (..0.2)     => :incidental
}

COHERENCE_LABELS = {
  (0.8..)     => :coherent,
  (0.6...0.8) => :mostly_coherent,
  (0.4...0.6) => :fragmented,
  (0.2...0.4) => :incoherent,
  (..0.2)     => :disintegrated
}

CHAPTER_LABELS = %i[origin early_learning growth mastery current]
```

## Helpers

### `Helpers::Episode` (class)

A significant event in the agent's history.

| Attribute | Type | Description |
|---|---|---|
| `id` | String (UUID) | unique identifier |
| `type` | Symbol | from EPISODE_TYPES |
| `content` | String | description of the episode |
| `significance` | Float (0..1) | how pivotal this episode was |
| `emotional_valence` | Float (-1..1) | emotional charge |
| `themes` | Array<Symbol> | associated theme IDs |
| `chapter_id` | String | chapter this episode belongs to |
| `occurred_at` | Time | when it happened |

### `Helpers::Theme` (class)

A recurring narrative arc threading through episodes.

| Attribute | Type | Description |
|---|---|---|
| `id` | String (UUID) | unique identifier |
| `name` | Symbol | from THEME_TYPES or custom symbol |
| `weight` | Float (0..1) | current prominence in the narrative |
| `episode_count` | Integer | episodes linked to this theme |

Key methods:
- `reinforce(amount)` — weight += amount (cap 1.0); increments episode_count
- `decay(amount)` — weight -= amount (floor 0.0); removes theme from narrative when weight reaches 0

### `Helpers::Chapter` (class)

A named temporal segment of the agent's story.

| Attribute | Type | Description |
|---|---|---|
| `id` | String (UUID) | unique identifier |
| `label` | Symbol | from CHAPTER_LABELS |
| `title` | String | chapter title |
| `opened_at` | Time | start of chapter |
| `closed_at` | Time | end of chapter (nil if current) |
| `episode_ids` | Array<String> | episodes belonging to this chapter |

Key methods:
- `open` — sets opened_at, marks as active
- `close` — sets closed_at, marks as completed
- `current?` — closed_at.nil?

### `Helpers::NarrativeEngine` (class)

Central narrative store and story construction.

| Method | Description |
|---|---|
| `add_episode(type:, content:, significance:, emotional_valence:)` | creates and stores episode; enforces MAX_EPISODES |
| `assign_to_chapter(episode_id:, chapter_id:)` | links episode to chapter |
| `create_chapter(label:, title:)` | creates chapter; enforces MAX_CHAPTERS |
| `close_chapter(chapter_id:)` | closes chapter |
| `add_theme(name:)` | creates theme; enforces MAX_THEMES |
| `link_theme(episode_id:, theme_id:)` | associates episode with theme |
| `reinforce_theme(theme_id:, amount:)` | boosts theme weight |
| `narrative_coherence` | coherence score: significance-weighted variance across emotional valences |
| `identity_summary` | snapshot: current chapter, dominant themes, coherence, most significant episode |
| `life_story` | ordered episode content array with chapter grouping |
| `most_defining_episodes(limit:)` | top N episodes by significance |
| `prominent_themes(limit:)` | top N themes by weight |
| `current_chapter` | the chapter with closed_at == nil |
| `decay_all_themes!` | decrements all theme weights by small amount |
| `narrative_report` | full report: episode counts, themes, coherence, chapters |

Coherence formula: `1.0 - (significance-weighted stddev of emotional_valence)`. High coherence = consistent emotional arc; low coherence = wildly varying emotional experiences.

## Actors

**`Actors::NarrativeDecay`** — fires periodically, calls `decay_themes` on the runner to decay all theme weights. Note: actor name is `NarrativeDecay`, not `Decay`.

## Runners

Module: `Legion::Extensions::NarrativeIdentity::Runners::NarrativeIdentity`

Note: The runner uses `extend self` rather than the standard module-method pattern used by other LEX runners. This means its methods are called directly on the module.

Private state: `@engine` (memoized `NarrativeEngine` instance via `@engine ||= NarrativeEngine.new`).

| Runner Method | Parameters | Description |
|---|---|---|
| `record_episode` | `type:, content:, significance: 0.5, emotional_valence: 0.0` | Record a significant episode |
| `assign_episode_to_chapter` | `episode_id:, chapter_id:` | Link episode to chapter |
| `create_chapter` | `label:, title:` | Create a new narrative chapter |
| `close_chapter` | `chapter_id:` | Close a chapter |
| `add_theme` | `name:` | Add a narrative theme |
| `link_theme` | `episode_id:, theme_id:` | Link episode to theme |
| `reinforce_theme` | `theme_id:, amount: 0.1` | Boost theme prominence |
| `narrative_coherence` | (none) | Narrative coherence score and label |
| `identity_summary` | (none) | Who-am-I snapshot |
| `life_story` | (none) | Full ordered episode content |
| `most_defining_episodes` | `limit: 5` | Top N by significance |
| `prominent_themes` | `limit: 5` | Top N by weight |
| `current_chapter` | (none) | The currently active chapter |
| `decay_themes` | (none) | Decay all theme weights |
| `narrative_report` | (none) | Full narrative stats |

## Integration Points

- **lex-memory**: significant episodic memory traces from lex-memory are the raw material for episode creation; callers extract high-significance/high-emotional-intensity traces and `record_episode` them.
- **lex-mental-time-travel**: temporal journeys that revisit significant episodes reinforce the narrative by increasing those episodes' coherence contribution.
- **lex-dream**: dream phase `agenda_formation` uses narrative themes to set priorities; prominent themes guide dream consolidation.
- **lex-metacognition**: `NarrativeIdentity` is listed under `:introspection` capability category.

## Development Notes

- Runner uses `extend self` — this is the only runner in all 25 LEX gems that uses this pattern instead of the standard module with instance methods called via `Client`. The effect is that runner methods are module-level methods, not mixed into an object.
- Actor name is `NarrativeDecay`, not the standard `Decay` used by other LEX gems with decay actors. When referencing, use `Actors::NarrativeDecay`.
- Coherence is a stability measure, not a richness measure. An agent with entirely negative experiences has high coherence (consistent arc); an agent with alternating positive/negative experiences has low coherence.
- `narrative_report` is the most comprehensive output — includes episode counts by type, theme weights, coherence score, chapter list, and most defining episodes.
- MAX_EPISODES eviction removes oldest incidental (lowest significance) episodes first, not oldest by time. This preserves pivotal moments regardless of age.
- Theme decay is slow but episodic — themes with no recent `reinforce_theme` calls will gradually fade. The relationship between decay rate and number of episodes needed to sustain a theme depends on the actor interval.
