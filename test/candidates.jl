@testset "version-to-candidate for Example 0.5.3" begin
    target = version_to_target(ctx, v"0.5.3")
    candidate = version_to_candidate(ctx, v"0.5.3")
    @test candidate_satisfies_target(ctx, candidate, target)
end
