using LinearAlgebra, Plots


#### McCall

β = 0.95       # discount factor
S = 50         # number of possible wage offers
w̄ = LinRange(1., 10., S)   # wage offers
p = ones(S)/S  # equal probability of each wage
c = 3.



function iterateBellman(V, Q, β, p, w̄, c)     # V, Q from next period
    V_accept = w̄ .+ β .* V                       # w̄[s] + β*V[s] for each wage s
    V_reject = c  + β  * Q                        # c + β*Q (same for all wages)
    V_new = max.(V_accept, V_reject)            # pick the better option
    Q_new = dot(p, V_new)                       # expected value of random offer
    C = V_accept .>= V_reject                   # 1 = accept, 0 = reject
    return (V=V_new, Q=Q_new, C=C)               # named tuple of results
end


function solveMcCall( β, p, w̄, c)
    V = max.(w̄, c)                                    # initial guess for V
    C = w̄ .>= c                                      # initial guess for policy
    Q = dot(p, V) 

    dist = 1.0  
    t = 1                                      # initialize distance
    while dist > 1e-10                               # loop until convergence
        V_new, Q_new, C = iterateBellman(V, Q, β, p, w̄, c)  # one Bellman step
        dist = norm(V - V_new, Inf)   
        V = V_new                                       # replace old V with new
        Q = Q_new                                       # replace old Q with new
        t = t+1 
    end
    return (V=V, Q=Q, C=C)
end

#equivalent reservation wage:
minimum(w̄[C])


solveMcCall(0.84, p, w̄, 5).V


@kwdef struct McCallModel
    β::Float64 = 0.95                                   # discount factor
    S::Int = 50                                          # number of wage offers
    w̄::Vector{Float64} = collect(LinRange(1., 10., S))  # wage grid
    p::Vector{Float64} = ones(S)/S                       # probabilities
    c::Float64 = 3.0                                     # unemployment benefit
    α::Float64 = 0.0                                     # firing probability
end


m = McCallModel()

m.c
m.β

m2 = McCallModel(c=5.0,β=.99)
m2.c
m2.β

(; p, w̄, c,β) = m2
β
c



function iterateBellman(m::McCallModel, V, Q)     # V, Q from next period
    (; p, w̄, c, β) = m
    V_accept = w̄ .+ β .* V                       # w̄[s] + β*V[s] for each wage s
    V_reject = c  + β  * Q                        # c + β*Q (same for all wages)
    V_new = max.(V_accept, V_reject)            # pick the better option
    Q_new = dot(p, V_new)                       # expected value of random offer
    C = V_accept .>= V_reject                   # 1 = accept, 0 = reject
    return (V=V_new, Q=Q_new, C=C)               # named tuple of results
end



function solveMcCall(m::McCallModel)
    (; c, w̄,p) = m
    V = max.(w̄, c)                                    # initial guess for V
    C = w̄ .>= c                                      # initial guess for policy
    Q = dot(p, V) 

    dist = 1.0  
    t = 1                                      # initialize distance
    while dist > 1e-10                               # loop until convergence
        V_new, Q_new, C = iterateBellman(m, V, Q)  # one Bellman step
        dist = norm(V - V_new, Inf)   
        V = V_new                                       # replace old V with new
        Q = Q_new                                       # replace old Q with new
        t = t+1 
    end
    return (V=V, Q=Q, C=C)
end

solveMcCall(McCallModel(c=5.,β=0.99))


cvalues = LinRange(0, 5, 100)                       # grid of c values to try
hvalues = zeros(length(cvalues))                    # store hazard rate for each c
for i in 1:length(cvalues)                          # loop over each c
    sol = solveMcCall(McCallModel(c=cvalues[i]))    # create model, solve
    hvalues[i] = dot(p, sol.C)                      # compute hazard rate p⋅C
end

plot(cvalues, 1 ./hvalues, linewidth=2, label="Hazard Rate", legend=:topright)
xlabel!("Unemployment Benefits (c)")                # label axes
ylabel!("Duration of Unemployment")


hcat(C,p)