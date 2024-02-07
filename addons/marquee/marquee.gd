##
## This control allows an array of label text to be specified
## and displayed as a scrolling set of labels that transition
## using the delay and and duration parameters
##
## The label's theme can be specified independently of other
## labels by including a theme_type for the label in the 
## label_variation
##

@tool
extends Control
class_name Marquee

## The label_variation (if not blank) will be specified during
## the creation of the labels by setting in the theme_type_variation
@export var label_variation : String :
	set(lv):
		label_variation = lv
		if is_inside_tree():
			_rebuild()

## The delay provides the time in seconds that each individual line
## in the lines array once it has reached the center.
@export var delay : float = 2.0 :
	set(d):
		delay = d
		if is_inside_tree():
			_relayout()

## The duration provides the time in seconds that it takes a line
## to move from the right edge to the center, and from the center
## to the left edge.
@export var duration : float = 2.0 :
	set(d):
		duration = d
		if is_inside_tree():
			_relayout()

## The actual text that is displayed on the marquee.  Each line is
## moved into the center of the marquee one line at a time.  The
## minimum size of this control will be the largest of an
## individual line
@export var lines : Array[String] : 
	set(l):
		lines = l
		if is_inside_tree():
			_rebuild()

var _tween : Tween
var _labels : Array[Label]

func _ready():
	resized.connect(_on_resized)
	set_clip_contents(true)
	_rebuild()

func _rebuild():
	for l in _labels:
		remove_child(l)
		l.queue_free()
	_labels = []
	var min_size : Vector2 = Vector2(0, 0)
	for line in lines:
		var label = Label.new()
		label.text = line
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if label_variation.length() > 0:
			label.theme_type_variation = label_variation
		_labels.push_back(label)
		add_child(label)
		var r = label.get_rect()
		if r.size.x > min_size.x: min_size.x = r.size.x
		if r.size.y > min_size.y: min_size.y = r.size.y
	custom_minimum_size = min_size
	_relayout()

func _exit_tree():
	if _tween:
		_tween.kill()

func _on_resized():
	_relayout()
	
func _relayout():
	if _tween:
		_tween.kill()
	var center = get_rect().size / 2.0
	_tween = get_tree().create_tween()
	_tween.set_loops()
	for lidx in range(_labels.size()):
		var current_label = _labels[lidx]
		var next_idx = lidx + 1
		if next_idx >= _labels.size():
			next_idx = 0
		var next_label = _labels[next_idx]
		if lidx == 0:
			current_label.position = center - current_label.get_rect().size / 2.0
		else:
			current_label.position = Vector2(get_rect().size.x, center.y - next_label.get_rect().size.y / 2.0)
		var right_pos = Vector2(get_rect().size.x, center.y - next_label.get_rect().size.y / 2.0)
		var center_pos = center - next_label.get_rect().size / 2.0
		var left_pos = Vector2(-current_label.get_rect().size.x, center.y - current_label.get_rect().size.y / 2.0)
		_tween.tween_interval(delay)
		_tween.tween_property(next_label, "position", center_pos, duration).from(right_pos)
		_tween.parallel().tween_property(current_label, "position", left_pos, duration)
