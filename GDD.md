# 🌙 Midnight Runner
## Game Design Document

> *"How deep does the midnight go?"*

---

# Overview

**Genre:** Swipe-based Idle RPG / Endless Runner Hybrid
**Platform:** iOS (primary), Android (future)
**Target Session:** 2-5 minutes (commute-friendly)
**Monetization:** Premium ($2.99) or Free + IAP cosmetics
**Dev Timeline:** 6-8 weeks solo

---

# High Concept

Every night at midnight, the veil between worlds thins. You are a Runner — someone who discovered they can slip through the cracks and explore what lies beneath.

The deeper you go, the stranger it gets. The monsters get weirder. The rewards get better. But the midnight only lasts so long.

**Core Fantasy:** Discovering what lurks in the spaces between reality, one run at a time.

---

# Core Loop

```
┌─────────────────────────────────────────┐
│                                         │
│   START RUN → SWIPE TO DODGE/ATTACK     │
│        ↓                                │
│   COLLECT FRAGMENTS (currency)          │
│        ↓                                │
│   GO DEEPER (difficulty scales)         │
│        ↓                                │
│   DIE or EXTRACT                        │
│        ↓                                │
│   SPEND FRAGMENTS → UPGRADE             │
│        ↓                                │
│   UNLOCK NEW DEPTHS                     │
│        ↓                                │
│   (repeat)                              │
│                                         │
└─────────────────────────────────────────┘
```

---

# Gameplay Mechanics

## Running & Swiping

- **Auto-run:** Character runs forward automatically
- **Swipe Left/Right:** Dodge obstacles, change lanes
- **Swipe Up:** Jump
- **Swipe Down:** Slide
- **Tap:** Attack (when monster in range)
- **Hold:** Shield/Block (costs stamina)

## Combat

Monsters appear in your path. You have split-second choices:
- **Dodge** — Safe, no reward
- **Attack** — Risk/reward, earn bonus fragments
- **Counter** — Perfect timing = massive damage + style points

### Monster Types
| Type | Behavior | Counter Window |
|------|----------|----------------|
| Shades | Lunge at you | Wide (beginner-friendly) |
| Wraiths | Phase in/out | Medium |
| Abyssals | Telegraphed slam | Tight |
| Bosses | Patterns to learn | Varies |

## Depth System

The "Depth" is how far into the midnight you've gone.

- **Depth 1-10:** Tutorial zone, Shades only
- **Depth 11-50:** Wraiths introduced, environment shifts
- **Depth 51-100:** Abyssals, reality glitches
- **Depth 100+:** Endless scaling, procedural horrors

Each depth milestone unlocks:
- New monster types
- New environments
- Lore fragments
- Cosmetics

## Extraction vs Death

At any point, you can **Extract** to bank your fragments safely.

**Die:** Lose 50% of current run's fragments
**Extract:** Keep 100%, but run ends

Creates tension: "Do I push one more depth or extract now?"

---

# Progression Systems

## Fragments (Primary Currency)

Earned by:
- Distance traveled
- Monsters defeated
- Depth milestones
- Daily bonuses

Spent on:
- Permanent stat upgrades
- New abilities
- Cosmetics

## Upgrades

| Upgrade | Effect | Max Level |
|---------|--------|-----------|
| Vitality | +Max HP | 20 |
| Reflexes | +Counter window | 15 |
| Greed | +Fragment gain | 25 |
| Endurance | +Stamina | 15 |
| Insight | +Monster telegraph time | 10 |

## Unlockables

- **Runners:** Different characters with unique abilities
- **Trails:** Visual effect behind runner
- **Masks:** Cosmetic face coverings
- **Lore Pages:** Collectible story fragments

---

# Meta Systems

## Daily Challenges

- "Reach Depth 30 without taking damage"
- "Defeat 50 Wraiths"
- "Extract with 1000+ fragments"

## Weekly Boss

Special boss appears once per week. Defeating it grants unique cosmetic.

## Leaderboards

- Deepest run (all-time)
- Deepest run (weekly)
- Highest fragments (single run)

---

# Narrative & World

## Tone

- **Mysterious** — Never fully explained
- **Eerie** — Unsettling but not scary
- **Melancholic** — Sense of loss, searching for something

## Lore Delivery

- Environmental storytelling (background details)
- Lore fragments (collectible text snippets)
- Monster descriptions (unlocked on defeat)
- No cutscenes, no dialogue — all ambient

## The Midnight

What is it? Never explicitly stated. Theories the player might form:
- Collective unconscious
- Space between dimensions
- Afterlife's waiting room
- Dream layer
- Time's shadow

---

# Visual Style

## Aesthetic

- **Silhouette-heavy** — Runner is mostly black shape
- **Limited color palette** — Deep purples, midnight blues, occasional neon accent
- **Parallax depth** — Multiple background layers create depth
- **Particle effects** — Fragments sparkle, monsters dissolve

## Reference Games
- Alto's Odyssey (mood, flow)
- Limbo (silhouette aesthetic)
- Hollow Knight (mysterious world)
- Hades (satisfying combat feedback)

---

# Audio

## Music

- Ambient, pulsing synth
- Intensifies with depth
- Drops to near-silence at extraction points

## SFX

- Satisfying swipe sounds
- Crunchy impact on attacks
- Ethereal monster death sounds
- Heartbeat when low HP

---

# Technical Scope

## MVP Features (Weeks 1-4)

- [ ] Core swipe controls
- [ ] Auto-running with lanes
- [ ] Basic monster (Shade)
- [ ] Depth counter
- [ ] Fragment collection
- [ ] Death/Extract flow
- [ ] Basic upgrade shop
- [ ] Placeholder art

## Polish Features (Weeks 5-6)

- [ ] 3 monster types
- [ ] 3 environments
- [ ] Particle effects
- [ ] Sound design
- [ ] Final art pass
- [ ] Juice & feel

## Post-Launch

- [ ] Additional runners
- [ ] Weekly boss system
- [ ] Leaderboards
- [ ] More depths & monsters

---

# Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Controls feel bad | Paper prototype swipe feel early |
| Too easy/hard | Tune depth scaling with playtesting |
| No retention hook | Daily challenges + depth milestones |
| Scope creep | Strict MVP, cut aggressively |

---

# Success Metrics

- **Day 1 Retention:** >40%
- **Day 7 Retention:** >15%
- **Average Session:** 3+ minutes
- **Depth Reached (D7):** Average player hits Depth 50

---

# Next Steps

1. Paper prototype swipe controls
2. Greybox the core loop in SpriteKit
3. Test with 3 people
4. Iterate on feel
5. Art pass
6. Ship

---

*"The midnight waits. How deep will you go?"*
