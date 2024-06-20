extends Node
class_name HoverManager

var children: Array # Array to hold the HoverButton instances for each child node
var self_ = self # Reference to self. Used if this script is used as a class instance

@export var hover_change_speed = 3.0 # Speed at which the hover effect changes
@export var press_change_speed = 4.0 # Speed at which the press effect changes

func _ready():
    # Initialize the HoverButton instances for each child node
    for child in self_.get_children():
        var new_child := HoverButton.new()
        new_child.button = child
        new_child.hover_change_speed = hover_change_speed
        new_child.press_change_speed = press_change_speed
        new_child.init()
        children.append(new_child)

func _process(delta):
    # Process the hover and press effects for each child node
    for child in children:
        child.process(delta)
