
# Dev Notes - 2026-03-05

## What Changed Today

### Game state snapshots
- Added generalized snapshot API in `game/GameLogic.gd`:
  - `create_game_snapshot(exclude_player_id := -1)`
  - includes: `ongoing`, `current_player`, `direction`, `draw_stack`, `top_card`, `players[{id, hand_count}]`
- Optimized `create_player_snapshot(player_id)` to reuse `create_game_snapshot(player_id)` and only append private player hand data.
- Added `_create_players_snapshot(exclude_player_id := -1)` helper to remove duplicate snapshot-building logic.
- Snapshot top-card now uses the actual top of discard pile (`last`) with an empty-pile guard.

### Networking / RPC payloads
- Server now attaches fresh generalized game snapshots to action payloads (`PLAY`, `DRAW`, `SKIP`) in `network/ServerController.gd`.
- Updated draw broadcast behavior:
  - Drawer receives full draw payload with private `cards`.
  - Other players receive a sanitized payload (no private cards), plus:
    - `player` (who drew)
    - `draw_count`
    - `game` snapshot
- Added `draw_count` field in `game/GameLogic.gd` draw result.

### Client event payloads
- Updated `network/ClientController.gd` signals/RPC propagation:
  - `on_cards_played(player_id, cards, game_snapshot)`
  - `on_cards_drawn(result)`
  - `on_turn_skipped(result)`

### GameManager sync flow
- In `core/game_manager.gd`, implemented snapshot-driven UI synchronization:
  - `_sync_game_snapshot(snapshot)` updates current-turn HUD state and opponent hand counts.
- Added local draw visualization support:
  - `_add_cards_to_client_hand(cards)` and wiring in `_on_cards_drawn(result)`.
- Play/skip handlers now consume snapshot payloads to keep HUD state consistent.
- Fixed draw request flow from UI:
  - `_on_draw_requested()` now calls `client_controller.request_draw()`.

### Hand helpers
- Added `add_cards(card_views)` in `card/hand/hand.gd` for appending new card views to a hand.

### Opponent placeholder utility
- Added reusable helper in `core/game_manager.gd`:
  - `_create_placeholder_cards(amount)`
- `_create_opponent_hand(...)` now uses that helper for initial opponent hand setup.

## Remaining Work / TODO

### Opponent draw visualization
- Implement opponent-side placeholder card addition when another player draws.
- Use `result.draw_count` from `_on_cards_drawn(result)` to append placeholder/back-facing card views to the correct opponent hand.
- Optionally animate draw from draw pile to opponent hand.

### Snapshot consistency and guards
- Add explicit guards where needed (null/empty payload checks, missing keys, bounds checks).
- Ensure handlers remain resilient if snapshot fields are absent during transition periods.

### Turn / gameplay UX
- Evaluate whether top-card visual should also be resynced from `game.top_card` for non-play events when needed.
- Review turn manager integration (`_turn_manager.start(...)` is still commented).

### Validation
- Run multiplayer end-to-end test pass for:
  - Play flow
  - Draw flow (drawer vs non-drawers)
  - Skip flow
  - HUD turn/hand-count correctness across all clients
