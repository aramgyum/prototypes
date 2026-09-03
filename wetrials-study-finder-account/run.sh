#!/usr/bin/env bash
# WeTrials embed account-access prototype — two origins on one machine.
#
#   ./run.sh            serve on 127.0.0.1 (this machine only)
#   ./run.sh --lan      serve on 0.0.0.0 too, so you can open it on your phone
#
# The SAME index.html is served twice. Port 5180 behaves as the partner site,
# port 5181 as portal.wetrials.com. Different ports are different origins, so
# the handoff, the fragment ticket and the per-origin storage are all real.
set -euo pipefail
cd "$(dirname "$0")"

BIND=127.0.0.1
[[ "${1:-}" == "--lan" ]] && BIND=0.0.0.0

cleanup() { kill 0 2>/dev/null || true; }
trap cleanup EXIT INT TERM

python3 -m http.server 5180 --bind "$BIND" >/dev/null 2>&1 &
python3 -m http.server 5181 --bind "$BIND" >/dev/null 2>&1 &
sleep 1

echo
echo "  Partner site   http://localhost:5180"
echo "  WeTrials portal http://localhost:5181   (you should not need to open this directly)"
if [[ "$BIND" == "0.0.0.0" ]]; then
  IP=$(ipconfig getifaddr en0 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')
  echo
  echo "  On your phone (same wifi):  http://$IP:5180"
  echo "  NOTE: the portal origin is derived from the host you open, so use the IP, not localhost."
fi
echo
echo "  Start at the partner site. Ctrl-C to stop."
echo

wait
