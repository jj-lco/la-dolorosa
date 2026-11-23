function crear_vista_personas(personas::Vector{String})

    vista = GtkBox(:v, 10)

    # Título
    push!(vista, GtkLabel("Gestión de personas"))

    # Contenedor de personas
    lista = GtkBox(:v, 5)
    push!(vista, lista)

    # Guardamos las filas para poder actualizarlas
    filas = Dict{String, GtkBox}()

    function actualizar_lista()

        # Ocultar las filas que ya no están en personas
        for (nombre, fila) in filas
            if !(nombre in personas)
                hide(fila)
            end
        end

        # Crear filas para las personas nuevas
        for persona in personas

            if haskey(filas, persona)
                show(filas[persona])
                continue
            end

            fila = GtkBox(:h, 5)

            etiqueta = GtkLabel(persona)
            btn_eliminar = GtkButton("×")

            push!(fila, etiqueta)
            push!(fila, btn_eliminar)

            filas[persona] = fila

            signal_connect(btn_eliminar, "clicked") do widget

                indice = findfirst(==(persona), personas)

                if indice !== nothing
                    deleteat!(personas, indice)
                    hide(fila)
                end

            end

            push!(lista, fila)
        end
    end

    actualizar_lista()

    # Campo para añadir personas
    entrada = GtkEntry()
    set_gtk_property!(
        entrada,
        :placeholder_text,
        "Nombre de la persona"
    )
    push!(vista, entrada)

    # Botón añadir
    btn_anadir = GtkButton("Añadir persona")
    push!(vista, btn_anadir)

    signal_connect(btn_anadir, "clicked") do widget

        nombre = strip(
            get_gtk_property(entrada, :text, String)
        )

        if !isempty(nombre) && !(nombre in personas)

            push!(personas, nombre)
            actualizar_lista()

            set_gtk_property!(entrada, :text, "")
        end
    end

    return vista
end