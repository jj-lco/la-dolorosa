using Gtk4

# Lógica
include("src/personas.jl")
include("src/gastos.jl")
#include("balances.jl")
#include("optimizacion.jl")

# Interfaz gráfica
include("interfaz/vista_personas.jl")
include("interfaz/vista_gastos.jl")
include("interfaz/vista_balances.jl")
include("interfaz/vista_optimizacion.jl")


function main()

    win = GtkWindow("LaDolorosa", 900, 600)
    main_box = GtkBox(:h)
    menu = GtkBox(:v)
    stack = GtkStack()

    # Cargar datos
    personas = cargar_personas()
    gastos = cargar_gastos()
    
    # Crear pantallas
    vista_personas = crear_vista_personas(personas)
    vista_gastos = crear_vista_gastos(personas,gastos)

    pantalla_balances = GtkBox(:v)
    push!(pantalla_balances, GtkLabel("Balances"))
    
    pantalla_opt = GtkBox(:v)
    push!(pantalla_opt, GtkLabel("Optimización"))

    # Añadir pantallas al stack
    push!(stack, vista_personas, "personas")
    push!(stack, vista_gastos, "gastos")
    push!(stack, pantalla_balances, "balances")
    push!(stack, pantalla_opt, "optimizacion")

    # Botones
    btn_personas = GtkButton("Participantes")
    btn_gastos = GtkButton("Gastos")
    btn_balances = GtkButton("Balances")
    btn_opt = GtkButton("Optimización")

    # Conectar botones
    signal_connect(btn_personas, "clicked") do widget
        set_gtk_property!(stack, :visible_child_name, "personas")
    end

    signal_connect(btn_gastos, "clicked") do widget
        set_gtk_property!(stack, :visible_child_name, "gastos")
    end

    signal_connect(btn_balances, "clicked") do widget
        set_gtk_property!(stack, :visible_child_name, "balances")
    end

    signal_connect(btn_opt, "clicked") do widget
        set_gtk_property!(stack, :visible_child_name, "optimizacion")
    end

    # Construir menú
    foreach(b -> push!(menu, b), [
        btn_personas,
        btn_gastos,
        btn_balances,
        btn_opt
    ])

    push!(main_box, menu)
    push!(main_box, stack)

    win[] = main_box

    present(win)

end

main()