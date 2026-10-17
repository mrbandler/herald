class_name StringEvent
extends Event

## An event carrying a String payload, e.g. stdout lines. Handlers may type it as `String`.
## The override must keep the parent signature, so a non-String payload fails at runtime here.


## Raises with a String payload, "" when omitted.
func raise(payload: Variant = "") -> void:
	var text: String = payload
	super(text)
