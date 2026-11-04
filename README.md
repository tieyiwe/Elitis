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

Add `&n=54` to any link to set the number of seats (default 54).

## Traveler experience

- Welcome screen "Bienvenue à bord d'Elitis Express" with confetti, then the menu unrolls.
- French by default, English with the FR/EN button (or `?lang=en` in the link). Hostess and admin screens stay in French.
- "Propulsé par TIBLOGICS / Powered by TIBLOGICS" on every screen. Add `tiblogics-logo.png` at the root to show the logo instead of the wordmark.

## One traveler per seat

- **Seat-back QR code locks the seat:** a traveler arriving with `?s=12` cannot switch to another seat.
- **Duplicate alert for the hostess:** if two different orders arrive for the same seat, both are flagged in red so she checks the tickets and deletes the wrong one.
- Editing an order keeps the same order code, so a re-scan updates the order instead of creating a duplicate.
- Real-time blocking across phones (a taken seat greyed out for everyone) needs a shared online database: planned for the full version.

## Seat numbering

Left side: 1 window, 2 aisle. Right side: 3 window, 4 aisle. Then 5 to 8 on row 2, and so on.

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
