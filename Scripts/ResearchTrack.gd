extends Control

class_name ResearchTrack

#@export var invention_resources : Array[Resource] = []
var invensions : Array[Invention] = []
var current_index : int = 0
var lab_manager : Control = null

func _ready() -> void:
	var button : Button = ($Button as Button)
	assert(button != null, "%s does not have a Button" % [name])
	($Button as Button).pressed.connect(on_button_press)
	$Pending.hide()
	hide()

func init(game : Control, rtd : ResearchTrackData) -> void:
	lab_manager = game
	$Pending/Track.text = rtd.track
	for i : Invention in rtd.inventions:
		print("Adding invention %s" % [i.button_text])
		i.set_condition_checker(game)
		invensions.append(i)
	
func get_next_pending_invention() -> Invention:
	if current_index >= invensions.size():
		return null
	else:
		return invensions[current_index] as Invention

func _process(_delta: float) -> void:
	if get_parent().visible == false:
		return
	update()

func update() -> void:
	var pending_invention = get_next_pending_invention()
	if pending_invention == null:
		if self.visible:
			#print("Retiring Research Track")
			hide()
		return

	if pending_invention.is_hidden():
		if self.visible:
			#print("Hiding %s" % pending_invention.get_button_text())
			hide()
		return

	if self.visible == false:
		#print("Showing %s" % pending_invention.get_button_text())
		show()

	if pending_invention.is_pending():
		if $Button.visible:
			$Button.hide()
		if $Pending.visible == false:
			#print("Showing ETA for %s" % pending_invention.get_button_text())
			if current_index == 0:
				$Pending/Track.hide()
			else:
				$Pending/Track.show()
			lab_manager.highlight_lab()
			$Pending.show()
		$Pending/ETA.text = pending_invention.get_eta_text()
		$Pending/Needs.text = "Needs: %s" % pending_invention.get_needs_text()
		return
	else:
		if $Button.visible == false:
			#print("Showing Button for %s" % pending_invention.get_button_text())
			lab_manager.highlight_lab()
			$Button.show()
		if $Pending.visible:
			$Pending.hide()
		$Button.text = pending_invention.get_button_text()
		
func on_button_press() -> void:
	var pending_invention = get_next_pending_invention()
	assert(pending_invention != null)
	pending_invention.activate()
	current_index += 1
	var next = get_next_pending_invention()
	if next != null:
		print("Advancing to %s" % [next.describe()])
	update()
