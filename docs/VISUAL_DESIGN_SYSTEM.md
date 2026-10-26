# Visual Design System & Branding Specification

**Project:** Enterprise Global Business Analytics — 3M Synthetic Transactions  
**Theme:** Premium Enterprise Corporate Light Theme  
**Theme JSON:** [`powerbi/theme/enterprise-light-theme.json`](../powerbi/theme/enterprise-light-theme.json)  
**Source Data Download Link:** [Download 3M Source Data from Google Drive](https://drive.google.com/file/d/1qT-9U-xVM0GlPSyNEoaroIBIA8X05CmK/view?usp=sharing)  

---

## 1. Brand Philosophy & Art Direction

The visual design system reflects a top-tier executive analytics platform:
- **Tone:** Authoritative, clean, modern, and accessible.
- **Background Architecture:** 
  - **Left Persistent Sidebar (18% width):** Deep corporate navy (`#061B3A` to `#0A2854`) featuring an illuminated 3D digital Earth network globe at the bottom-left corner.
  - **Main Dashboard Canvas (82% width):** Crisp, spacious near-white canvas (`#F7FAFE`) with subtle pale-blue wave accents, leaving generous white space for live Power BI visual containers.
  - **No Baked-in Text:** The canvas background (`assets/backgrounds/Futuristic Blue Earth Dashboard Background.png`) contains **zero pre-rendered text, logos, or icons**, allowing crisp Power BI native fonts and interactive navigation buttons.

---

## 2. Design Tokens & Color Palette

| Token Name | Hex Code | Swatch | Application & Visual Hierarchy |
|---|---|---|---|
| `navy-950` | `#061B3A` | Dark Navy | Primary sidebar base, callout text, brand header |
| `navy-900` | `#0A2854` | Deep Navy | Sidebar secondary gradient, primary data series |
| `blue-600` | `#1769E0` | Electric Blue | Active navigation pill, primary bar/line charts, key focus |
| `blue-500` | `#2588F5` | Vivid Blue | Secondary data series, map bubbles, interactive hyperlinks |
| `sky-100` | `#EAF4FF` | Soft Pale Blue | Visual card highlights, active slicer background |
| `canvas` | `#F7FAFE` | Canvas White | Report canvas base |
| `card` | `#FFFFFF` | Pure White | Visual container cards, dropdown slicer popups |
| `ink` | `#14243B` | Charcoal Ink | Primary body typography, axis text, table contents |
| `muted` | `#64748B` | Slate Gray | Subtitles, helper text, legend labels, disabled states |
| `border` | `#DFE7F2` | Hairline Blue | 1px card borders (Radius: 8px) |
| `success` | `#16A36A` | Emerald Green | Positive KPIs, delivered status, favorable variance |
| `warning` | `#E18A24` | Amber Orange | Processing status, threshold warnings, data alerts |
| `danger` | `#D94B5C` | Ruby Red | Cancelled status, negative financial variance |

---

## 3. Typography & Text Classes

All visuals adhere to the Windows standard corporate typeface:
- **Primary Font Family:** `Segoe UI Semibold, wf_segoe-ui_semibold, helvetica, arial, sans-serif`
- **Callout Numbers (KPI Cards):** `26pt Segoe UI Semibold`, Color: `#061B3A`
- **Section & Visual Titles:** `13pt Segoe UI Semibold`, Color: `#14243B`
- **Subtitles & Card Labels:** `10pt Segoe UI`, Color: `#64748B`
- **Table Data Cells:** `9pt Segoe UI`, Color: `#14243B`

---

## 4. Visual Container Specifications

To create a clean, floating aesthetic that stands out crisply over the subtle background:
- **Background Color:** `#FFFFFF` (100% opaque)
- **Border:** `1px solid #DFE7F2` with **8px corner radius**
- **Drop Shadow:** Custom soft shadow:
  - Color: `#061B3A` (92% transparency)
  - Blur: `6px`
  - Distance: `2px`
  - Angle: `90°`

---

## 5. Iconography Library

The project includes an exclusive suite of **65 named business analytics icons** located in `assets/icons/`:
- **Vector (SVG):** `assets/icons/svg/navy/` (for light cards) and `white/` (for navy sidebar)
- **Raster (PNG):** Transparent high-resolution PNG fallbacks in both navy and white

Icons represent: Total Orders, Units Sold, Revenue, Profit, Profit Margin, Delivered, Shipped, Processing, Cancelled, Country, Currency, Product, Date Range, Filter, Refresh, and page navigation targets.
