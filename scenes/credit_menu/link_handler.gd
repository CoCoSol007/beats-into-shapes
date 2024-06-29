extends RichTextLabel


func _on_meta_clicked(meta):
	# This function will be called when a link is clicked
	OS.shell_open(meta)
