function crear_vista_gastos(personas::Vector{String},gastos::Vector{Gasto})

    vista = GtkBox(:v, 15)

    titulo = GtkLabel("Gestión de gastos")
    push!(vista, titulo)

    columnas = GtkBox(:h, 20)
    push!(vista, columnas)

    # LISTA DE GASTOS

    columna_lista = GtkBox(:v, 10)

    push!(columna_lista, GtkLabel("Gastos registrados"))

    # GtkStack permite sustituir fácilmente el contenido
    stack_lista = GtkStack()

    function crear_lista()

        contenedor = GtkBox(:v, 8)

        if isempty(gastos)
            push!(contenedor, GtkLabel("No hay gastos registrados."))
        end

        for gasto in gastos

            fila = GtkBox(:h, 8)

            texto = "$(gasto.concepto) — $(gasto.importe) €"

            etiqueta = GtkLabel(texto)
            boton_eliminar = GtkButton("×")

            push!(fila, etiqueta)
            push!(fila, boton_eliminar)

            signal_connect(boton_eliminar, "clicked") do widget

                if eliminar_gasto!(gastos, gasto.id)
                    actualizar_lista()
                end

            end

            push!(contenedor, fila)
        end

        return contenedor
    end

    function actualizar_lista()
        nuevo_contenedor = crear_lista()

        # Añadir una nueva página y mostrarla
        push!(stack_lista, nuevo_contenedor)
        set_gtk_property!(
            stack_lista,
            :visible_child,
            nuevo_contenedor
        )
    end

    actualizar_lista()

    push!(columna_lista, stack_lista)

    # ==========================================
    # COLUMNA DERECHA: AÑADIR GASTO
    # ==========================================

    columna_formulario = GtkBox(:v, 10)

    push!(columna_formulario, GtkLabel("Añadir gasto"))

    # Concepto
    entrada_concepto = GtkEntry()

    set_gtk_property!(
        entrada_concepto,
        :placeholder_text,
        "Concepto del gasto"
    )

    push!(columna_formulario, entrada_concepto)

    # Importe
    entrada_importe = GtkEntry()

    set_gtk_property!(
        entrada_importe,
        :placeholder_text,
        "Importe (€)"
    )

    push!(columna_formulario, entrada_importe)

    # Pagador
    push!(columna_formulario, GtkLabel("Pagador"))

    combo_pagador = GtkDropDown(personas)
    push!(columna_formulario, combo_pagador)

    # Participantes
    push!(columna_formulario, GtkLabel("Participantes"))

    checks_participantes = GtkCheckButton[]

    for persona in personas

        check = GtkCheckButton(persona)

        push!(checks_participantes, check)
        push!(columna_formulario, check)

    end

    # Botón añadir
    btn_anadir = GtkButton("Añadir gasto")

    push!(columna_formulario, btn_anadir)

    signal_connect(btn_anadir, "clicked") do widget

        concepto = String(strip(
            get_gtk_property(
                entrada_concepto,
                :text,
                String
            )
        ))

        texto_importe = String(strip(
            get_gtk_property(
                entrada_importe,
                :text,
                String
            )
        ))

        importe = tryparse(
            Float64,
            replace(texto_importe, "," => ".")
        )

        # Validaciones
        if isempty(concepto)
            println("Introduce un concepto.")
            return
        end

        if importe === nothing || importe <= 0
            println("Introduce un importe válido.")
            return
        end

        if isempty(personas)
            println("No hay personas registradas.")
            return
        end

        # Pagador
        indice_pagador = Gtk4.selected(combo_pagador)

        if indice_pagador === nothing
            println("Selecciona un pagador.")
            return
        end

        pagador = personas[indice_pagador]

        # Participantes
        participantes = String[]

        for (i, check) in enumerate(checks_participantes)

            if get_gtk_property(check, :active, Bool)
                push!(participantes, personas[i])
            end

        end

        if isempty(participantes)
            println("Selecciona al menos un participante.")
            return
        end

        # Guardar
        try

            anadir_gasto!(
                gastos,
                concepto,
                importe,
                pagador,
                participantes
            )

            actualizar_lista()

            # Limpiar formulario
            set_gtk_property!(entrada_concepto, :text, "")
            set_gtk_property!(entrada_importe, :text, "")

            for check in checks_participantes
                set_gtk_property!(check, :active, false)
            end

        catch error

            println("Error al guardar el gasto: ", error)

        end

    end

    # ==========================================
    # AÑADIR COLUMNAS A LA VISTA
    # ==========================================

    push!(columnas, columna_lista)
    push!(columnas, columna_formulario)

    return vista
end