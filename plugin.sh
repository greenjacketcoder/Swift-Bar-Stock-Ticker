#!/bin/bash
# <xbar.title>Finnhub Up/Down (Simple, No Extras)</xbar.title>
# <xbar.version>v1.2</xbar.version>
# <xbar.author>Your Name</xbar.author>
# <xbar.desc>Colors green if c > pc, red if c < pc. Finnhub /quote. ASCII-only output.</xbar.desc>
# <xbar.refreshTime>30s</xbar.refreshTime>

symbol="${SYMBOL:-AAPL}"
token="${FINNHUB_TOKEN:-REPLACE_WITH_YOUR_FINNHUB_TOKEN}"

if [[ -z "$token" || "$token" == "REPLACE_WITH_YOUR_FINNHUB_TOKEN" ]]; then
  echo "$symbol: N/A | color=gray"
  echo "---"
  echo "Missing FINNHUB token. Set FINNHUB_TOKEN in your environment."
  exit 0
fi

url="https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${token}"
resp_body="/tmp/finnhub_quote_${symbol}.json"

curl -sS -A 'Mozilla/5.0 (Macintosh; Intel Mac OS X) SwiftBar-Finnhub-Simple/1.2' "$url" -o "$resp_body" 2>/dev/null || true

if [[ ! -s "$resp_body" ]]; then
  echo "$symbol: N/A | color=gray"
  echo "---"
  echo "Empty response body. See $resp_body"
  exit 0
fi

if grep -q '"error"' "$resp_body"; then
  err="$(tr -d '\n' < "$resp_body" | cut -c1-200)"
  echo "$symbol: N/A | color=gray"
  echo "---"
  echo "$err"
  exit 0
fi

c_val="$(grep -oE '\"c\":[+-]?[0-9]+(\.[0-9]+)?' "$resp_body" | head -n1 | sed 's/.*://')"
pc_val="$(grep -oE '\"pc\":[+-]?[0-9]+(\.[0-9]+)?' "$resp_body" | head -n1 | sed 's/.*://')"
d_val="$(grep -oE '\"d\":[+-]?[0-9]+(\.[0-9]+)?' "$resp_body" | head -n1 | sed 's/.*://')"
dp_val="$(grep -oE '\"dp\":[+-]?[0-9]+(\.[0-9]+)?' "$resp_body" | head -n1 | sed 's/.*://')"

num_re='^-?[0-9]+([.][0-9]+)?$'
if ! [[ "$c_val" =~ $num_re && "$pc_val" =~ $num_re ]]; then
  echo "$symbol: N/A | color=gray"
  echo "---"
  echo "Could not parse c/pc. Raw: $(tr -d '\n' < "$resp_body" | cut -c1-160)..."
  exit 0
fi

if ! [[ "$d_val" =~ $num_re ]]; then
  d_val="$(awk -v c="$c_val" -v pc="$pc_val" 'BEGIN{printf("%.6f", c - pc)}')"
fi
if ! [[ "$dp_val" =~ $num_re ]]; then
  dp_val="$(awk -v c="$c_val" -v pc="$pc_val" 'BEGIN{ if (pc==0) printf("0"); else printf("%.6f", (c - pc)/pc*100) }')"
fi

c_txt="$(awk -v x="$c_val" 'BEGIN{printf("$%.2f", x)}')"
pc_txt="$(awk -v x="$pc_val" 'BEGIN{printf("$%.2f", x)}')"
d_txt="$(awk -v x="$d_val" 'BEGIN{printf("%+.2f", x)}')"
dp_txt="$(awk -v x="$dp_val" 'BEGIN{printf("%+.2f%%", x)}')"

cmp="$(awk -v c="$c_val" -v pc="$pc_val" 'BEGIN{print (c>pc)?1:((c<pc)?-1:0)}')"
color="gray"; indicator=""
if [[ "$cmp" == "1" ]]; then color="green"; indicator="UP"; fi
if [[ "$cmp" == "-1" ]]; then color="red"; indicator="DOWN"; fi

echo "${symbol}: ${c_txt} ${indicator} | color=${color}"
echo "---"
echo "Prev close: ${pc_txt} | color=gray"
echo "Delta: ${d_txt}  Percent: ${dp_txt} | color=${color}"
echo "Saved response: ${resp_body} | color=gray"
echo "Source: Finnhub /quote | color=gray"
