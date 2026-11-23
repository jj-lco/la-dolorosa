function crear_vista_gastos(personas::Vector{String}, gastos::Vector{Gasto})

    # Contenedor principal
    vista = GtkBox(:v, 10)

    # Título
    titulo = GtkLabel("Gestión de gastos")
    push!(vista, titulo)

    # -----------------------------------
    # Concepto del gasto
    # -----------------------------------

    entrada_concepto = GtkEntry()
    set_gtk_property!(
        entrada_concepto,
        :placeholder_text,
        "Concepto del gasto"
    )
    push!(vista, entrada_concepto)

    # -----------------------------------
    # Importe
    # -----------------------------------

    entrada_importe = GtkEntry()
    set_gtk_property!(
        entrada_importe,
        :placeholder_text,
        "Importe (€)"
    )
    push!(vista, entrada_importe)

    # -----------------------------------
    # Selección del pagador
    # -----------------------------------

    etiqueta_pagador = GtkLabel("¿Quién ha pagado?")
    push!(vista, etiqueta_pagador)

    combo_pagador = GtkDropDown(personas)
    push!(vista, combo_pagador)

    # -----------------------------------
    # Selección de participantes
    # -----------------------------------

    etiqueta_participantes = GtkLabel("Participantes:")
    push!(vista, etiqueta_participantes)

    checks_participantes = GtkCheckButton[]

    for persona in personas
        check = GtkCheckButton(persona)
        push!(checks_participantes, check)
        push!(vista, check)
    end

    # -----------------------------------
    # Lista de gastos registrados
    # -----------------------------------

    etiqueta_lista = GtkLabel("Gastos registrados")
    push!(vista, etiqueta_lista)

    lista_gastos = GtkLabel("")

    function actualizar_lista_gastos()
        if isempty(gastos)
            texto = "Todavía no hay gastos registrados."
        else
            lineas = String[]

            for gasto in gastos
                push!(
                    lineas,
                    "$(gasto.concepto): $(gasto.importe) € - Pagó: $(gasto.pagador)"
                )
            end

            texto = join(lineas, "\n")
        end

        set_gtk_property!(lista_gastos, :label, texto)
    end

    actualizar_lista_gastos()
    push!(vista, lista_gastos)

    # -----------------------------------
    # Botón añadir gasto
    # -----------------------------------

    btn_anadir = GtkButton("Añadir gasto")
    push!(vista, btn_anadir)

    signal_connect(btn_anadir, "clicked") do widget

        concepto = strip(
            get_gtk_property(entrada_concepto, :text, String)
        )

        texto_importe = strip(
            get_gtk_property(entrada_importe, :text, String)
        )

        # Validar concepto
        if isempty(concepto)
            println("Introduce un concepto.")
            return
        end

        # Validar importe
        importe = tryparse(Float64, replace(texto_importe, "," => "."))

        if importe === nothing || importe <= 0
            println("Introduce un importe válido.")
            return
        end

        # Validar pagador
        indice_pagador = get_gtk_property(
            combo_pagador,
            :selected,
            UInt32
        )

        if indice_pagador >= length(personas)
            println("Selecciona un pagador.")
            return
        end

        pagador = personas[Int(indice_pagador) + 1]

        # Obtener participantes seleccionados
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

        # Crear gasto
        nuevo_gasto = Gasto(
            concepto,
            importe,
            pagador,
            participantes
        )

        push!(gastos, nuevo_gasto)

        # Actualizar interfaz
        actualizar_lista_gastos()

        # Limpiar campos
        set_gtk_property!(entrada_concepto, :text, "")
        set_gtk_property!(entrada_importe, :text, "")

        for check in checks_participantes
            set_gtk_property!(check, :active, false)
        end

        println("Gasto añadido correctamente.")
    end

    return vista
end