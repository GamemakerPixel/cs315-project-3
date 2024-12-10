class_name Distributions
extends Node

static var rng = RandomNumberGenerator.new()

static func sample_from_distribution(distribution) -> int:
	return rng.rand_weighted(distribution)
