---
name: Focus Flow
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#434655'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#585f67'
  on-secondary: '#ffffff'
  secondary-container: '#dce3ec'
  on-secondary-container: '#5e656d'
  tertiary: '#006242'
  on-tertiary: '#ffffff'
  tertiary-container: '#007d55'
  on-tertiary-container: '#bdffdb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#dce3ec'
  secondary-fixed-dim: '#c0c7d0'
  on-secondary-fixed: '#151c23'
  on-secondary-fixed-variant: '#40484f'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-timer:
    fontFamily: Outfit
    fontSize: 64px
    fontWeight: '600'
    lineHeight: 72px
    letterSpacing: -0.03em
  display-timer-mobile:
    fontFamily: Outfit
    fontSize: 56px
    fontWeight: '600'
    lineHeight: 64px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Outfit
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.25rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system establishes a high-performance productivity environment that pairs deep focus with approachable warmth. Targeted at professionals, students, and knowledge workers who require cognitive clarity without sensory overwhelm, the aesthetic blends Modern Clean surfaces with subtle Tactile elements. 

The interface evokes calm agency, rhythm, and gentle accomplishment. Key visuals leverage pure white elevated surfaces set against an ultra-soft cool background, keeping eye fatigue minimal during multi-hour focus sessions. Visual tension is deliberately low: sharp lines are replaced by structural softness, high-contrast borders are restrained to subtle 1px frame dividers, and state feedback relies on crisp primary blues and reassuring success emeralds rather than loud alarms.

## Colors

The palette is engineered around high legibility, strict contrast standards, and functional calmness.

- **Background Canvas (`#F8FAFC`)**: A cool, muted slate tint that reduces glare compared to pure white, serving as the quiet base for elevated task cards.
- **Surface & Cards (`#FFFFFF`)**: Pure white reserved strictly for elevated components, input regions, and modal containers. Outlined with `#E2E8F0` to maintain definition without visual noise.
- **Primary Focus (`#2563EB`)**: A vibrant cobalt blue representing active states, primary CTA buttons, timer progress rings, and selected indicators.
- **Primary Soft (`#EFF6FF`)**: A delicate pastel blue tint used for pill backplates, selected navigation indicators, and active badge backgrounds.
- **Text & Hierarchy**:
  - `Text Primary` (`#0F172A`): Deep slate, offering maximum readability for clock digits, headers, and active tasks.
  - `Text Secondary` (`#475569`): Mid-slate, strictly validated against WCAG AA requirements on both `#FFFFFF` and `#F8FAFC` backgrounds for labels, timestamps, and secondary descriptors.
- **Semantic States**:
  - `Success` (`#10B981`): Emerald green used for session completion, streak milestones, and task checkmarks. Soft surface counterpart: `#ECFDF5`.
  - `Destructive / Break Reset` (`#EF4444`): Vivid crimson for timer aborts and deletions, coupled with soft alert backdrop `#FEE2E2`.

## Typography

The type system balances mathematical legibility with approachable geometry. 

- **Outfit** provides friendly, balanced round geometry for top-level headers, section titles, and the primary countdown clock. The numerical glyphs are tabular and open, preventing clock jitter during rapid countdown changes.
- **Inter** provides neutral, utilitarian performance across task descriptions, settings lists, data labels, and timestamps.
- **Guidelines**:
  - Emojis are strictly banned from titles, metrics, and technical labels to preserve cognitive focus; all iconography is delivered via clean stroke-based vectors.
  - Large countdown sizes scale down smoothly via `display-timer-mobile` for viewports under 380px wide to avoid breaking layout margins.

## Layout & Spacing

The layout is built for fluid touch performance within a mobile-first column model. 

- **Grid Architecture**: Mobile views leverage a 4-column layout with `1rem` margins and `0.75rem` gutters. Tablet expansions move to an 8-column layout with `1.5rem` margins and a maximum content containment width of 640px to ensure the timer and task views remain focused and within comfortable thumb reach.
- **Vertical Rhythm**: Built upon an 8px base grid (with a 4px sub-grid for tight chip/label paddings). Content stacks adhere strictly to `space-md` (16px) between cohesive cards and `space-xl` (32px) separating major screen modules (e.g., Timer Display to Task Queue).
- **Safe Area Adaptations**: Full accommodation for bottom navigation safe insets (iOS home indicator padding + Android system nav bars) ensures interactive buttons never collide with device edge gestures.

