% ============================================================================
% SISTEMA INTELIGENTE DE GESTIÓN DE CONCESIONARIO EL VEHÍCULO SOÑADO
% Práctica II - Lenguajes y Paradigmas de la Computación
% ============================================================================

% BASE DE DATOS DE VEHÍCULOS
vehiculo(renault, logan, sedan, 20000, 2024).
vehiculo(mazda, cx50, suv, 44000, 2023).
vehiculo(toyota, corolla_cross, suv, 30600, 2022).
vehiculo(byd, yuan_up, suv, 30600, 2025).
vehiculo(mazda, m3, sedan, 20400, 2020).
vehiculo(ford, f150, pickup, 50100, 2021).
vehiculo(mazda, miata, sport, 40800, 2024).
vehiculo(chevrolet, z72, pickup, 60900, 2023).
vehiculo(porsche, '718', sport, 130000, 2021).
vehiculo(toyota, sequoya, suv, 153000, 2024).
vehiculo(bmw, x5, suv, 45000, 2021).
vehiculo(ford, ranger, pickup, 42000, 2021).

% ============================================================================
% VALIDACIÓN Y CONSULTAS
% ============================================================================

% Verifica si un vehículo está dentro del rango de presupuesto
dentro_presupuesto(Referencia, LimiteMax) :-
    vehiculo(_, Referencia, _, Costo, _),
    Costo =< LimiteMax.

% Búsqueda por marca con detalles completos
buscar_por_marca(Marca, ListaCompleta) :-
    findall(
        vehiculo(Marca, Ref, Tipo, Precio, Ano),
        vehiculo(Marca, Ref, Tipo, Precio, Ano),
        ListaCompleta).

% Agrupación inteligente por marca usando bagof
agrupar_marca(Marca, Agrupacion) :-
    bagof(
        info(Ref, Tipo, Precio, Ano),
        vehiculo(Marca, Ref, Tipo, Precio, Ano),
        Agrupacion).

% Filtrado avanzado por múltiples criterios
filtrar_avanzado(Marca, Tipo, MaxPrecio, Resultado) :-
    bagof(
        auto(Ref, Precio, Ano),
        (vehiculo(Marca, Ref, Tipo, Precio, Ano), Precio =< MaxPrecio),
        Resultado).

% ============================================================================
% SISTEMA DE REPORTES FINANCIEROS
% ============================================================================

% Reporte principal con análisis financiero
reporte_completo(Marca, Tipo, Presupuesto, Analisis) :-
    findall(
        [Ref, Precio, Ano],
        (vehiculo(Marca, Ref, Tipo, Precio, Ano), Precio =< Presupuesto),
        Vehiculos),
    sumar_inventario(Vehiculos, ValorTotal),
    contar_elementos(Vehiculos, Cantidad),
    calcular_promedio(ValorTotal, Cantidad, Promedio),
    Analisis = informe(
        vehiculos(Vehiculos),
        total(ValorTotal),
        cantidad(Cantidad),
        promedio(Promedio)).

% Suma recursiva del inventario
sumar_inventario([], 0).
sumar_inventario([[_, Precio, _]|Cola], Total) :-
    sumar_inventario(Cola, SubTotal),
    Total is SubTotal + Precio.

% Contador de elementos
contar_elementos(Lista, Cantidad) :- length(Lista, Cantidad).

% Cálculo de precio promedio
calcular_promedio(_, 0, 0) :- !.
calcular_promedio(Total, Cantidad, Promedio) :-
    Promedio is Total / Cantidad.

% Reporte con restricción de inventario máximo
reporte_con_limite(Marca, Tipo, Presupuesto, LimiteInventario, ReporteOptimizado) :-
    findall(
        [Ref, Precio, Ano],
        (vehiculo(Marca, Ref, Tipo, Precio, Ano), Precio =< Presupuesto),
        TodosVehiculos),
    ordenar_por_costo(TodosVehiculos, Ordenados),
    seleccionar_hasta_limite(Ordenados, LimiteInventario, 0, Seleccionados, TotalFinal),
    ReporteOptimizado = optimizado(
        seleccionados(Seleccionados),
        valor_total(TotalFinal),
        limite(LimiteInventario)).

% Ordenamiento por precio (menor a mayor)
ordenar_por_costo(Vehiculos, Ordenados) :-
    sort(2, @=<, Vehiculos, Ordenados).

% Selección acumulativa hasta el límite
seleccionar_hasta_limite([], _, Acum, [], Acum).
seleccionar_hasta_limite([[Ref, Precio, Ano]|Resto], Limite, Acum, Seleccion, TotalFinal) :-
    NuevoAcum is Acum + Precio,
    (   NuevoAcum =< Limite
    ->  seleccionar_hasta_limite(Resto, Limite, NuevoAcum, RestoSel, TotalFinal),
        Seleccion = [[Ref, Precio, Ano]|RestoSel]
    ;   Seleccion = [],
        TotalFinal = Acum).

