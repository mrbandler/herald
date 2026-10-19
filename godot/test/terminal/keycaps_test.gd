extends GdUnitTestSuite

func test_lays_a_centred_grid() -> void:
	var caps: Keycaps = auto_free(Keycaps.new())
	caps.rows = 2
	caps.columns = 3
	caps.pitch = 0.1
	var spots := caps.positions()
	assert_int(spots.size()).is_equal(6)
	assert_vector(spots[0]).is_equal_approx(Vector3(-0.1, 0.0, -0.05), Vector3.ONE * 0.0001)
	assert_vector(spots[5]).is_equal_approx(Vector3(0.1, 0.0, 0.05), Vector3.ONE * 0.0001)
