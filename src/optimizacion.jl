using JuMP, GLPK

include("balances.jl")

## Balances
balances = calcular_balances()

S = [i for i in keys(balances) if balances[i] < 0]
D = [j for j in keys(balances) if balances[j] > 0]

fuentes = Dict(i => -balances[i] for i in S)
pozos = Dict(j => balances[j] for j in D)

# Modelo de optimización
function optimizar(fuentes,pozos)

    model = Model(GLPK.Optimizer)

    @variable(model, x[S,D] >= 0) # dinero a enviar de la fuente f al pozo p (€)
    @variable(model, y[S,D], Bin) # indicador: si se realiza una transacción de la fuente f al pozo p

    @objective(model, Min, sum(y[i,j] for i in S, j in D))

    @constraint(model, [i in S], sum(x[i,j] for j in D) == supply[i])
    @constraint(model, [j in D], sum(x[i,j] for i in S) == demand[j])
    @constraint(model, [i in S, j in D],
        x[i,j] <= min(supply[i], demand[j]) * y[i,j]
    )

    JuMP.optimize!(model)

    # Construir un diccionario de transacciones
    transacciones = Dict()

    return transacciones
end