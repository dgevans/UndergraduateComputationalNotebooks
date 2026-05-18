using Plots, LinearAlgebra
@kwdef struct RustModel
    β::Float64 = 0.95                                # discount factor
    S::Int = 50                                       # number of mileage bins
    RC::Float64 = 20.0                                # replacement cost
    θ₁::Float64 = 0.04                               # maintenance cost parameter
    θ₃::Vector{Float64} = [0.36, 0.48, 0.16]         # transition probabilities
    x̄::Vector{Float64} = Float64.(0:S-1)             # mileage states
    c::Vector{Float64} = θ₁ * x̄                      # cost at each mileage level
end

m = RustModel()
θ₃ = m.θ₃


S = 50

function buildTransition(θ₃, S)
    K = length(θ₃)                          # number of possible increments
    F0 = zeros(S, S)                       # keep transition matrix: mileage goes up
    F1 = zeros(S, S)                       # replace transition matrix: mileage resets

    for i in 1:S                           # loop over current states
        for k in 1:K                       # loop over possible increments
            j_keep = min(i + k - 1, S)     # when i = S and k = 2 j_keep = S 
            F0[i, j_keep] += θ₃[k]          # keep transition: state i → state i + (k-1)

            #impose i = 1
            j_replace = k          
            F1[i, j_replace] += θ₃[k]       # replace transition: any state → state (k)
        end
    end
    return F0, F1
end
K = length(θ₃)                          # number of possible increments

F0 = zeros(S, S)                       # keep transition matrix: mileage goes up
F1 = zeros(S, S)                       # replace transition matrix: mileage resets

for i in 1:S                           # loop over current states
    for k in 1:K                       # loop over possible increments
        j_keep = min(i + k - 1, S)     # when i = S and k = 2 j_keep = S 
        F0[i, j_keep] += θ₃[k]          # keep transition: state i → state i + (k-1)

        #impose i = 1
        j_replace = k          
        F1[i, j_replace] += θ₃[k]       # replace transition: any state → state (k)
    end
end


N = 10_000
v0_val = 2.0
v1_val = 3.0

ε0 = -log.(-log.(rand(N)))                          # N extreme value draws
ε1 = -log.(-log.(rand(N)))                          # N independent draws

max_payoffs = max.(v0_val .+ ε0, v1_val .+ ε1)      # simulated max for each draw
const γ_euler = Base.MathConstants.eulergamma       # Euler's constant ≈ 0.5772

theoretical = log(exp(v0_val) + exp(v1_val)) + γ_euler
println("Simulated E[max]:   ", round(mean(max_payoffs), digits=4))
println("Theoretical:        ", round(theoretical, digits=4))

choices = (v1_val .+ ε1) .> (v0_val .+ ε0)          # 1 if option 1 chosen
simulated_prob = mean(choices)

theoretical_prob = exp(v1_val) / (exp(v0_val) + exp(v1_val))
println("Simulated P(d=1):   ", round(simulated_prob, digits=4))
println("Theoretical P(d=1): ", round(theoretical_prob, digits=4))


function iterateBellman(m::RustModel, V, F0, F1)
    (; β, RC, c) = m
    v_keep = -c + β * (F0 * V)                      # value of keeping
    v_replace = (-RC) .+ β * (F1 * V)               # value of replacing
    vmax = max.(v_keep, v_replace)                   # for numerical stability
    V_new = vmax + log.(exp.(v_keep - vmax)          # log-sum-exp trick:
                      + exp.(v_replace - vmax))      #   prevents overflow
    return V_new
end


function solveBellman(m::RustModel,F0,F1,tol = 1e-10)
    V = zeros(m.S)                                         # initial guess: all zeros
    dist = 1.0                                           # initialize distance

    niter = 0                                            # count iterations
    while dist > 1e-10                                   # loop until convergence
        V_new = iterateBellman(m, V, F0, F1)             # one Bellman step
        dist = norm(V - V_new, Inf)                      # max absolute change
        V = V_new                                        # update
        niter += 1
    end
    return V
end
println("Converged in $niter iterations")

function solveRust(m::RustModel)
    (; β, RC, c, θ₃, S) = m
    #build transition matrices
    F0, F1 = buildTransition(θ₃, S)
    #solve the Bellman equation
    V = solveBellman(m, F0, F1)                      # solve the DP
    #compute choice probabilities
    v_keep = -c + β * (F0 * V)                       # choice-specific values
    v_replace = (-RC) .+ β * (F1 * V)
    P_rep = 1 ./ (1 .+ exp.(v_keep - v_replace))     # logit choice probabilities
    #return tuple with solution
    return (V=V, P=P_rep, v_keep=v_keep, v_replace=v_replace)
end

sol = solveRust(m)

P_rep = sol.P
T =100
x_sim = zeros(Int, T)                            # mileage states
d_sim = zeros(Int, T)                            # replacement decisions
x_sim[1] = 1                                     # start at state 1 (0 mileage)

for t in 1:T
    # The choice
    if rand() < P_rep[x_sim[t]]
        d_sim[t] = 1
    else
        d_sim[t] = 0
    end
    # The transition (update the mileage state for the next period)
    if t < T
        Δ = rand(Categorical(θ₃)) - 1            # mileage increment: 0, 1, or 2
        if d_sim[t] == 1
            x_sim[t+1] = min(1 + Δ, S)           # replace: reset then increment
        else
            x_sim[t+1] = min(x_sim[t] + Δ, S)    # keep: current + increment
        end
    end
end