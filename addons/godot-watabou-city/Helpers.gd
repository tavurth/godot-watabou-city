extends RefCounted

static func smooth_line2d(line: Line2D, num_points: int = 2, corner_speed: float = 4) -> void:
	var curve := Curve2D.new()

	for idx in range(len(line.points)):
		curve.add_point(line.points[idx])

		if idx > 0:
			var delta = line.points[idx] - line.points[idx-1]
			delta /= corner_speed

			curve.set_point_in(idx, -delta)
			curve.set_point_out(idx, +delta)

	var points = curve.tessellate(num_points)

	line.set_points(points)
