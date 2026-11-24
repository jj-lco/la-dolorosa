using JSON

struct Gasto
    id::Int
    concepto::String
    importe::Float64
    pagador::String
    participantes::Vector{String}
end

const RUTA_GASTOS = "datos/gastos.json"

function guardar_gastos(gastos::Vector{Gasto})
    mkpath(dirname(RUTA_GASTOS))

    datos = [
        Dict(
            "id" => g.id,
            "concepto" => g.concepto,
            "importe" => g.importe,
            "pagador" => g.pagador,
            "participantes" => g.participantes
        )
        for g in gastos
    ]

    open(RUTA_GASTOS, "w") do archivo
        JSON.print(archivo, datos, 4)
    end
end

function cargar_gastos()
    if !isfile(RUTA_GASTOS)
        return Gasto[]
    end

    datos = JSON.parsefile(RUTA_GASTOS)

    return [
        Gasto(
            Int(g["id"]),
            String(g["concepto"]),
            Float64(g["importe"]),
            String(g["pagador"]),
            String.(g["participantes"])
        )
        for g in datos
    ]
end

function anadir_gasto!(
    gastos::Vector{Gasto},
    concepto::String,
    importe::Float64,
    pagador::String,
    participantes::Vector{String}
)
    concepto = String(strip(concepto))
    pagador = String(strip(pagador))
    participantes = String.(strip.(participantes))

    isempty(concepto) && throw(ArgumentError("Concepto vacío"))
    importe <= 0 && throw(ArgumentError("Importe no válido"))
    isempty(pagador) && throw(ArgumentError("Pagador vacío"))
    isempty(participantes) && throw(ArgumentError("Sin participantes"))

    length(unique(participantes)) == length(participantes) ||
        throw(ArgumentError("Participantes duplicados"))

    id = isempty(gastos) ? 1 : maximum(g.id for g in gastos) + 1

    nuevo_gasto = Gasto(
        id,
        concepto,
        importe,
        pagador,
        participantes
    )

    push!(gastos, nuevo_gasto)

    try
        guardar_gastos(gastos)
    catch
        pop!(gastos)
        rethrow()
    end

    return nuevo_gasto
end

function eliminar_gasto!(gastos::Vector{Gasto}, id::Int)
    indice = findfirst(g -> g.id == id, gastos)

    indice === nothing && return false

    eliminado = gastos[indice]
    deleteat!(gastos, indice)

    try
        guardar_gastos(gastos)
    catch
        insert!(gastos, indice, eliminado)
        rethrow()
    end

    return true
end