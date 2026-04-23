"""
    countTransitions(s, n_states)

Count transitions in state sequence `s` and return
an n_states × n_states matrix of counts.
"""
function countTransitions(s, n_states)
    N = zeros(Int, n_states, n_states)   # Initialize count matrix
    for t in 2:length(s)
        N[s[t-1], s[t]] += 1            # Increment the (i,j) count
    end
    return N
end

s = [1, 1, 2, 1, 2, 2, 1]

N = zeros(Int, 2, 2)

#t = 2
s[1]
s[2]
N[s[1], s[2]] += 1 # N[1, 1] += 1   

# t = 3
s[2]
s[3]
N[s[2], s[3]] += 1 # N[1, 2

N = countTransitions(s, 2) # should return [2 3; 2 1]


sum(N, dims=2) # sum over the rows
sum(N, dims=1) # sum over the columns

sumNrows = sum(N, dims=2)

P_est = N ./ sumNrows # divide each row by its sum to get probabilities

#equivalent to 
P_est = zeros(2,2)
P_est[1, :] = N[1, :] ./sumNrows[1]
P_est[2, :] = N[2, :] ./sumNrows[2]



sample_sizes = [50, 200, 1000, 5000, 20000]
errors = zeros(length(sample_sizes))
for n in sample_sizes
    s_sim, _ = simulateMarkov(P, X̄, n)
    N_sim = countTransitions(s_sim, 2)
    P_est_sim = N_sim ./ sum(N_sim, dims=2)
    println("Sample size: $n")
    println("Estimated P:\n$P_est_sim\n")
    push!(errors, norm(P_est_sim - P)) # Store the error (norm of difference)
end





#### McCall

β = 0.95       # discount factor
S = 5         # number of possible wage offers
w̄ = LinRange(1., 10., S)   # wage offers
p = ones(S)/S  # equal probability of each wage
c = 3.

println(collect(w̄))

V1 = zeros(S) # initialize value function guess
for j in 1:S
    V1[j] = max(w̄[j],c)
end

V1 = max.(w̄, c) # vectorized version of the above loop
using LinearAlgebra
Q1 = dot(p,V1) # expected value of a wage offer

#note different than
dot(p,w̄)