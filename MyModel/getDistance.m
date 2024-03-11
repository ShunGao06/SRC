function h = getDistance(a, b)
	h = sqrt(sum((a - b) .^ 2, 2));