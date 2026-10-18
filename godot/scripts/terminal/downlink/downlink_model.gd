class_name DownlinkModel
extends Resource

## The downlink's numbers: data rate, manifest push, storage, and how rows and progress read.

## How a row arrived.
enum Grade {
	CLEAN,
	NOISY,
	LOST,
}
