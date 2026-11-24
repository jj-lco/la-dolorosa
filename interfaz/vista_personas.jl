function crear_vista_personas(personas::Vector{String})

    vista = GtkBox(:v, 10)
    push!(vista, GtkLabel("Participantes"))

    lista = GtkBox(:v, 5)

    filas = Dict{String, GtkBox}()

    function actualizar_lista()

        for (nombre, fila) in filas
            if !(nombre in personas)
                hide(fila)
            end
        end

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
                if eliminar_persona!(personas, persona)
                    hide(fila)
                end
            end

            push!(lista, fila)
        end
    end

    actualizar_lista()
    push!(vista, lista)

    # Entrada de texto
    entrada = GtkEntry()
    set_gtk_property!(
        entrada,
        :placeholder_text,
        "Nombre"
    )
    push!(vista, entrada)

    # Botón añadir
    btn_añadir = GtkButton("Añadir")
    push!(vista, btn_añadir)

    signal_connect(btn_añadir, "clicked") do widget

        nombre = String(strip(
            get_gtk_property(entrada, :text, String)
        ))

        if añadir_persona!(personas, nombre)
            actualizar_lista()
            set_gtk_property!(entrada, :text, "")
        end
    end

    return vista
end