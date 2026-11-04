"""Assemble index.html from src/app.html + inlined QR libraries (no internet needed at runtime)."""
from pathlib import Path
root = Path(__file__).parent
app = (root / "src/app.html").read_text(encoding="utf-8")
libs = (root / "src/lib/qr.min.js").read_text(encoding="utf-8") + "\n;" + (root / "src/lib/jsqr.min.js").read_text(encoding="utf-8")
(root / "index.html").write_text(app.replace("/*LIBS*/", libs), encoding="utf-8")
print("index.html rebuilt")
