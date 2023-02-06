import FutureTagBot
import GitHub
import Test

using Test: @testset, @test, @test_throws

using FutureTagBot: Context, Registry, ClonedRegistry, Package, ClonedPackage
using FutureTagBot: Candidate, Target, Plan
using FutureTagBot: candidate_satisfies_target
using FutureTagBot: version_to_candidate
using FutureTagBot: version_to_target

@testset "FutureTagBot.jl" begin
    run(`git --version`)
    run(`curl --version`)

    include("setup.jl")

    @testset "commit-to-tree" begin
        include("commits.jl")
    end

    @testset "version-to-candidate" begin
        include("candidates.jl")
    end
end
