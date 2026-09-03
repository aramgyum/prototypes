# Study Finder — portal account access

A clickable prototype of signing in to the WeTrials patient portal from inside the
embedded Study Finder widget, without losing the partner's page.

**[Open the prototype](./index.html)**

Design spec it belongs to: `2026-08-25-labrador-portal-account-access-design.md`
(in the WeTrials monorepo under `docs/superpowers/specs/`).

## Run it

```bash
./run.sh          # → http://localhost:5180
./run.sh --lan    # also reachable from a phone on the same wifi
```

One `index.html`, served twice. **Port 5180 is the partner site, 5181 is
`portal.wetrials.com`.** Different ports are different origins, so the redirect, the
one-time ticket in the URL fragment, and the per-origin storage isolation are all
genuine rather than simulated. Start at 5180.

Opened any other way — a `file://` path, a single-host deploy, a preview pane — it
falls back to a simulated mode: same screens and steps, but the navigation is an
in-page swap with a visible address strip, because one origin cannot be two.

## Deploying it

Hosting this at a single URL (GitHub Pages, one Netlify site) gives you the
**simulated** mode. Paths don't make new origins — only hostnames do.

For the real thing, host the same file at two hostnames and fill in `DEPLOY` at the
top of `index.html`:

```js
const DEPLOY = {
  partner: 'https://wt-partner.pages.dev',
  portal:  'https://wt-portal.pages.dev',
};
```

Two Cloudflare Pages projects, or any two subdomains, will do. Nothing else changes.

## What to look at

| | |
| --- | --- |
| **Sign in** | Saves widget state, hands off to the portal, returns with a one-time ticket in the URL **fragment**, restores state. Watch the address bar — the ticket is stripped before anything can read it. |
| **ENTRY A/B/C/D/E** (bottom left) | The one demo control, not product UI. Five ways the account can live in the widget. This is the open design decision. |
| **"I'm interested"** | Works signed out; signed in it skips the login wall and starts at step 1. That gap is the conversion argument. |
| **Version E** | Bottom tab bar, mobile only, `position: sticky` not `fixed` — scroll to the partner footer and watch it park rather than cover. |

Full notes, trade-offs and known simplifications: [README-notes.md](./README-notes.md).
