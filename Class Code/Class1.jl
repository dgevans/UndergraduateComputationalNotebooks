x = 2

x = true

100 > 10

x = 3
x = 5


10%3
9%3


greeting = "Hello, world!"


name = "Fred"
age = 65
"My name is $name and I am $age years old."

x = [5,6]


David = [40,"male",71.5]

David[1] = "this is string"


A = [1.,2.,3.]

A[1] = "This is a string"


A
i = 2


A = [1,2,3,4,5,6,7,8,9,10]

largeA = A.>5

A[largeA]

A[A.>5]

nA = length(A)



d = (39,"male",71.5)

age,gender,height = d


person = (name="David", age=40, height=71.5)

David = Dict("age" => 39, "gender" => "male", "height"=> 71.5)

David["age"]

David["age"] = "this is a string"

David["job"] = "Economist"
David["Favorite TV Show"] = "Community"

dict = Dict{Float64,Float64}()

for i in 1:5 
    println( i ) #will print i for i running from 1 to 5
end

#equivalent to
for i in [1,2,3,4,5]
    println( i ) #will print i for i running from 1 to 5
end


David = [32,"male",71.5];
for element in David
    println( element )
end

for i in 1:3
    println( David[i] )
end

for i in 1:length(x_values)
    println( x_values[i]*x_values[i] )
end



β = 0.95 #can use Greek letters: type \beta then hit `tab`
ret = 0.
for j in 0:5
    ret += β^j
end
print( ret )

ret = 0.
ret = ret + β^0 #j = 0
ret = ret + β^1 #j = 1
ret = ret + β^2 #j = 2
ret = ret + β^3 #j = 3
ret = ret + β^4 #j = 4
ret = ret + β^5 #j = 5
print( ret )

β^0 + β^1 + β^2 + β^3 + β^4 + β^5


x = 1

x == 1
x == 2
x != 2
x != 1


1 < 2 && 'f' in "foo" 
1 < 2
'f' in "foo"
'g' in "foo"

1 < 2 && 'g' in "foo"



x = 4
if x > 4
    println( "Yay!" )
end
if x < 4
    print( "We did not reach this code, it never ran, how existential" )
end


primes = Int[]
for i in 2:10
    isprime = true
    for p in primes
        if i%p == 0
            println( "$i is divisible by $p, so it is not prime" )
            isprime = false
        end
    end
    if isprime
        println( "$i is prime => add it to primes" )
        push!(primes, i)
    end
end
print( primes )


f = x -> x^4

f(2)

f(4)

g(x) = x^5
g(2)
g(4)


function h(x)
    return x^2
end


function h(x,y)
    return x^2 + y^2
end

h(2,3) # 2^2+ 3^2
h(2) # 2^2