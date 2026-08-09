---
# DESIGN.md token schema — machine-readable source of truth.
# Tailwind config and shadcn/ui theme are GENERATED from this block. Edit here, not there.
meta:
  name: "{{PROJECT_NAME}} Design System"
  version: 1.0.0
  style: modern-saas-vibrant
  contrast: WCAG-2.2-AA
  themes: [light, dark]

colors:
  light:
    brand.50:  "oklch(0.97 0.02 275)"
    brand.100: "oklch(0.94 0.04 275)"
    brand.300: "oklch(0.80 0.12 275)"
    brand.500: "oklch(0.62 0.21 275)"   # primary accent
    brand.600: "oklch(0.55 0.21 275)"   # primary hover — 4.8:1 on surface
    brand.700: "oklch(0.47 0.19 275)"   # primary active
    accent.500: "oklch(0.70 0.19 195)"  # secondary/teal, gradient partner
    surface:      "oklch(1 0 0)"
    surface.sunken: "oklch(0.98 0.004 275)"
    surface.raised: "oklch(1 0 0)"
    border:       "oklch(0.91 0.006 275)"
    border.strong: "oklch(0.82 0.01 275)"
    text:         "oklch(0.22 0.02 275)"   # 14.6:1 on surface
    text.muted:   "oklch(0.50 0.02 275)"   # 4.9:1 on surface
    text.onBrand: "oklch(1 0 0)"           # 4.9:1 on brand.600
    success: "oklch(0.62 0.15 150)"
    warning: "oklch(0.72 0.16 75)"
    danger:  "oklch(0.58 0.21 25)"
    info:    "oklch(0.62 0.15 240)"
    focus:   "oklch(0.62 0.21 275)"
  dark:
    brand.50:  "oklch(0.24 0.05 275)"
    brand.100: "oklch(0.30 0.07 275)"
    brand.300: "oklch(0.55 0.16 275)"
    brand.500: "oklch(0.72 0.17 275)"   # lifted for dark surfaces
    brand.600: "oklch(0.78 0.15 275)"
    brand.700: "oklch(0.84 0.12 275)"
    accent.500: "oklch(0.78 0.15 195)"
    surface:      "oklch(0.19 0.015 275)"
    surface.sunken: "oklch(0.15 0.015 275)"
    surface.raised: "oklch(0.24 0.018 275)"
    border:       "oklch(0.32 0.02 275)"
    border.strong: "oklch(0.42 0.02 275)"
    text:         "oklch(0.97 0.005 275)"  # 15.1:1 on surface
    text.muted:   "oklch(0.74 0.015 275)"  # 6.2:1 on surface
    text.onBrand: "oklch(0.17 0.02 275)"   # 8.4:1 on brand.500
    success: "oklch(0.75 0.15 150)"
    warning: "oklch(0.82 0.15 75)"
    danger:  "oklch(0.71 0.18 25)"
    info:    "oklch(0.74 0.14 240)"
    focus:   "oklch(0.78 0.15 275)"

gradients:
  brand:   "linear-gradient(135deg, {colors.brand.500} 0%, {colors.accent.500} 100%)"
  surface: "linear-gradient(180deg, {colors.surface.raised} 0%, {colors.surface} 100%)"

typography:
  fontFamily.sans: "Inter var, Inter, ui-sans-serif, system-ui, sans-serif"
  fontFamily.mono: "JetBrains Mono, ui-monospace, SFMono-Regular, monospace"
  features: "'cv11', 'ss01', 'tnum' 0"          # tabular nums enabled per-component
  display:  { size: "3rem",    weight: 700, lineHeight: 1.1,  letterSpacing: "-0.03em" }
  h1:       { size: "2.25rem", weight: 700, lineHeight: 1.15, letterSpacing: "-0.02em" }
  h2:       { size: "1.75rem", weight: 650, lineHeight: 1.25, letterSpacing: "-0.015em" }
  h3:       { size: "1.375rem",weight: 600, lineHeight: 1.3,  letterSpacing: "-0.01em" }
  body:     { size: "1rem",    weight: 400, lineHeight: 1.6,  letterSpacing: "0" }
  bodySm:   { size: "0.875rem",weight: 400, lineHeight: 1.55, letterSpacing: "0" }
  label:    { size: "0.875rem",weight: 550, lineHeight: 1.4,  letterSpacing: "0" }
  caption:  { size: "0.75rem", weight: 450, lineHeight: 1.45, letterSpacing: "0.01em" }
  code:     { size: "0.875rem",weight: 450, lineHeight: 1.6,  family: "{typography.fontFamily.mono}" }

spacing:      # 4px base, used for padding, gap, margin
  0: "0"
  1: "0.25rem"
  2: "0.5rem"
  3: "0.75rem"
  4: "1rem"
  6: "1.5rem"
  8: "2rem"
  12: "3rem"
  16: "4rem"
  24: "6rem"

