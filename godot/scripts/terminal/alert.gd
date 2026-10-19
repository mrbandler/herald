class_name Alert
extends Resource

## An alert for the CRT's alert box: what went wrong, and what it means for the Listener.

## The headline, shown between exclamation marks under the warning triangle, e.g. `NO ACK SENT`.
@export var title := ""

## What happened and what to do about it, a few short lines of 40 columns or less.
@export_multiline var explainer := ""