% ============================================================================
% CASOS DE PRUEBA
% ============================================================================

% PRUEBA 1: Toyota SUVs económicos (bajo $30,000)
prueba_toyota_economico(Resultado) :-
    findall(
        Referencia,
        (vehiculo(toyota, Referencia, suv, Precio, _), Precio < 30000),
        Resultado),
    format('~nVehículos Toyota SUV bajo $30,000: ~w~n', [Resultado]).

% PRUEBA 2: Inventario Ford clasificado por tipo y año
prueba_ford_clasificado :-
    format('~n=== INVENTARIO FORD CLASIFICADO ===~n'),
    forall(
        bagof(Referencias, Precio^vehiculo(ford, Referencias, Tipo, Precio, Ano), Lista),
        format('Tipo: ~w | Año: ~w | Referencias: ~w~n', [Tipo, Ano, Lista])).

% PRUEBA 3: Análisis de sedanes con límite presupuestario
prueba_sedanes_limitado(Analisis) :-
    findall(
        [Ref, Precio, Anno],
        vehiculo(_, Ref, sedan, Precio, Anno),
        TodosSedanes),
    seleccionar_hasta_limite(TodosSedanes, 500000, 0, Seleccionados, Total),
    contar_elementos(Seleccionados, Cantidad),
    Analisis = analisis_sedanes(
        seleccionados(Seleccionados),
        total_invertido(Total),
        cantidad_vehiculos(Cantidad),
        limite_presupuestal(500000),
        ahorro(Ahorro)),
    Ahorro is 500000 - Total,
    format('~n=== ANÁLISIS DE SEDANES ===~n'),
    format('Total invertido: $~w~n', [Total]),
    format('Vehículos seleccionados: ~w~n', [Cantidad]),
    format('Ahorro disponible: $~w~n', [Ahorro]).

% ============================================================================
% CONSULTAS ADICIONALES AVANZADAS
% ============================================================================

% Análisis por categoría con estadísticas
estadisticas_por_tipo(Tipo, Stats) :-
    findall(Precio, vehiculo(_, _, Tipo, Precio, _), Precios),
    length(Precios, Total),
    sum_list(Precios, SumaTotal),
    Promedio is SumaTotal / Total,
    max_list(Precios, Maximo),
    min_list(Precios, Minimo),
    Stats = estadisticas(
        tipo(Tipo),
        cantidad(Total),
        suma_total(SumaTotal),
        precio_promedio(Promedio),
        mas_caro(Maximo),
        mas_barato(Minimo)
    ).

% Vehículo premium (más costoso del inventario)
vehiculo_premium(Info) :-
    findall(
        [Precio, Marca, Ref, Tipo, Ano],
        vehiculo(Marca, Ref, Tipo, Precio, Ano),
        Todos
    ),
    sort(1, @>=, Todos, [[P, M, R, T, A]|_]),
    Info = premium(marca(M), modelo(R), tipo(T), precio(P), ano(A)).

% Oportunidad económica (más barato disponible)
mejor_oferta(Info) :-
    findall(
        [Precio, Marca, Ref, Tipo, Ano],
        vehiculo(Marca, Ref, Tipo, Precio, Ano),
        Todos
    ),
    sort(1, @=<, Todos, [[P, M, R, T, A]|_]),
    Info = oferta(marca(M), modelo(R), tipo(T), precio(P), ano(A)).

% Inventario total valorizado
valoracion_total_inventario(Informe) :-
    findall(Precio, vehiculo(_, _, _, Precio, _), TodosPrecios),
    sum_list(TodosPrecios, ValorTotal),
    length(TodosPrecios, CantidadTotal),
    Promedio is ValorTotal / CantidadTotal,
    Informe = inventario_global(
        valor_total(ValorTotal),
        unidades(CantidadTotal),
        valor_promedio(Promedio)).

% Comparador de marcas
comparar_marcas(Marca1, Marca2, Comparacion) :-
    estadisticas_por_tipo(_, Stats1),
    Stats1 = estadisticas(tipo(_), _, suma_total(Total1), _, _, _),
    estadisticas_por_tipo(_, Stats2),
    Stats2 = estadisticas(tipo(_), _, suma_total(Total2), _, _, _),
    (Total1 > Total2 -> Ganador = Marca1; Ganador = Marca2),
    Comparacion = ganador(Ganador).

% ============================================================================
% MENÚ DE CONSULTAS RÁPIDAS
% ============================================================================
ejecutar_pruebas :-
    format('~n+----------------------------------------------------------+~n'),
    format('¦  SISTEMA DE GESTIÓN DE CONCESIONARIO EL VEHÍCULO SOÑADO  ¦~n'),
    format('+----------------------------------------------------------+~n'),
    prueba_toyota_economico(_),
    prueba_ford_clasificado,
    prueba_sedanes_limitado(_),
    format('~n[Pruebas completadas exitosamente, ¡sigue haciendo más!]~n').

