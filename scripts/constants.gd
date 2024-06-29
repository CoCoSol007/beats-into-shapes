"""
All the constants of the game.
"""

class_name Constants

enum ActionKey {UNBOUND, LEFT, MAIN, RIGHT}

enum ActionStatus {VERY_SOON, TOO_SOON, PERFECT, PERFECT_PLUS, TOO_LATE, MISSED}

const PERFECT_STATUS = [ActionStatus.PERFECT, ActionStatus.PERFECT_PLUS]
const AVAILABLE_STATUS = [ActionStatus.TOO_LATE, ActionStatus.PERFECT, ActionStatus.PERFECT_PLUS, ActionStatus.TOO_SOON]
const BAD_STATUS = [ActionStatus.VERY_SOON, ActionStatus.TOO_SOON, ActionStatus.TOO_LATE]
