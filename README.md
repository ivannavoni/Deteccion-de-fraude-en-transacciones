Deteccion de fraude en transacciones

Identificar y alertar transacciones fraudulentas de cuentas con múltiples movimientos en ubicaciones geográficas distintas dentro de un lapso muy corto.

Objetivo: Identificar y alertar transacciones que cumplen el patrón de "Viaje Imposible": cuentas con múltiples movimientos en ubicaciones geográficas distintas dentro de un lapso muy corto.
Impacto: Diseño e implementación de un motor de reglas SQL para aislar anomalías de alto riesgo en la base de datos, demostrando la capacidad de generar Alertas de Riesgo para el equipo de fraude.
Conocimiento utilizado: LAG, OVER, WITH (CTE), PARTITION BY (aparte de las funciones basicas como SELECT, FROM, WHERE, ORDER BY)
Base de datos: Banking transactions

Explicación del Proceso (Metodología de Ventana)
1. Preparación de Datos y Creación de la Ventana Secuencial
Para cumplir con la consigna, la metodología se centró en la comparación de transacciones consecutivas del mismo emisor:
•	Aislamiento por Usuario (PARTITION BY): Se utilizó la función de ventana LAG() dentro de la cláusula OVER. Se aplicó PARTITION BY "Sender Account ID" para agrupar las filas, asegurando que el cálculo de la transacción anterior solo se realice dentro del historial de cada cuenta individual.
•	Definición de Secuencia (ORDER BY): Dentro de cada partición, se utilizó ORDER BY "Timestamp" para establecer el orden cronológico de las transacciones, lo cual es fundamental para definir correctamente qué es la fila "anterior". Este orden se mantiene idéntico en todos los cálculos de LAG.
•	Obtención de Datos Anteriores: Se aplicó LAG(columna, 1) dos veces:
o	Para obtener el previous_timestamp (el tiempo de la transacción anterior).
o	Para obtener la previous_location (la ubicación de la transacción anterior).

2. Estructuración con CTE
Se encapsuló toda esta lógica de cálculo dentro de una Expresión de Tabla Común (WITH LAGDATA AS (...)). Esto se hizo para a) mantener la claridad del código y b) permitir el uso posterior de los alias (previous_location, etc.) en la cláusula WHERE de la consulta principal.

3. Aplicación de la Regla de Riesgo (La Consulta Final)
La consulta principal aplicó los siguientes filtros al conjunto de datos generado por el CTE:
•	Filtro de Historial (IS NOT NULL): Se utilizó WHERE previous_location IS NOT NULL para eliminar las primeras transacciones de cada cuenta, ya que no tienen un historial para comparar.
•	Conclusión del Filtro Inicial: Al aplicar la lógica inicial de AND "Fraud Flag" = 'True' sobre la data, se confirmó una limitación: solo una cuenta cumplía con el doble criterio de tener historial de transacciones y estar pre-marcada como fraude, lo que sugiere que el dataset original estaba incompleto o no estaba optimizado para este patrón de riesgo.
