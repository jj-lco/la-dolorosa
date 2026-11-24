using JSON

const RUTA_PERSONAS = "../datos/personas.json"

function cargar_personas()
    if !isfile(RUTA_PERSONAS)
        return String[]
    end

    return String.(JSON.parsefile(RUTA_PERSONAS))
end

function guardar_personas(personas::Vector{String})

    mkpath(dirname(RUTA_PERSONAS))

    open(RUTA_PERSONAS, "w") do archivo
        JSON.print(archivo, personas, 4)
    end

    return nothing
end

function añadir_persona!(personas::Vector{String}, nombre::String)
    nombre = strip(nombre)
    
    if isempty(nombre) || nombre in personas
        return false
    end

    push!(personas, nombre)
    guardar_personas(personas)

    return true
end

function eliminar_persona!(personas::Vector{String}, nombre::String)
    indice = findfirst(==(nombre), personas)

    if indice === nothing
        return false
    end

    deleteat!(personas, indice)
    guardar_personas(personas)

    return true
end