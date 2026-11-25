function calcular_balances(
    personas::Vector{String},
    gastos::Vector{Gasto}
)

    pagado = Dict(p => 0.0 for p in personas)
    correspondiente = Dict(p => 0.0 for p in personas)

    for gasto in gastos

        # Comprobar que el pagador existe
        if !(gasto.pagador in personas)
            error("El pagador $(gasto.pagador) no está registrado")
        end

        # Comprobar participantes
        if isempty(gasto.participantes)
            error("El gasto $(gasto.concepto) no tiene participantes")
        end

        if !all(p -> p in personas, gasto.participantes)
            error("Hay participantes no registrados en $(gasto.concepto)")
        end

        # Registrar el importe pagado
        pagado[gasto.pagador] += gasto.importe

        # Repartir el gasto equitativamente
        parte = gasto.importe / length(gasto.participantes)

        for p in gasto.participantes
            correspondiente[p] += parte
        end
    end

    balances = Dict()

    for p in personas

        total_pagado = pagado[p]
        total_correspondiente = correspondiente[p]

        b = total_pagado - total_correspondiente

        push!(
            balances,
            Balance(
                p,
                total_pagado,
                total_correspondiente,
                b
            )
        )
    end

    return balances
end

function obtener_deudores(balances::Vector{Balance})
    return filter(b -> b.balance < -1e-6, balances)
end

function obtener_acreedores(balances::Vector{Balance})
    return filter(b -> b.balance > 1e-6, balances)
end