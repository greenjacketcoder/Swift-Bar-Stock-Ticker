# Swift-Bar-Stock-Ticker
macOS menu-bar market ticker (SwiftBar). Single-file Bash with no extra installs. Colors price green/red vs previous close. Data source pluggable (Finnhub by default).

## Quick Install (this Mac)
```bash
# Put your Finnhub token in env and install to SwiftBar:
FINNHUB_TOKEN=YOUR_KEY \
bash -c 'curl -fsSL https://raw.githubusercontent.com/<YOUR_USERNAME>/<YOUR_REPO>/main/plugins/finnhub_updown_simple_nodeps.30s.sh \
  -o ~/Library/Application\ Support/SwiftBar/Plugins/finnhub_updown_simple_nodeps.30s.sh && \
  chmod +x ~/Library/Application\ Support/SwiftBar/Plugins/finnhub_updown_simple_nodeps.30s.sh && \
  open -a SwiftBar'
