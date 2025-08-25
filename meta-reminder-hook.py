#!/usr/bin/env python3
import json
import sys
import re

# Load input from stdin
try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
    sys.exit(1)

prompt = input_data.get("prompt", "")

# Check if prompt involves markdown editing or spec writing
markdown_patterns = [
    r"(?i)\b(edit|update|write|create).*\.md\b",
    r"(?i)\b(spec|overview|documentation).*edit",
    r"(?i)\btodo.*\.md\b",
    r"(?i)\bmarkdown.*edit"
]

for pattern in markdown_patterns:
    if re.search(pattern, prompt):
        # Add reminder context that Claude will see
        print("\nReminder: When editing markdown specs, consult meta.md for writing guidelines (succinctness, zero repetition, clear sections).\n")
        break

# Continue processing normally
sys.exit(0)