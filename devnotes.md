TODO ------------------------------------------------

## [ ] ****BUG**** Hue selection may get stuck during flow and prevent GameManager from advancing playing logic.

TODO ------------------------------------------------

## [ ] Fix selection logic not properly updating the available cards
- This could be due to either failure on `game_manager.gd` logic handling it or updates not being handled correctly in `hand.gd`.
- Also, cards that were selected and are should behave differently when selected and available.

TODO ------------------------------------------------

## [ ] Implement `draw_pile.gd` reaction to `_draw_stack` changes.
- This involves updating the UI to reflect the new state of the draw pile after a card is drawn.

TODO ------------------------------------------------

## [ ] Finish animation when playing card inside `discard_pile.gd`, current it uses a similar to desired but need tweaking.

TODO ------------------------------------------------

## [ ] Finish the hue selection flow. Animations + completion.
