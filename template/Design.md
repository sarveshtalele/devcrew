---
version: alpha
name: "{{PROJECT_NAME}} Design System"
description: Modern SaaS, vibrant but disciplined. Light and dark as equal first-class themes, WCAG 2.2 AA throughout.

colors:
  # --- light theme (default) ---
  primary: "#5B2BD9"          # brand violet; white text on it clears AA
  primaryHover: "#4A21B5"
  primaryActive: "#3A1A8F"
  onPrimary: "#FFFFFF"
  accent: "#0B7C87"           # teal; the far stop of the brand gradient
  onAccent: "#FFFFFF"
  surface: "#FFFFFF"
  surfaceSunken: "#F7F7FB"
  surfaceRaised: "#FFFFFF"
  border: "#E5E5EF"
  borderStrong: "#CFCFDE"
  text: "#1A1A24"
  textMuted: "#5B5B70"
  success: "#17803D"
  warning: "#92610A"
  danger: "#C02626"
  info: "#1D4FD8"
  focus: "#5B2BD9"

  # --- dark theme ---
  # The token schema has no theme axis, so dark variants are named tokens.
  # Lightness is lifted rather than surfaces darkened further: saturated hues
  # vibrate against near-black backgrounds.
  primaryDark: "#A78BFA"
  primaryHoverDark: "#BCA5FB"
  primaryActiveDark: "#C9BAFC"
  onPrimaryDark: "#14141C"
  accentDark: "#5EEAD4"
  onAccentDark: "#14141C"
  surfaceDark: "#14141C"
  surfaceSunkenDark: "#0F0F16"
  surfaceRaisedDark: "#1D1D28"
  borderDark: "#33334A"
  borderStrongDark: "#4A4A66"
  textDark: "#F5F5FA"
  textMutedDark: "#B4B4C8"
  successDark: "#4ADE80"
  warningDark: "#FCD34D"
  dangerDark: "#FCA5A5"
  infoDark: "#93C5FD"
  focusDark: "#A78BFA"

typography:
  display:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: -0.03em
    fontFeature: "'cv11', 'ss01'"
  h1:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: -0.02em
  h2:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: 650
    lineHeight: 1.25
    letterSpacing: -0.015em
  h3:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: -0.01em
  body:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.6
    letterSpacing: 0em
  bodySmall:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.55
    letterSpacing: 0em
  label:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 550
    lineHeight: 1.4
    letterSpacing: 0em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: 450
    lineHeight: 1.45
    letterSpacing: 0.01em
  numeric:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 450
    lineHeight: 1.5
    letterSpacing: 0em
    fontFeature: "'tnum' 1"
  code:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: 450
    lineHeight: 1.6
    letterSpacing: 0em

spacing:
  none: 0px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  3xl: 64px
  4xl: 96px

rounded:
  none: 0px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  full: 9999px

