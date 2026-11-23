using JSON

struct Gasto
    concepto::String
    importe::Float64
    pagador::String
    participantes::Vector{String}
end

ruta_predeterminada = "datos/gastos.json"


function cargar_gastos(ruta::String = ruta_predeterminada)

    if !isfile(ruta)
        return Gasto[]
    end

    datos = JSON.parsefile(ruta)

    return [
        Gasto(
            g["concepto"],
            Float64(g["importe"]),
            g["pagador"],
            String.(g["participantes"])
        )
        for g in datos
    ]
end


function guardar_gastos(
    nuevos_gastos::Vector{Gasto},
    ruta::String = ruta_predeterminada
)

    # Crear directorio si no existe
    mkpath(dirname(ruta))

    gastos = cargar_gastos(ruta)
    append!(gastos, nuevos_gastos)

    datos = [
        Dict(
            "concepto" => g.concepto,
            "importe" => g.importe,
            "pagador" => g.pagador,
            "participantes" => g.participantes
        )
        for g in gastos
    ]

    open(ruta, "w") do archivo
        JSON.print(archivo, datos, 4)
    end

    return gastos
end


function borrar_gastos(gasto::Gasto, ruta::String = ruta_predeterminada)

end


function resetear_gastos(ruta::String = ruta_predeterminada)

    # Crear directorio si no existe
    mkpath(dirname(ruta))

    open(ruta, "w") do archivo
        JSON.print(archivo, [])
    end

    return nothing
end