# EchoGen.ai UI Design Specifications

## Typography System

### Primary Font: **Inter**
- **Reasoning**: Modern, clean, highly readable at all sizes, excellent for both headings and body text
- **Usage**: Headings, body text, UI elements, buttons
- **Weights**: Light (300), Regular (400), Medium (500), SemiBold (600), Bold (700)

### Secondary Font: **SF Pro Display** (iOS) / **Roboto** (Android)
- **Usage**: System UI elements, native components
- **Fallback**: Inter for cross-platform consistency

### Font Hierarchy
```
Display Large: Inter Bold 32px
Display Medium: Inter Bold 28px
Headline Large: Inter SemiBold 24px
Headline Medium: Inter SemiBold 20px
Title Large: Inter Medium 18px
Title Medium: Inter Medium 16px
Body Large: Inter Regular 16px
Body Medium: Inter Regular 14px
Label Large: Inter Medium 14px
Label Medium: Inter Medium 12px
Label Small: Inter Medium 11px
```

## Color Palette (Based on Onboarding UI Reference)

### Primary Colors
- **Primary Blue**: `#4A5FF7` (matches onboarding purple-blue)
- **Primary Light**: `#6B7BFF`
- **Primary Dark**: `#3347D4`

### Secondary Colors
- **Coral/Orange**: `#FF6B6B` (matches onboarding coral)
- **Warm Yellow**: `#FFD93D`
- **Success Green**: `#6BCF7F`

### Neutral Colors
- **Background**: `#FAFBFC`
- **Surface**: `#FFFFFF`
- **Surface Variant**: `#F5F7FA`
- **Text Primary**: `#1A1D29`
- **Text Secondary**: `#6B7280`
- **Text Tertiary**: `#9CA3AF`
- **Border**: `#E5E7EB`
- **Border Light**: `#F3F4F6`

### Dark Mode Colors
- **Background**: `#0D1117`
- **Surface**: `#161B22`
- **Surface Variant**: `#21262D`
- **Text Primary**: `#F0F6FC`
- **Text Secondary**: `#8B949E`
- **Text Tertiary**: `#6E7681`

## App Bar Design

### Specifications
- **Height**: 64px (56px + 8px padding)
- **Background**: Surface color with subtle shadow
- **Title**: Inter SemiBold 20px
- **Elevation**: 2dp subtle shadow

### Content Layout
```
[Logo Icon] EchoGen.ai                    [Settings Icon]
     16px spacing     flex-grow              16px margin
```

### Interactive Elements
- **Logo**: Tappable, returns to home
- **Settings Icon**: Outlined gear icon, 24x24px
- **States**: Normal, Pressed (opacity 0.7)

## Bottom Navigation Bar Design

### Specifications
- **Height**: 80px (includes safe area)
- **Background**: Surface color
- **Border**: 1px top border in Border Light color
- **Elevation**: 8dp shadow (floating appearance)

### Navigation Items (3 tabs)

#### 1. Create (Default/Home)
- **Icon**: Plus circle or microphone-plus (24x24px)
- **Label**: "Create"
- **Active State**: Primary Blue color
- **Inactive State**: Text Secondary color

#### 2. Library
- **Icon**: Headphones or list icon (24x24px)
- **Label**: "Library"
- **Badge**: Optional red dot for new items

#### 3. Settings
- **Icon**: Gear or sliders icon (24x24px)
- **Label**: "Settings"

### Interaction States
- **Active**: Icon + Label in Primary Blue, subtle background highlight
- **Inactive**: Icon + Label in Text Secondary
- **Pressed**: Brief scale animation (0.95x)

## Homepage (Create Page) Design

### Overall Layout Structure
```
┌─────────────────────────────────────┐
│           App Bar                   │
├─────────────────────────────────────┤
│                                     │
│           Tab Bar                   │
│     [From URL][From Audio][Prompt]  │
│                                     │
│           Tab Content               │
│         (Dynamic based              │
│          on selected tab)           │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│         Bottom Navigation           │
└─────────────────────────────────────┘
```