components:
  # Valid sub-tokens are fixed by the spec: backgroundColor, textColor,
  # typography, rounded, padding, size, height, width. Anything the schema
  # cannot model — borders, focus rings, shadows — is specified in the prose
  # below and applied by hand.
  buttonPrimary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.onPrimary}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
    height: 44px
  buttonPrimaryHover:
    backgroundColor: "{colors.primaryHover}"
    textColor: "{colors.onPrimary}"
  buttonPrimaryActive:
    backgroundColor: "{colors.primaryActive}"
    textColor: "{colors.onPrimary}"
  buttonPrimaryDisabled:
    backgroundColor: "{colors.surfaceSunken}"
    textColor: "{colors.textMuted}"
  buttonPrimaryDark:
    backgroundColor: "{colors.primaryDark}"
    textColor: "{colors.onPrimaryDark}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
    height: 44px
  buttonPrimaryHoverDark:
    backgroundColor: "{colors.primaryHoverDark}"
    textColor: "{colors.onPrimaryDark}"
  buttonPrimaryActiveDark:
    backgroundColor: "{colors.primaryActiveDark}"
    textColor: "{colors.onPrimaryDark}"
  buttonSecondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
    height: 44px
  buttonSecondaryDark:
    backgroundColor: "{colors.surfaceRaisedDark}"
    textColor: "{colors.textDark}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
    height: 44px
  buttonGhost:
    backgroundColor: "{colors.surfaceSunken}"
    textColor: "{colors.textMuted}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
  buttonGhostDark:
    backgroundColor: "{colors.surfaceSunkenDark}"
    textColor: "{colors.textMutedDark}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
  buttonDestructive:
    backgroundColor: "{colors.danger}"
    textColor: "{colors.onPrimary}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
    height: 44px
  buttonDestructiveDark:
    backgroundColor: "{colors.dangerDark}"
    textColor: "{colors.onPrimaryDark}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
    height: 44px
  buttonAccent:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.onAccent}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
    height: 44px
  buttonAccentDark:
    backgroundColor: "{colors.accentDark}"
    textColor: "{colors.onAccentDark}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
    height: 44px
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
    height: 44px
  inputDark:
    backgroundColor: "{colors.surfaceSunkenDark}"
    textColor: "{colors.textDark}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
    height: 44px
  card:
    backgroundColor: "{colors.surfaceRaised}"
    textColor: "{colors.text}"
    rounded: "{rounded.lg}"
    padding: "{spacing.lg}"
  cardDark:
    backgroundColor: "{colors.surfaceRaisedDark}"
    textColor: "{colors.textDark}"
    rounded: "{rounded.lg}"
    padding: "{spacing.lg}"
  dialog:
    backgroundColor: "{colors.surfaceRaised}"
    textColor: "{colors.text}"
    rounded: "{rounded.xl}"
    padding: "{spacing.xl}"
    width: 512px
  dialogDark:
    backgroundColor: "{colors.surfaceRaisedDark}"
    textColor: "{colors.textDark}"
    rounded: "{rounded.xl}"
    padding: "{spacing.xl}"
    width: 512px
  toast:
    backgroundColor: "{colors.surfaceRaised}"
    textColor: "{colors.text}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  toastDark:
    backgroundColor: "{colors.surfaceRaisedDark}"
    textColor: "{colors.textDark}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  badge:
    backgroundColor: "{colors.surfaceSunken}"
    textColor: "{colors.text}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  badgeSuccess:
    backgroundColor: "{colors.success}"
    textColor: "{colors.onPrimary}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  badgeWarning:
    backgroundColor: "{colors.warning}"
    textColor: "{colors.onPrimary}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  badgeDanger:
    backgroundColor: "{colors.danger}"
    textColor: "{colors.onPrimary}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  badgeInfo:
    backgroundColor: "{colors.info}"
    textColor: "{colors.onPrimary}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  badgeSuccessDark:
    backgroundColor: "{colors.successDark}"
    textColor: "{colors.onPrimaryDark}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  badgeWarningDark:
    backgroundColor: "{colors.warningDark}"
    textColor: "{colors.onPrimaryDark}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  badgeDangerDark:
    backgroundColor: "{colors.dangerDark}"
    textColor: "{colors.onPrimaryDark}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  badgeInfoDark:
    backgroundColor: "{colors.infoDark}"
    textColor: "{colors.onPrimaryDark}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xs}"
  tableCell:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text}"
    typography: "{typography.numeric}"
    padding: "{spacing.sm}"
  tableCellDark:
    backgroundColor: "{colors.surfaceDark}"
    textColor: "{colors.textDark}"
    typography: "{typography.numeric}"
    padding: "{spacing.sm}"
  codeBlock:
    backgroundColor: "{colors.surfaceSunken}"
    textColor: "{colors.text}"
    typography: "{typography.code}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md}"
  codeBlockDark:
    backgroundColor: "{colors.surfaceSunkenDark}"
    textColor: "{colors.textDark}"
    typography: "{typography.code}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md}"
  skeleton:
    backgroundColor: "{colors.surfaceSunken}"
    rounded: "{rounded.sm}"
  skeletonDark:
    backgroundColor: "{colors.surfaceRaisedDark}"
    rounded: "{rounded.sm}"
---

# Design System

