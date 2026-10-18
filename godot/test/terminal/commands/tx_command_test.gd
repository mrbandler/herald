extends GdUnitTestSuite

var _tx: TxCommand
var _spy: AtomSpy
var _requests: AtomSpy

func before_test() -> void:
	_tx = TxCommand.new()
	_tx.out = StringEvent.new()
	_tx.speak_open = BoolValue.new()
	_tx.sequence = StringListValue.new()
	_tx.locked = BoolValue.new()
	_tx.tx_requested = Event.new()
	_spy = AtomSpy.events(_tx.out)
	_requests = AtomSpy.events(_tx.tx_requested)

func test_requests_a_transmission_when_ready() -> void:
	_ready_to_send()
	_tx.run(PackedStringArray())
	assert_array(_spy.calls).is_empty()
	assert_int(_requests.calls.size()).is_equal(1)

func test_refuses_arguments() -> void:
	_ready_to_send()
	_tx.run(PackedStringArray(["NOW"]))
	assert_array(_spy.calls).is_equal(["USAGE: TX"])

func test_closed_uplink() -> void:
	_ready_to_send()
	_tx.speak_open.value = false
	_tx.run(PackedStringArray())
	assert_array(_spy.calls).is_equal(["UPLINK CLOSED"])

func test_empty_sequence() -> void:
	_ready_to_send()
	_tx.sequence.value = PackedStringArray()
	_tx.run(PackedStringArray())
	assert_array(_spy.calls).is_equal(["SEQUENCE EMPTY"])

func test_no_lock() -> void:
	_ready_to_send()
	_tx.locked.value = false
	_tx.run(PackedStringArray())
	assert_array(_spy.calls).is_equal(["NO LOCK"])
	assert_array(_requests.calls).is_empty()

func _ready_to_send() -> void:
	_tx.speak_open.value = true
	_tx.sequence.value = PackedStringArray(["ACK"])
	_tx.locked.value = true