### Tab Bar Design
- **Height**: 48px
- **Background**: Surface color
- **Indicator**: Primary Blue, 3px height, rounded
- **Tab Spacing**: Equal distribution
- **Tab Text**: Inter Medium 14px
- **Active State**: Primary Blue text
- **Inactive State**: Text Secondary

### Tab Content Layouts

#### Tab 1: From URL
```
┌─────────────────────────────────────┐
│  🌐 Turn any article into a podcast │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ Enter URL (article, blog...)    │ │
│  │ https://example.com/article     │ │
│  └─────────────────────────────────┘ │
│                                     │
│  📡 Content Extraction Service      │
│  ○ Firecrawl    ○ HyperbrowserAI   │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │     🚀 Fetch Content           │ │
│  └─────────────────────────────────┘ │
│                                     │
│  💡 Paste any article URL and we'll │
│     extract the content for you     │
└─────────────────────────────────────┘
```

#### Tab 2: From Audio
```
┌─────────────────────────────────────┐
│  🎵 Transform audio into podcast    │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │    📁 Upload Audio File         │ │
│  │    MP3, WAV, M4A supported      │ │
│  └─────────────────────────────────┘ │
│                                     │
│  🤖 Transcription Service           │
│  ○ Groq (Whisper)                  │
│  ○ OpenAI (Whisper)                │
│  ○ Google AI Studio                │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │     ✨ Transcribe & Proceed     │ │
│  └─────────────────────────────────┘ │
│                                     │
│  💡 Upload your audio and we'll     │
│     convert it to podcast script    │
└─────────────────────────────────────┘
```

#### Tab 3: From Prompt
```
┌─────────────────────────────────────┐
│  💭 Create podcast from your ideas  │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ Describe your podcast topic...  │ │
│  │                                 │ │
│  │ e.g., "A 10-minute discussion   │ │
│  │ about AI impact on education"   │ │
│  │                                 │ │
│  │                                 │ │
│  └─────────────────────────────────┘ │
│                                     │
│  🧠 AI Model                        │
│  ○ Google Gemini  ○ OpenAI GPT-4   │
│  ○ Claude        ○ Groq Models     │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │     🎯 Generate Script          │ │
│  └─────────────────────────────────┘ │
│                                     │
│  💡 Describe your idea and AI will  │
│     create the complete script      │
└─────────────────────────────────────┘
```

### Component Specifications

#### Input Fields
- **Height**: 48px (single line), 120px (multi-line)
- **Background**: Surface color
- **Border**: 1px Border color, 2px Primary Blue (focused)
- **Border Radius**: 8px
- **Padding**: 16px horizontal, 12px vertical

#### Radio Button Groups
- **Layout**: Horizontal flow, wrap if needed
- **Spacing**: 12px between options
- **Active State**: Primary Blue background, white text
- **Inactive State**: Border color outline

#### Primary Buttons
- **Height**: 48px
- **Background**: Primary Blue
- **Text**: White, Inter Medium 16px
- **Border Radius**: 8px
- **Elevation**: 2dp shadow
- **Pressed State**: Primary Dark background

#### Cards/Sections
- **Background**: Surface color
- **Border Radius**: 12px
- **Padding**: 20px
- **Margin**: 16px horizontal, 8px vertical
- **Shadow**: 1dp subtle shadow

## Implementation Notes

### Flutter Specific
- Use `Inter` font family via Google Fonts package
- Implement `Theme.of(context)` for consistent theming
- Use `BottomNavigationBar` with custom styling
- Implement `TabBar` with `TabBarView` for create page
- Use `Card` widgets for content sections
- Implement proper dark mode support

### Responsive Considerations
- Minimum tap target: 44px x 44px
- Text scaling support for accessibility
- Landscape orientation adjustments
- Tablet layout adaptations (wider cards, more spacing)

### Accessibility
- Semantic labels for all interactive elements
- High contrast ratios (4.5:1 minimum)
- Focus indicators for keyboard navigation
- Screen reader announcements for state changes 