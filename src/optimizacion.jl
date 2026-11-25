using JuMP, GLPK

struct Transferencia
    deudor::String
    acreedor::String
    importe::Float64
end

# Algoritmo determinístico para instancias pequeñas
function opt_deterministico(balances::AbstractDict{String, <:Real})

    model = Model(GLPK.Optimizer)

    F = [f for (f, v) in balances if v < 0] # fuentes
    S = [s for (s, v) in balances if v > 0] # sumideros

    @variable(model, x[F,S] >= 0) # dinero a enviar de la fuente f al sumidero s (€)
    @variable(model, y[F,S], Bin) # indicador: si se realiza una transacción de la fuente f al sumidero s

    @objective(model, Min, sum(y[f,s] for f in F, s in S))

    @constraint(model, [f in F], sum(x[f,s] for s in S) == -balances[f])
    @constraint(model, [s in S], sum(x[f,s] for f in F) == balances[s])
    @constraint(model, [f in F, s in S],
        x[f,s] <= min(-balances[f], balances[s]) * y[f,s]
    )
    
    JuMP.optimize!(model)
    
    if termination_status(model) != MOI.OPTIMAL
        error("No se ha encontrado solución óptima.")
    end

    transferencias = Transferencia[]
    for f in F, s in S
        importe = round(value(x[f,s]); digits = 2)

        if importe > 0
            push!(
                transferencias,
                Transferencia(f,s,importe)
            )
        end
    end

    return transferencias
end

# Algoritmo greedy para instancias grandes
function opt_greedy()


    return transferencias
end