rounded:
  none: "0"
  sm:   "0.5rem"
  md:   "0.75rem"
  lg:   "1rem"
  xl:   "1.5rem"
  full: "9999px"

elevation:
  0: "none"
  1: "0 1px 2px oklch(0.22 0.02 275 / 0.06), 0 1px 3px oklch(0.22 0.02 275 / 0.10)"
  2: "0 4px 8px oklch(0.22 0.02 275 / 0.06), 0 2px 4px oklch(0.22 0.02 275 / 0.08)"
  3: "0 12px 24px oklch(0.22 0.02 275 / 0.10), 0 4px 8px oklch(0.22 0.02 275 / 0.06)"
  4: "0 24px 48px oklch(0.22 0.02 275 / 0.14), 0 8px 16px oklch(0.22 0.02 275 / 0.08)"
  focusRing: "0 0 0 2px {colors.surface}, 0 0 0 4px {colors.focus}"

motion:
  duration.fast: "120ms"
  duration.base: "200ms"
  duration.slow: "320ms"
  ease.standard: "cubic-bezier(0.2, 0, 0, 1)"
  ease.emphasized: "cubic-bezier(0.3, 0, 0, 1)"

breakpoints:
  mobile: "375px"
  tablet: "768px"
  desktop: "1280px"
  wide: "1536px"

components:
  button.primary:
    background: "{gradients.brand}"
    textColor: "{colors.text.onBrand}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "{spacing.3} {spacing.6}"
    minSize: "44px"
    elevation: "{elevation.1}"
  button.primary.hover:
    background: "{colors.brand.600}"
    elevation: "{elevation.2}"
  button.primary.active:
    background: "{colors.brand.700}"
    elevation: "{elevation.0}"
  button.primary.focusVisible:
    elevation: "{elevation.focusRing}"
  button.primary.disabled:
    background: "{colors.border}"
    textColor: "{colors.text.muted}"
    elevation: "{elevation.0}"
  button.secondary:
    background: "{colors.surface}"
    textColor: "{colors.text}"
    border: "1px solid {colors.border.strong}"
    rounded: "{rounded.md}"
    padding: "{spacing.3} {spacing.6}"
  button.ghost:
    background: "transparent"
    textColor: "{colors.text.muted}"
    rounded: "{rounded.md}"
    padding: "{spacing.2} {spacing.4}"
  button.destructive:
    background: "{colors.danger}"
    textColor: "{colors.text.onBrand}"
    rounded: "{rounded.md}"
    padding: "{spacing.3} {spacing.6}"
  input:
    background: "{colors.surface}"
    textColor: "{colors.text}"
    border: "1px solid {colors.border.strong}"
    rounded: "{rounded.md}"
    padding: "{spacing.3} {spacing.4}"
    minSize: "44px"
    typography: "{typography.body}"
  input.focusVisible:
    border: "1px solid {colors.focus}"
    elevation: "{elevation.focusRing}"
  input.invalid:
    border: "1px solid {colors.danger}"
  card:
    background: "{colors.surface.raised}"
    border: "1px solid {colors.border}"
    rounded: "{rounded.lg}"
    padding: "{spacing.6}"
    elevation: "{elevation.1}"
  dialog:
    background: "{colors.surface.raised}"
    rounded: "{rounded.xl}"
    padding: "{spacing.8}"
    elevation: "{elevation.4}"
    maxWidth: "32rem"
  toast:
    background: "{colors.surface.raised}"
    rounded: "{rounded.md}"
    padding: "{spacing.4}"
    elevation: "{elevation.3}"
  badge:
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.1} {spacing.3}"
  table.cell:
    typography: "{typography.bodySm}"
    padding: "{spacing.3} {spacing.4}"
    border: "1px solid {colors.border}"
---

# Design System

## Overview

Modern SaaS, vibrant but disciplined. The product should feel fast, current, and confident — a saturated violet→teal brand gradient used sparingly against calm neutral surfaces. Energy comes from **one** gradient, generous radii, and soft layered shadows; everything else stays quiet so the data stays readable.

The rule that keeps "vibrant" from becoming "loud": **colour is a signal, not decoration.** If a surface is coloured, it is because something on it is actionable or needs attention. A screen has at most one gradient element.

Light and dark are equal first-class themes, not an inversion. Every token exists in both. Ship neither until both pass contrast.

## Colors

