"""
All the constants of the game.
"""

class_name Constants

enum ActionKey {UNBOUND, LEFT, MAIN, RIGHT}

enum ActionStatus {VERY_SOON, TOO_SOON, PERFECT, TOO_LATE, MISSED}

const AVAILABLE_STATUS = [ActionStatus.TOO_LATE, ActionStatus.PERFECT, ActionStatus.TOO_SOON]