> **Format:** [DESIGN.md by Google Labs](https://github.com/google-labs-code/design.md) — the YAML front matter above carries machine-readable tokens, the prose below carries the rationale. Agents read both; the Tailwind theme is generated from the front matter and never hand-edited.
>
> ```bash
> make design          # lint, then export tokens.css + tailwind.tokens.json
> make design-check    # lint only — this is what CI runs
> ```
>
> Change a value **here**, then regenerate. The section order below is canonical and the linter enforces it, along with contrast ratios and token references. Values that the token schema does not model — elevation, motion, breakpoints, gradients — live in the prose sections below and are applied by hand.

## Overview

Modern SaaS, vibrant but disciplined. The product should feel fast, current, and confident: a saturated violet→teal brand gradient used sparingly against calm neutral surfaces. Energy comes from **one** gradient, generous radii, and soft layered shadows; everything else stays quiet so the data stays readable.

The rule that keeps "vibrant" from becoming "loud": **colour is a signal, not decoration.** If a surface is coloured, it is because something on it is actionable or needs attention. A screen has at most one gradient element.

Light and dark are equal first-class themes, not an inversion. Every colour has a `…Dark` counterpart. Ship neither until both pass contrast.

## Colors

- `primary` is both the identity and the interactive colour, chosen dark enough that `onPrimary` white text clears 4.5:1. Do not lighten it and keep white text.
- `accent` exists almost exclusively as the far stop of the brand gradient. It is not a second brand colour and must not be used to colour standalone controls.
- Semantic colours (`success` `warning` `danger` `info`) never carry meaning alone — always pair with an icon and text. Colour-blind users must lose nothing.
- Dark mode **lifts lightness** (`primary #5B2BD9 → primaryDark #A78BFA`) rather than darkening surfaces further, and flips `onPrimary` to near-black. Saturated hues at low lightness vibrate against dark backgrounds.
- **Contrast floors, checked by the linter, not by eye:** body text ≥ 4.5:1, large text (≥ 24px, or 18.66px bold) ≥ 3:1, UI borders and icons ≥ 3:1, focus ring ≥ 3:1 against both the component and the surrounding surface.

`border`, `borderStrong`, `focus`, and their dark counterparts are defined here but cannot be referenced from a component block — the spec's component sub-tokens are `backgroundColor`, `textColor`, `typography`, `rounded`, `padding`, `size`, `height`, `width`, with no border or outline slot. The linter reports them as orphaned; that is expected, and they are applied through the CSS in this document rather than through the token export.

**Gradient** (not a token — the schema has no gradient type; apply by hand):

```css
--gradient-brand: linear-gradient(135deg, #5B2BD9 0%, #0B7C87 100%);
--gradient-brand-dark: linear-gradient(135deg, #A78BFA 0%, #5EEAD4 100%);
```

Never place body text on the gradient. One gradient element per screen.

## Typography

Inter for everything, JetBrains Mono for code, IDs, and anything the user might copy. One family keeps the vertical rhythm predictable and removes a whole class of layout bugs.

- The scale is fixed at nine steps. If you need a size that isn't in it, you need a different component.
- Negative letter-spacing tightens as size grows (`display` −0.03em → `body` 0). This is what makes large headings look designed rather than merely large.
- Line length caps at **72ch** for prose, **48ch** in cards.
- Use the `numeric` token for tables, prices, and metrics — it enables tabular figures so columns don't jitter on update.
- Weight, not colour, carries hierarchy. `textMuted` is for genuinely secondary content, never for "smaller heading".

## Layout

- 4px base grid. Every padding, gap, and margin comes from `spacing`. No arbitrary `13px`.
- 12-column fluid grid, `lg` gutters on desktop, `md` on mobile. Page max-width 1280px, content column 1120px.
- **Vertical rhythm:** `md` inside a component, `lg` between components, `2xl` between sections.
- Touch targets ≥ 44×44px at every breakpoint, including desktop — people use touchscreens on desktop.
- Never hide content to fit a small screen. Reflow, stack, or progressively disclose it.

**Breakpoints** (not tokens — applied in the Tailwind config):

| Name | Width | Also the Playwright viewport |
|---|---|---|
| mobile | 375px | ✓ |
| tablet | 768px | ✓ |
| desktop | 1280px | ✓ |
| wide | 1536px | |

Mobile-first. Layout must be correct at the three viewports the E2E suite runs.

## Elevation & Depth

Five levels, each with one job. Not tokens — the schema has no shadow type, so these are applied as CSS custom properties.

| Level | Use | Value |
|---|---|---|
| 0 | flush content, pressed states | `none` |
| 1 | cards, resting buttons | `0 1px 2px rgb(26 26 36 / 0.06), 0 1px 3px rgb(26 26 36 / 0.10)` |
| 2 | hover on an interactive surface | `0 4px 8px rgb(26 26 36 / 0.06), 0 2px 4px rgb(26 26 36 / 0.08)` |
| 3 | popovers, dropdowns, toasts | `0 12px 24px rgb(26 26 36 / 0.10), 0 4px 8px rgb(26 26 36 / 0.06)` |
| 4 | modals, command palette | `0 24px 48px rgb(26 26 36 / 0.14), 0 8px 16px rgb(26 26 36 / 0.08)` |
| focus ring | every focusable element | `0 0 0 2px var(--surface), 0 0 0 4px var(--focus)` |

Shadows are tinted with the text hue, never pure black — pure black shadows read as dirt on coloured surfaces. In dark mode shadows do little work; depth comes from `surfaceRaisedDark` being *lighter* than `surfaceDark`. Do not stack elevations: a card inside a modal stays at 0.

**Motion** (not tokens): fast 120ms, base 200ms, slow 320ms; standard easing `cubic-bezier(0.2, 0, 0, 1)`. Animate `transform` and `opacity` only, and respect `prefers-reduced-motion`.

## Shapes

- Radii step with size: controls `md` (12px), cards `lg` (16px), modals `xl` (24px), pills and avatars `full`.
- **Nested radius rule:** inner radius = outer radius − padding. A `lg` card with `lg` padding holds `md` children. Concentric corners are the tell that separates a designed UI from an assembled one.
- Borders are 1px `border` for structure, `borderStrong` for anything interactive. Border *and* elevation together only at level 3+.

## Components

Built on shadcn/ui (Radix primitives, source-owned in `src/components/ui/`). Radix gives correct focus management, ARIA, and keyboard behaviour for free — **do not** hand-roll a dialog, combobox, or menu.

Rules for every component:

- Ships with all states: default, hover, active, **focus-visible**, disabled, loading, error, empty.
- Focus ring on every focusable element. Never `outline: none` without an equivalent replacement.
- Loading uses skeletons shaped like the eventual content, not spinners. Spinners only for actions under 1s.
- Empty states explain what goes here and give the action that fills it.
- Errors say what happened and what to do next, next to the field that caused it, announced via `aria-live`.
- Destructive actions require confirmation naming the exact object being destroyed.
- Any component rendering PII, PHI, or cardholder data masks by default (`•••• 4242`) with explicit reveal, and is excluded from analytics and session replay.

Dark-mode component values are the same token names with the `Dark` suffix — `buttonPrimary` uses `{colors.primary}` in light and `{colors.primaryDark}` in dark. The generated theme wires both; components never branch on theme themselves.

## Do's and Don'ts

**Do**

- Take every value from the tokens above and generate the Tailwind config with `make design`.
- Run `make design-check` before calling a UI change done — contrast is arithmetic, not opinion.
- Test both themes and all three viewports.
- Animate `transform` and `opacity` only, and respect `prefers-reduced-motion`.
- Use semantic HTML first, Radix second, `div` last.
- Label every icon-only control with `aria-label`.

**Don't**

- Don't add a colour, size, radius, or shadow that isn't defined here. Extend the front matter in a PR instead.
- Don't use more than one gradient per screen, or a gradient behind body text.
- Don't convey state with colour alone.
- Don't use placeholder text as a label — it disappears exactly when the user needs it.
- Don't put disabled buttons behind unexplained rules; say what unlocks them.
- Don't nest elevations, or mix `md` and `lg` radii on sibling elements.
- Don't ship a component without a focus-visible state. axe won't catch it; reviewers must.
- Don't reorder the sections of this file. The order is canonical and the linter enforces it.
