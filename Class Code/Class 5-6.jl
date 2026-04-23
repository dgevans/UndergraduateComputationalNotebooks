using LinearAlgebra
using Plots

a = 1
b = 2
c = 3
d = 4

A = [a b; 
     c d]

x = [5,6]

A*x

# Compare to
a*x[1] + b*x[2]
c*x[1] + d*x[2]


b
1/b 
b*(1/b)

A
Ainv = inv(A)

A*Ainv
Ainv*A


y = [3,4]
#find x such that
#y_1 = a*x[1] + b*x[2]
#y_2 = c*x[1] + d*x[2]
x = Ainv*y
#check:
a*x[1] + b*x[2]
c*x[1] + d*x[2]

A*x

using Distributions
cointoss = Categorical([0.5, 0.5])
rand(cointoss) # 1 or 2 with equal probability

rand(cointoss, 10) # 10 tosses

wbar = [-1,1] #winnings

w = wbar[rand(cointoss)] 


using Random
Random.seed!(42)
rand(cointoss, 10) # same sequence of tosses as before


loadedcoin = Categorical([0.8, 0.2])
rand(loadedcoin, 100) # more likely to get 1 than 2


multistate = Categorical([0.5, 0.3, 0.2])

rand(multistate, 10) # 10 draws from 3 states with different probabilities

w̄ = [-1, 1, 2]

winnings = w̄[rand(multistate, 10)] # 10 draws of winnings from the multistate distribution

winnings[1] #first period
winnings[2] #second period

P = [0.9 0.1;
     0.3 0.7]

ḡ = [0.03,-0.01]

P[1,1]
P[2,1]
P[1,:] # Conditinal distribution if we are in an expansion
P[2,:] # Conditional distribution if we are in a recession

pboom = Categorical(P[1, :])
ḡ[rand(pboom,10)]


"""
    drawDiscrete(p, X̄)

Draws a discrete random variable with probability vector p
over values X̄. Returns (state, value).
"""
function drawDiscrete(p, X̄)      # Declare the function
    dist = Categorical(p)         # Create the distribution from p
    s = rand(dist)                # Draw a random state index
    X = X̄[s]                     # Look up the value for that state
    return s, X                   # Return both the index and value
end

drawDiscrete([0.5,0.5], [-1,1]) # should return either (1, -1) or (2, 1) with equal probability


function simulateMarkov(P, X̄, T; s₁=1)
    X = zeros(T)                          # Set up storage for values
    s = zeros(Int, T)                     # Set up storage for states
    s[1] = s₁                             # Initialize first period
    X[1] = X̄[s₁]                         # Initialize first period
    for t in 2:T                          # For each period t = 2, ..., T
        s[t], X[t] = drawDiscrete(P[s[t-1], :], X̄)  # Draw next state from row s[t-1] of P
    end
    return s, X                           # Return states and values
end

P = [0.9 0.1;
     0.3 0.7]
X̄ = [0.03, -0.01]
s₁ = 1
T = 5

function simulateMarkov(P,X̄,T; s₁=1)
     # Set up storage for states and values
     s = zeros(Int, T)
     X = zeros(T)

     #t = 1
     s[1] = s₁
     X[1] = X̄[s₁]

     for t in 2:T
          pt = P[s[t-1], :]
          s[t], X[t] = drawDiscrete(pt, X̄)
     end
     return s, X
end
#Same as below, but unrolled

#t = 2
t = 2
pt = P[s[t-1], :]
s[t], X[t] = drawDiscrete(pt, X̄)

# t= 3
p2 = P[s[2], :]
s[3], X[3] = drawDiscrete(p2, X̄)

# t = 4
p3 = P[s[3], :]
s[4], X[4] = drawDiscrete(p3, X̄)

# t = 5
p4 = P[s[4], :]
s[5], X[5] = drawDiscrete(p4, X̄)


simulateMarkov(P, X̄, 100)


loadedcoin = Categorical([0.8, 0.2])
rand(loadedcoin) # 1 or 2 with equal probability

rand(loadedcoin, 10) # 10 tosses

wbar = [-1,1] #winnings

N = 100000
winnings = wbar[rand(loadedcoin, N)] # 10 draws of winnings from the multistate distribution

mean(winnings) # should be close to 0.6
dot([0.8, 0.2], wbar) # should be exactly 0.6




P = [0.9 0.1;
     0.3 0.7]

ḡ = [0.03,-0.01]

dot(P[1,:], ḡ) # should be 0.026
#same as
P[1,1]*ḡ[1] + P[1,2]*ḡ[2] # should be 0.026
dot(P[2,:], ḡ) # should be 0.002
#same as
P[2,1]*ḡ[1] + P[2,2]*ḡ[2] # should be 0.002


P*ḡ

P*P*ḡ # This is 2 periods ahead forecast of growth
(P^2)*ḡ
(P^10)*ḡ # This is 10 periods ahead forecast of growth
(P^100)*ḡ # This is 100 periods ahead forecast of growth, should be close to the stationary distribution forecast


s, g = simulateMarkov(P, ḡ, 5000)   # 5000 periods for convergence
T = length(g)


gboom = []                         # Will hold growth after booms
grec = []                          # Will hold growth after recessions

for t in 1:T-1                    # Loop over all periods
    if s[t] == 1                   # Was period t a boom?
        push!(gboom, g[t+1])      #   → save next period's growth
    else                           # Was period t a recession?
        push!(grec, g[t+1])       #   → save next period's growth
    end
end