- `brand.500` is the identity colour; `brand.600` is the *interactive* colour, because `500` on white does not clear 4.5:1 for text. **Never put text on `brand.500` in light mode.**
- `accent.500` (teal) exists almost exclusively as the far stop of `gradients.brand`. It is not a second brand colour and must not be used to colour standalone controls.
- Semantic colours (`success` `warning` `danger` `info`) never carry meaning alone — always pair with an icon and text. Colour-blind users must lose nothing.
- Dark mode lifts brand lightness (`0.62 → 0.72`) rather than darkening surfaces further: saturated hues at low lightness vibrate against dark backgrounds.
- **Contrast floor (enforced by the linter):** body text ≥ 4.5:1, large text (≥ 18.66px bold / 24px) ≥ 3:1, UI borders and icons ≥ 3:1, focus ring ≥ 3:1 against **both** the component and the surrounding surface.

## Typography

Inter for everything, JetBrains Mono for code, IDs, and anything the user might copy. One family keeps the vertical rhythm predictable and removes a whole class of layout bugs.

- Scale is fixed at 8 steps. If you need a size that isn't in the scale, you need a different component.
- Negative letter-spacing tightens as size grows (`display` −0.03em → `body` 0). This is what makes large headings look designed rather than merely large.
- Line length caps at **72ch** for prose, **48ch** in cards.
- Numbers in tables, prices, and metrics use tabular figures (`font-variant-numeric: tabular-nums`) so columns don't jitter on update.
- Weight, not colour, carries hierarchy. `text.muted` is for genuinely secondary content, never for "smaller heading".

## Layout

- 4px base grid. Every padding, gap, and margin comes from `spacing`. No arbitrary `13px`.
- 12-column fluid grid, `spacing.6` gutters desktop, `spacing.4` mobile. Page max-width 1280px, content column 1120px.
- **Vertical rhythm:** `spacing.4` inside a component, `spacing.6` between components, `spacing.12` between sections.
- Mobile-first. Three breakpoints, and layout must be correct at 375 / 768 / 1280 — the same three viewports the Playwright suite runs.
- Touch targets ≥ 44×44px at every breakpoint, including desktop (people use touchscreens on desktop).
- Never hide content to fit a small screen — reflow, stack, or progressively disclose it.

## Elevation & Depth

Five levels, and each has one job:

| Level | Use |
|---|---|
| 0 | flush content, pressed states |
| 1 | cards, resting buttons |
| 2 | hover on an interactive surface |
| 3 | popovers, dropdowns, toasts |
| 4 | modals, command palette |

Shadows are tinted with the text hue, never pure black — pure black shadows read as dirt on coloured surfaces. In dark mode, shadows do little work; depth comes from `surface.raised` being *lighter* than `surface`. Do not stack elevations: a card inside a modal stays at 0.

## Shapes

- Radii step with size: controls `md` (12px), cards `lg` (16px), modals `xl` (24px), pills/avatars `full`.
- **Nested radius rule:** inner radius = outer radius − padding. A `lg` card with `spacing.6` padding holds `md` children. Concentric corners are the tell that separates a designed UI from an assembled one.
- Borders are 1px `border` for structure, `border.strong` for anything interactive. Border *and* elevation together only for level 3+.

## Components

Built on shadcn/ui (Radix primitives, source-owned in `src/components/ui/`). Radix gives correct focus management, ARIA, and keyboard behaviour for free — **do not** hand-roll a dialog, combobox, or menu.

Rules for every component:
- Ships with all states: default, hover, active, **focus-visible**, disabled, loading, error, empty.
- Focus ring is `elevation.focusRing` on every focusable element. Never `outline: none` without an equivalent replacement.
- Loading uses skeletons shaped like the eventual content, not spinners — spinners only for actions under 1s.
- Empty states explain what goes here and give the action that fills it.
- Errors say what happened and what to do next, next to the field that caused it, and are announced via `aria-live`.
- Destructive actions require confirmation naming the exact object being destroyed.
- Any component rendering PII/PHI/CHD must mask by default (`•••• 4242`) with explicit reveal, and must never be included in analytics or session-replay capture.

## Do's and Don'ts

**Do**
- Take every value from the token block; generate Tailwind config from it.
- Test both themes and all three viewports before calling a UI change done.
- Animate `transform` and `opacity` only, with `motion.duration.base`, and respect `prefers-reduced-motion`.
- Use semantic HTML first — Radix second, `div` last.
- Label every icon-only control with `aria-label`.

**Don't**
- Don't add a colour, size, radius, or shadow that isn't in the tokens. Extend the token block via PR instead.
- Don't use more than one gradient per screen, or a gradient behind body text.
- Don't convey state with colour alone.
- Don't use placeholder text as a label — it disappears exactly when the user needs it.
- Don't put disabled buttons behind unexplained rules; say what unlocks them.
- Don't nest elevations, or mix `md` and `lg` radii on sibling elements.
- Don't ship a component without a focus-visible state — axe won't catch it, reviewers must.
