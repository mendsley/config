import json, sys

try:
    data = json.load(sys.stdin)
    model = data["model"]["display_name"]
    pct = int(data.get("context_window", {}).get("used_percentage", 0) or 0)
    total = data.get("context_window", {}).get("context_window_size", 0) or 0
    total_k = total // 1000
    print(f"{model} {pct}% of {total_k}k")
except:
    print("Claude Code")
