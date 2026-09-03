# Study Finder account access — prototype

A clickable prototype of the flow in
`docs/superpowers/specs/2026-08-25-labrador-portal-account-access-design.md`,
built to settle the open design questions before any of it is written for real.

**This is a prototype, not a spike.** Nothing here touches Nunavut, genesis-express
or Mongo. Sign-in is faked. What it demonstrates is the *choreography* — what gets
saved before the handoff, what crosses between origins, what each origin can see,
and what the patient experiences.

## Run it

```bash
./run.sh            # → http://localhost:5180
./run.sh --lan      # also reachable from your phone on the same wifi
```

One `index.html`, served twice. **Port 5180 is the partner site, port 5181 is
`portal.wetrials.com`.** Different ports are different origins, so the redirect,
the fragment ticket and the per-origin storage isolation are all genuine — not
simulated. Open **5180** and start there.

Opened any other way (a `file://` path, a published page), it falls back to a
simulated mode: same screens, same steps, but the navigation is an in-page swap
with a visible address strip, because a single origin can't be two.

## What to look at

| | |
| --- | --- |
| **Sign in** (top right) | Saves widget state, navigates the tab to the portal, comes back with a one-time ticket in the URL **fragment**, restores state, shows the name. Watch the address bar: the ticket is stripped before you can read it. |
| **The account sheet** | Tap the avatar. Deep links open the portal with a "Back to partnerhealth.org" affordance throughout. |
| **"I'm interested"** | Signed out, the enroll wizard still works — the portal's `/enroll` is a public route and must stay that way. Signed in, it starts at step 1 instead of a login wall. That difference is the main conversion argument. |
| **ENTRY A / B / C / D** (bottom left) | The one demo control, not product UI. Switches the account entry point. This is decision #1. |
| **Sign out** | Resets it so you can run the whole thing again in front of people. |

### The four entry options

| | Signed out | Signed in | The trade |
| --- | --- | --- | --- |
| **A** Split row | Separate "Sign in" button beside a shrunk page pill | Avatar in the same spot | Unambiguous, but two competing controls in one row and the page label truncates first on 360px |
| **B** Unified pill | "Sign in" inside the pill, after a divider | Avatar takes that segment | Reads as one component; ~61px of width; two tap targets that look like one object |
| **C** Sheet only | Nothing in the header — account lives under the three pages in the Switch Page sheet | Nothing in the header | No new chrome at all, but signed-in state is never on screen and everything is two taps deep |
| **D** CTA banner | A slim dark bar above the switcher: "Track your trial requests · Sign in · Create account" | Bar disappears, avatar takes the pill segment (same as B) | Much the strongest invitation, and free once signed in — but it costs ~56px above the fold for every visitor who never signs in, and banners invite banner-blindness |

| **E** Bottom tab bar | Three tabs — Study Finder / Learning / Support — pinned to the bottom **on mobile only**. The header keeps Sign in; the pill loses its chevron there because navigation has moved | Same bar, avatar in the header | The only option that fixes discoverability of Learning Center and Support, which are currently invisible behind a pill nobody taps. Costs 62px of screen, and the bar is not always on screen (see below) |

### E and the container problem

The bar is **`position: sticky`, not `position: fixed`** — that is the whole design.
A fixed bar would hover over the partner's own footer and content, because the widget
does not own the viewport, it is a block inside someone else's document. Sticky pins it
to the bottom of the screen **while the widget is in view**, and parks it at the end of
the widget when you scroll past. The prototype now includes a Partner Health footer
specifically so you can scroll down and watch it park rather than cover.

The honest cost: it is not an app tab bar. Scroll past the widget and it is gone. That
is correct behaviour for an embed, and it is weaker than what a native tab bar buys you.
If a partner gives the widget its own full page (the `basePath` case in the setup guide),
a fixed bar would be legitimate — which argues for a declared `layout: 'page' | 'inline'`
rather than one behaviour for everyone.

