# This file is part of Kpax3. License is MIT.

# suppose we
# a) split a cluster with 15 units into two clusters of 8 and 7 units
#    respectively, moving from k = 5 to k = 6
# b) move a unit from a cluster with 15 units to a new cluster (split)
# c) move a unit from a cluster with 15 units to another cluster with 7 units

function test_mcmc_partition_ratios()
  ifile = "data/proper_aa.fasta"
  ofile = "../build/test.bin"

  settings = KSettings(ifile, ofile)

  x = AminoAcidData(settings)

  priorR = EwensPitman(settings.α, settings.θ)
  priorC = AminoAcidPriorCol(x.data, settings.γ, settings.r)

  state = AminoAcidState(x.data, [1; 1; 1; 1; 1; 1], priorR, priorC, settings)
  support = MCMCSupport(state, priorC)

  support.vi = 8
  support.vj = 7

  for (α, θ) in ((0.4, -0.3), (0.4, 0.0), (0.4, 2.1), (0.0, 2.1), (-2.4, 10))
    ep = EwensPitman(α, θ)

    lr1 = logdPriorRow(50, 6, [22;  8; 7; 5; 1; 7], ep) -
          logdPriorRow(50, 5, [22; 15; 7; 5; 1], ep)

    logratiopriorrowsplit!(6, ep, support)
    @test_approx_eq_eps support.lograR lr1 ε

    logratiopriorrowmerge!(5, ep, support)
    @test_approx_eq_eps support.lograR -lr1 ε

    lr2 = logdPriorRow(50, 6, [22; 14; 7; 5; 1; 1], ep) -
          logdPriorRow(50, 5, [22; 15; 7; 5; 1], ep)

    @test_approx_eq_eps logratiopriorrowsplit(6, 15, ep) lr2 ε
    @test_approx_eq_eps logratiopriorrowmerge(5, 14, ep) -lr2 ε

    lr3 = logdPriorRow(50, 5, [22; 14; 8; 5; 1], ep) -
          logdPriorRow(50, 5, [22; 15; 7; 5; 1], ep)

    @test_approx_eq_eps logratiopriorrowmove(15, 7, ep) lr3 ε
  end

  nothing
end

test_mcmc_partition_ratios()
