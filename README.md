# Elitis Express · Menu à bord

QR seat ordering for Elitis Express buses (menu: Hôtels Tanoudja). Built by TIBLOGICS.

Travelers scan the QR code on the back of the seat in front of them, pick their seat on the bus map (window / aisle), order from the menu and get an order QR code. The hostess scans that code and gets the order, sorted by seat number.

No login, no server, no database. The order is stored inside the QR code itself, so it works even with poor network on the road.

## Links (replace `BASE` with the GitHub Pages address)

| Screen | Link | Use |
|---|---|---|
| Traveler, seat preselected | `BASE/?s=12` | Printed on each seat back |
| Traveler, choose seat | `BASE/` | Generic QR code (station, ticket) |
| Hostess | `BASE/?mode=hotesse` | Scan rounds ("tournées"): scan many travelers in a row, then get the station summary (what to prepare + what to deliver per seat). Also "à servir / à préparer / servies", paid/served, cash total |
| Admin | `BASE/?mode=admin` | Print the sheet of seat QR codes + hostess QR code |

Add `&b=12` to any link to set the bus number.

## Traveler experience

- Welcome screen "Bienvenue à bord d'Elitis Express" with confetti, then the menu unrolls.
- French by default, English with the FR/EN button (or `?lang=en` in the link). Hostess and admin screens stay in French.
- "Propulsé par TIBLOGICS / Powered by TIBLOGICS" on every screen. Add `tiblogics-logo.png` at the root to show the logo instead of the wordmark.

## Seat selection

Travelers can browse the menu freely. The first time they tap "+", a seat picker opens (bottom sheet, 60 seats by default, window/aisle filter). Nothing is added until a seat is confirmed. Travelers arriving from a seat-back QR code (`?s=12`) skip this step.

## Show the hostess

Once items are in the cart, a **Hôtesse** QR button sits next to the cart bar, and the order screen's main button is **Montrer à l'hôtesse**. It opens the selection with its QR code (seat required). **Afficher en grand** (or tapping the QR) shows a full-screen white QR for easy scanning, and the screen is kept awake where supported.

## Menu du jour synced to all travelers (Supabase)

When configured, the menu confirmed by the hostess is published online and applies automatically to every traveler of that bus (loaded on open, refreshed every minute and when the phone wakes). Sold-out items already in a cart are removed with a message.

**One-time setup (about 10 minutes, free plan):**
1. Create a project on supabase.com.
2. SQL Editor > New query > paste `supabase.sql` > Run.
3. Set the hostess PIN: `update public.app_secrets set v = 'YOUR-PIN' where k = 'hostess_pin';`
4. Project Settings > API: copy the Project URL and the anon / publishable key into `config.js` (edit it directly on GitHub). No rebuild needed.

**Bus number:** each bus has a number (`?b=12` in links). The admin page puts it in every seat QR code and the hostess QR code. The hostess sees it (and the PIN field) on the Menu du jour screen. Each bus has its own menu du jour.

Without `config.js` values, the app works offline as before (shareable link / QR fallback).

## Menu du jour (daily availability)

- Each day, before the first scan, the hostess must confirm the "Menu du jour" (switches per item and per size/option). Scanning is blocked until it is confirmed.
- After confirming, she gets a link and QR code (`?d=YYYY-MM-DD&off=...`) to share (WhatsApp, copy). Travelers who open it see sold-out items greyed out ("Épuisé").
- Any order containing a sold-out item is flagged when scanned and in the round summary.
- Automatic sync to every traveler's phone needs the online database (full version).

## One traveler per seat

- **Seat-back QR code locks the seat:** a traveler arriving with `?s=12` cannot switch to another seat.
- **Duplicate alert for the hostess:** if two different orders arrive for the same seat, both are flagged in red so she checks the tickets and deletes the wrong one.
- Editing an order keeps the same order code, so a re-scan updates the order instead of creating a duplicate.
- Real-time blocking across phones (a taken seat greyed out for everyone) needs a shared online database: planned for the full version.

## Seat numbering (Elitis bus, 50 seats)

- 12 rows on the left (2 seats: window, aisle), 11 rows on the right: the middle-door row has no seats on the right.
- Each row: left window, left aisle, right window, right aisle (1 2 | 4 3).
- Back row: 4 seats numbered left to right, 47 48 49 50.
- The door row is set by `LAYOUT.doorRow` in `src/app.html` (currently 7), or per link with `?porte=7`. The admin page has a field for it.

| Row | Seats |
|---|---|
| 1 to 6 | 1 to 24 |
| 7 (door) | 25, 26 (left only) |
| 8 to 12 | 27 to 46 |
| Back | 47 48 49 50 |

## Editing

- **Menu, prices, seat count, company name:** edit `src/app.html` (the `MENU` list and the config constants at the top of the script), then run `python3 build.py` to regenerate `index.html`.
- **Brand colors:** the 4 CSS variables at the top of `src/app.html` (`--navy`, `--navy2`, `--amber`, `--amber-d`).
- **Logo:** add the official logo as `logo.png` at the root of the repo. It appears automatically (a fallback "E" badge shows until then).

`index.html` is self-contained (QR generator and scanner libraries are inlined), so it is the only file GitHub Pages needs.

## Known limits (pilot version)

- Hostess orders are saved only on her phone (browser storage).
- No live shared seat occupancy yet (see "One traveler per seat" above for the current safeguards).
- Camera scanning requires HTTPS (GitHub Pages provides it). Manual code entry is available as a fallback.

The multi-company version (all bus companies in Burkina Faso) will need a backend: companies, buses, trips, menus, reports.

## Libraries

- [qrcode-generator](https://github.com/kazuhikoarase/qrcode-generator) (MIT)
- [jsQR](https://github.com/cozmo/jsQR) (Apache-2.0)
