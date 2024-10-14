extends Control

class_name ResearchTrack

var inventions : Array[Invention] = []
var current_index : int = 0

func _ready() -> void:
	($Button as Button).pressed.connect(on_button_press)
	hide()
	
func get_next_pending_invention() -> Invention:
	if current_index >= inventions.size():
		return null
	else:
		return inventions[current_index]

func add_invention(invention : Invention) -> void:
	inventions.append(invention)

func _process(_delta: float) -> void:
	update()

func update() -> void:
	var pending_invention = get_next_pending_invention()
	if pending_invention == null:
		if self.visible:
			print("Retiring Research Track")
			hide()
		return

	if pending_invention.is_hidden():
		if self.visible:
			print("Hiding %s" % pending_invention.get_button_text())
			hide()
		return

	if self.visible == false:
		print("Showing %s" % pending_invention.get_button_text())
		show()

	if pending_invention.is_pending():
		if $Button.visible:
			$Button.hide()
		if $ETA.visible == false:
			print("Showing ETA for %s" % pending_invention.get_button_text())
			$ETA.show()
		$ETA.text = pending_invention.get_eta_text()
		return
	else:
		if $Button.visible == false:
			print("Showing Button for %s" % pending_invention.get_button_text())
			$Button.show()
		if $ETA.visible:
			$ETA.hide()
		$Button.text = pending_invention.get_button_text()
		
func on_button_press() -> void:
	var pending_invention = get_next_pending_invention()
	if pending_invention != null:
		pending_invention.activate()
		current_index += 1
		update()
