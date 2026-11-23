using JuMP, GLPK

include("balances.jl")

## Balances
balances = calcular_balances()

S = [i for i in keys(balances) if balances[i] < 0]
D = [j for j in keys(balances) if balances[j] > 0]

supply = Dict(i => -balances[i] for i in S)
demand = Dict(j => balances[j] for j in D)

## Modelo

model = Model(GLPK.Optimizer)

### Variables ###

@variable(model, x[S,D] >= 0) # dinero a enviar de la fuente f al pozo p (€)
@variable(model, y[S,D], Bin) # indicador: si se realiza una transacción de la fuente f al pozo p

### Función objetivo ###

@objective(model, Min, sum(y[i,j] for i in S, j in D))


### Restricciones ###

@constraint(model, [i in S], sum(x[i,j] for j in D) == supply[i])
@constraint(model, [j in D], sum(x[i,j] for i in S) == demand[j])
@constraint(model, [i in S, j in D],
    x[i,j] <= min(supply[i], demand[j]) * y[i,j]
)

### Solución ###

JuMP.optimize!(model)

println("El valor óptimo de la función objetivo es ", objective_value(model))

for i in S, j in D
    println("x[$i,$j] = ",JuMP.value(x[i,j]))
end


function optimizar(balances::Vector{Balance})
    
end