## Elevation & Depth

Visual hierarchy is communicated through subtle boundary definition and low-intensity ambient diffusion, avoiding harsh drop shadows:

- **Level 0 (Canvas Base)**: `#F8FAFC` flat surface.
- **Level 1 (Default Containers & Task Cards)**: `#FFFFFF` surface bounded by a crisp `1px solid #E2E8F0` border and an ambient shadow: `0px 2px 8px rgba(15, 23, 42, 0.04)`.
- **Level 2 (Floating Action Elements & Active Modals)**: `#FFFFFF` surface with `1px solid #CBD5E1` border and an ambient shadow: `0px 8px 24px rgba(15, 23, 42, 0.08)`.
- **Level 3 (Fixed Bottom Navigation Bar)**: Pure `#FFFFFF` bar with a subtle top edge border `1px solid #E2E8F0` and upward diffused shadow: `0px -4px 16px rgba(15, 23, 42, 0.03)`.

## Shapes

The design system employs a distinct dual-tier shape language:

- **Containers and Cards**: Strictly governed by a rounded corner radius of `16px` (`1rem`). This applies to session statistics cards, task tiles, settings groups, and modal dialogs.
- **Pills and Circular Controls**: Complete pill encapsulation using `9999px` radius (`rounded-full`). Applied across navigation pill targets, filter tags, primary action buttons, timer control circles, and status chips.
- This dynamic contrast between structured 16px cards and fully rounded interactables provides clear visual affordance for tap targets.

## Components

### Buttons & Interactive Controls
- **Primary Button**: Fully rounded (`9999px`), background `#2563EB`, text `#FFFFFF` (`label-lg`). Height: 52px. Active press scales down slightly (`scale(0.98)`).
- **Secondary / Soft Button**: Background `#EFF6FF`, text `#2563EB` (`label-lg`), height: 44px, radius `9999px`.
- **Destructive Button**: Background `#FEE2E2`, text `#EF4444`, radius `9999px`.
- **Timer Floating Circular Actions**: 64x64px circular buttons (`radius: 9999px`) for Play/Pause (`#2563EB` fill, white vector icon) and 48x48px for Reset/Skip (`#F1F5F9` fill, `#475569` vector icon).

### Cards
- Constructed with `#FFFFFF`, `16px` radius, `1px solid #E2E8F0` border, and Level 1 elevation shadow. Inner padding is uniformly `space-md` (16px) or `space-lg` (24px) for milestone summaries.

### Bottom Navigation
- Fixed at the screen base with safe area padding. Contains 4 structured items: **Timer**, **Stats**, **Premios**, and **Config**.
- **Inactive Item**: 24px clean vector line icon, color `#475569`, label in `label-sm` (`#475569`).
- **Active Item**: Encapsulated within a pastel blue pill (`#EFF6FF`), padding 8px horizontal, 16px vertical, `9999px` radius. Icon and typography rendered in active primary `#2563EB`. No emojis permitted.

### Task Checkbox & List Items
- **List Tile**: `#FFFFFF` background, 16px border-radius, `space-md` padding.
- **Checkbox**: 22x22px pill-rounded (`radius: 6px`), 1.5px border `#CBD5E1`. On checked: `#10B981` background with white vector check icon. Completed task text transitions to `#475569` with strikethrough.

### Input Fields
- Background `#FFFFFF`, 1px border `#E2E8F0`, 12px radius, 48px height. Focus state introduces a 2px outer ring in `#2563EB` with an extra subtle shadow glow. Placeholder text in `#94A3B8`.

### Timer Ring & Visualizer
- Concentric circular gauge with 8px stroke. Track background in `#E2E8F0`, animated progress arc in `#2563EB` with rounded stroke caps. Center stage houses the `display-timer` typography.