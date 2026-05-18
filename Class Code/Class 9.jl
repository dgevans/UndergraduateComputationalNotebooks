using Plots, LinearAlgebra

P = [0.5 0.5; 0.5 0.5]

ybar = [1,3]

Ey = P * ybar


P


A = [1 2; 3 4]
b = [5, 6]

p = A \ b
p = inv(A) * b

A*p - b


excessDemand(p, A, ε, a, b) = A*p^(-ϵ) - (a+b*p)
excessDemand = (p, A, ε, a, b) -> A*p^(-ε) - (a+b*p)
function excessDemand(p, A, ε, a, b)
    return A*p^(-ε) - (a+b*p)
end




using NonlinearSolve

#Finding Equilibiurm price
A= 120
ε = 0.5
a = 10
b = 5


function equilibrium_price(A, ε, a, b, p0) 

    f = (p,_) -> [excessDemand(p[1], A, ε, a, b)]

    prob = NonlinearProblem(f, [p0])
    sol = solve(prob)
    return sol.u
end



x = zeros(5)

x[1] = 5
x[2]

x[6]