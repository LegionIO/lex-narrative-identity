# lex-narrative-identity

Personal narrative construction and identity coherence for LegionIO agents. Part of the LegionIO cognitive architecture extension ecosystem (LEX).

## What It Does

`lex-narrative-identity` gives an agent an autobiographical self. It records significant episodes (achievements, failures, discoveries, transformations) organized into chapters and threaded by recurring themes. Narrative coherence measures identity stability based on the consistency of the agent's emotional arc. The life story and identity summary answer the agent's "who am I" question.

Key capabilities:

- **Episode types**: achievement, failure, discovery, relationship, challenge, transformation, routine
- **Theme types**: growth, agency, communion, redemption, contamination, stability, exploration
- **Chapters**: temporal narrative segments with label, title, and open/closed lifecycle
- **Coherence scoring**: significance-weighted variance of emotional valence across episodes
- **Coherence labels**: coherent / mostly_coherent / fragmented / incoherent / disintegrated
- **Significance labels**: pivotal / significant / notable / minor / incidental

## Installation

Add to your Gemfile:

```ruby
gem 'lex-narrative-identity'
```

Or install directly:

```
gem install lex-narrative-identity
```

## Usage

```ruby
require 'legion/extensions/narrative_identity'

client = Legion::Extensions::NarrativeIdentity::Client.new

# Create a narrative chapter
chapter = client.create_chapter(label: :growth, title: 'Learning Phase')
chapter_id = chapter[:chapter][:id]

# Record significant episodes
ep = client.record_episode(
  type: :achievement,
  content: 'Successfully resolved a complex multi-agent coordination problem',
  significance: 0.9,
  emotional_valence: 0.8
)

# Assign to chapter and link themes
client.assign_episode_to_chapter(episode_id: ep[:episode][:id], chapter_id: chapter_id)

theme = client.add_theme(name: :growth)
client.link_theme(episode_id: ep[:episode][:id], theme_id: theme[:theme][:id])

# Get identity summary
summary = client.identity_summary
# => { coherence: 0.82, coherence_label: :coherent,
#      dominant_themes: [:growth], current_chapter: { label: :growth, ... },
#      most_significant: { content: '...', significance: 0.9 } }

# Full life story
client.life_story

# Stats
client.narrative_report
```

## Runner Methods

| Method | Description |
|---|---|
| `record_episode` | Record a significant episode |
| `assign_episode_to_chapter` | Link episode to a chapter |
| `create_chapter` | Create a new narrative chapter |
| `close_chapter` | Close a chapter |
| `add_theme` | Add a narrative theme |
| `link_theme` | Link an episode to a theme |
| `reinforce_theme` | Boost a theme's prominence |
| `narrative_coherence` | Coherence score and label |
| `identity_summary` | Who-am-I snapshot: coherence, themes, current chapter |
| `life_story` | Full ordered episode content with chapter grouping |
| `most_defining_episodes` | Top N episodes by significance |
| `prominent_themes` | Top N themes by weight |
| `current_chapter` | The currently active chapter |
| `decay_themes` | Decay all theme weights |
| `narrative_report` | Full narrative statistics |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
