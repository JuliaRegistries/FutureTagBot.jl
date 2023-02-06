candidates_and_targets = [
    Candidate(v"0.5.0", "54af302a0877b0d7a02125db84ce613bca32c62b") =>
        Target(v"0.5.0", "29a04c9d4de9e15249e84549d6f0eb107675c639"),
    Candidate(v"0.5.1", "c37b675d85372c4df2fd705f80c9bd0abab05742") =>
        Target(v"0.5.1", "8eb7b4d4ca487caade9ba3e85932e28ce6d6e1f8"),
    Candidate(v"0.5.3", "29aa1b4bd266e60e45cc79b1e5ff06e475a40cd6") =>
        Target(v"0.5.3", "46e44e869b4d90b96bd8ed1fdcf32244fddfb6cc"),
]

for (candidate, target) in candidates_and_targets
    @test candidate isa Candidate
    @test target isa Target
    @test candidate_satisfies_target(ctx, candidate, target)
end

let
    candidate = Candidate(v"0.5.0", "54af302a0877b0d7a02125db84ce613bca32c62b")
    target = Target(v"0.5.3", "46e44e869b4d90b96bd8ed1fdcf32244fddfb6cc")
    @test_throws Exception candidate_satisfies_target(cloned_example, candidate, target)
    expected_msg = "Version 0.5.0 is not equal to version 0.5.3"
    expected_exception = FutureTagBot.VersionMismatch(expected_msg)
    @test_throws expected_exception candidate_satisfies_target(ctx, candidate, target)
end

let
    candidate = Candidate(v"0.5.3", "54af302a0877b0d7a02125db84ce613bca32c62b")
    target = Target(v"0.5.3", "46e44e869b4d90b96bd8ed1fdcf32244fddfb6cc")
    @test !candidate_satisfies_target(ctx, candidate, target)
end