C's dropdown button carries a **user glyph** (an avatar once signed in) so the account
is discoverable at all, and the sheet's account block is a highlighted card with both
Sign in and Create account rather than a plain menu row. Without those two things C
isn't a fair comparison — nothing on screen would suggest an account exists.

D is worth looking at closely because it is the only option that separates the two jobs:
inviting a stranger, and serving someone who is already in. A and B use one control for
both, which is why their signed-out state is a weak invitation.

The **hamburger** in the Partner Health header is the partner's own menu, not the
widget's. It's there so the embed is judged in a realistic frame — tapping it says so.

## The bit that matters most

Two session facts, and neither crosses an origin:

- **The portal's own session** — stands in for its `httpOnly` cookie. Authenticates
  all real work, in the portal's own tab.
- **The widget's session** — display identity only: a name and initials. No request
  counts, no messages, nothing clinical. It never leaves `sessionStorage` on the
  partner's origin and it dies with the tab.

In the two-port setup you can prove this: sign in, then in DevTools on port 5180
try to read the portal's session. It isn't there. That is the whole security
argument for this design, and it is checkable rather than asserted.

## Responsive

One codebase, no separate mobile and desktop builds — it reflows. Checked at
**360, 390, 768, 1024 and 1440**, on every screen (both entry states of all four
options, the account panel, study detail, enroll, requests), for horizontal
overflow, script errors and sub-44px tap targets. All clean.

There are two breakpoints, not one:

- **768px** — the header becomes a single row (pill · search · account) and every
  control in it is exactly **52px** tall. Below this it stacks. This is what stops an
  iPad rendering "Sign in" stranded on its own row above the search.
- **1024px** — the body splits into filter rail + results.

The desktop layout follows the **shipped** widget, not an invention:

- Page pill and search bar share **one row**, pill ~280px on the left, search filling
  the rest. No filter button beside the search — filters live in the rail.
- Results sit beside a **320px filter rail** (Filter / Condition / Location / Study
  Type / Study Status / Sex), each section its own card. The rail is static; it's
  there so the widget is judged in its real shape rather than as a bare list.
- The conditions block runs **horizontally** on desktop (label cell, then chips) and
  stacks on mobile.

What else changes across the breakpoint (1024px):

- The account panel is a **bottom sheet** on mobile and a **dropdown anchored under
  the avatar** on desktop.
- **The account control moves to the end of the header row on desktop**, which means
  A, B and D converge there and only really differ on mobile. That is worth saying
  out loud when you compare them: the entry-option decision is a mobile decision.
- Full-width buttons stop being full width above 1024 — they'd be 1000px otherwise.
- "I'm interested" opens a **new tab** on desktop and navigates the **same tab** on
  mobile, which is the behaviour split the design argues for.

One thing that looks like a bug and isn't: at 360px in **option A** the page label
truncates to "Study Fi…". That is option A's documented weakness — two controls
competing for one row — and the prototype is showing it rather than hiding it.

## Where it will and won't run

It works in a plain browser, from `file://`, inside a sandboxed `srcdoc` preview
pane, and with site storage blocked. The History API and `sessionStorage` are both
probed once at boot and shimmed with in-memory equivalents if they throw — a
prototype that dies in a preview pane can't be shown to anyone.

The consequence in those stricter contexts: the browser Back button won't step
through the flow, because there are no real history entries to step through. The
in-page back and close controls all still work.

## Known simplifications

- Sign-in is a button, not OAuth. The real flow adds Nunavut's authorize/token
  round trip in the middle of step 2 — it changes the timing, not the shape.
- The ticket is base64 JSON, not signed or single-use. In the real design it is
  32 random bytes, server-side, 60-second TTL, redeemable once.
- The origin allowlist is a hardcoded array. In the real design it comes from
  `ApiKey.restrictions.application.websites`. You can see it work: open the portal
  with a `ret` value that isn't allowed and the sign-in button refuses.
- Desktop uses the same redirect as mobile. Whether desktop keeps a popup instead
  is still open (decision #3).
- The unread badge is shown. Whether it ships in phase one is still open
  (decision #1) — it is clinical-adjacent data on a third party's page.
