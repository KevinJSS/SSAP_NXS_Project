# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# User.create!(
#     email: "kevin@gmail.com",
#     password: "kevin1234",
#     id_card: "208880111",
#     fullname: "Kevin Alvarado Pérez",
#     phone: "(+506) 8888 8881",
#     address: "Dirección de habitación aquí",
#     role: 1,
#     job_position: "Desarrollador",
#     account_number: "CR12309870131",
#     id_card_type: 0,
#     marital_status: 0,
#     birth_date: Date.new(1990, 1, 1),
#     province: "Alajuela",
#     canton: "Naranjo",
#     district: "Centro",
#     education: 3,
#     nationality: "Costarricense",
#     gender: 0
#   )

Phase.create(code: 'I-01', name: 'Inicio')
Phase.create(code: 'T-01', name: 'Terreno')
Phase.create(code: 'S-01', name: 'Estructura')
Phase.create(code: 'A-01', name: 'Acabados')
Phase.create(code: 'E-01', name: 'Electricidad')
Phase.create(code: 'F-01', name: 'Fontanería')
Phase.create(code: 'I-02', name: 'Bodega G')
Phase.create(code: 'I-03', name: 'Acceso Temporal G')
Phase.create(code: 'I-04', name: 'Barreras y Cerramiento G')
Phase.create(code: 'I-05', name: 'Identificación Proyecto G')
Phase.create(code: 'I-06', name: 'Instalación provisional G')
Phase.create(code: 'I-07', name: 'Cabañas Sanitarias G')
Phase.create(code: 'I-08', name: 'Seguridad Temporal S')
Phase.create(code: 'I-09', name: 'Batidoras S')
Phase.create(code: 'I-10', name: 'Herramienta Liviana G')
Phase.create(code: 'I-11', name: 'Vibrador S')
Phase.create(code: 'I-12', name: 'Puntales S')
Phase.create(code: 'I-13', name: 'Transporte de Materiales S')
Phase.create(code: 'I-14', name: 'Andamios S')
Phase.create(code: 'I-15', name: 'Plataformas S')
Phase.create(code: 'I-16', name: 'Oficina de Obra G')
Phase.create(code: 'I-17', name: 'Planos y Copias M')
Phase.create(code: 'I-18', name: 'Maestro de Obras O')
Phase.create(code: 'I-19', name: 'Maestro de Obras S')
Phase.create(code: 'I-20', name: 'Bodeguero y Planillero O')
Phase.create(code: 'I-21', name: 'Bodeguero y Planillero S')
Phase.create(code: 'I-22', name: 'Transporte de Personal S')
Phase.create(code: 'I-23', name: 'Vivienda de Personal S')
Phase.create(code: 'I-24', name: 'Alimentación de Personal S')
Phase.create(code: 'I-25', name: 'Supervisor de Seguridad Ocupacional S')
Phase.create(code: 'I-26', name: 'Equipo de Seguridad M')
Phase.create(code: 'I-27', name: 'Control de Calidad O')
Phase.create(code: 'I-28', name: 'Control de Calidad S')
Phase.create(code: 'I-29', name: 'Inspección y Pruebas de Laboratorio S')
Phase.create(code: 'I-30', name: 'Limpieza para entrega final M')
Phase.create(code: 'I-31', name: 'Limpieza para entrega final O')
Phase.create(code: 'I-32', name: 'Limpieza para entrega final S')
Phase.create(code: 'I-33', name: 'Mantenimiento M')
Phase.create(code: 'I-34', name: 'Mantenimiento O')
Phase.create(code: 'I-35', name: 'Mantenimiento S')
Phase.create(code: 'I-36', name: 'Seguro Todo Riesgo de Construcción G')
Phase.create(code: 'I-37', name: 'Garantías G')
Phase.create(code: 'I-38', name: 'Póliza de Riesgos Laborales G')
Phase.create(code: 'I-39', name: 'Servicios Médicos y Emergencia G')
Phase.create(code: 'I-40', name: 'Bote de Basura S')
Phase.create(code: 'I-41', name: 'Plancha compactadora S')
Phase.create(code: 'I-42', name: 'Trazo G')
Phase.create(code: 'I-43', name: 'Estudios de Suelos S')
Phase.create(code: 'I-44', name: 'Alquiler de equipo S')
Phase.create(code: 'T-01', name: 'Terreno')
Phase.create(code: 'T-02', name: 'Limpieza terreno M')
Phase.create(code: 'T-03', name: 'Limpieza terreno O')
Phase.create(code: 'T-04', name: 'Limpieza terreno S')
Phase.create(code: 'T-05', name: 'Tala y Poda de Árboles M')
Phase.create(code: 'T-06', name: 'Tala y Poda de Árboles O')
Phase.create(code: 'T-07', name: 'Tala y Poda de Árboles S')
Phase.create(code: 'T-08', name: 'Demolición de Edificaciones M')
Phase.create(code: 'T-09', name: 'Demolición de Edificaciones O')
Phase.create(code: 'T-10', name: 'Demolición de Edificaciones S')
Phase.create(code: 'T-11', name: 'Relocalización de Edificaciones M')
Phase.create(code: 'T-12', name: 'Relocalización de Edificaciones M')
Phase.create(code: 'T-13', name: 'Relocalización de Edificaciones M')
Phase.create(code: 'T-14', name: 'Moviminero de tierras M')
Phase.create(code: 'T-15', name: 'Movimiento de tierras O')
Phase.create(code: 'T-16', name: 'Moviminero de tierras S')
Phase.create(code: 'T-17', name: 'Rellenos M')
Phase.create(code: 'T-18', name: 'Rellenos O')
Phase.create(code: 'T-19', name: 'Rellenos S')
Phase.create(code: 'T-20', name: 'Estabilización y Tratamiento de Suelos M')
Phase.create(code: 'T-21', name: 'Estabilización y Tratamiento de Suelos O')
Phase.create(code: 'T-22', name: 'Estabilización y Tratamiento de Suelos S')
Phase.create(code: 'T-23', name: 'Drenajes de Sitio M')
Phase.create(code: 'T-24', name: 'Drenajes de Sitio O')
Phase.create(code: 'T-25', name: 'Drenajes de Sitio S')
Phase.create(code: 'T-26', name: 'Apuntalamiento y Tabla Estaqueado M')
Phase.create(code: 'T-27', name: 'Apuntalamiento y Tabla Estaqueado O')
Phase.create(code: 'T-28', name: 'Apuntalamiento y Tabla Estaqueado S')
Phase.create(code: 'T-29', name: 'Muros de Contención M')
Phase.create(code: 'T-30', name: 'Muros de Contención O')
Phase.create(code: 'T-31', name: 'Muros de Contención S')
Phase.create(code: 'T-32', name: 'Control de Erosión M')
Phase.create(code: 'T-33', name: 'Control de Erosión O')
Phase.create(code: 'T-34', name: 'Control de Erosión S')
Phase.create(code: 'T-35', name: 'Base y Sub Base M')
Phase.create(code: 'T-36', name: 'Base y Sub Base O')
Phase.create(code: 'T-37', name: 'Base y Sub Base S')
Phase.create(code: 'T-38', name: 'Pavimento M')
Phase.create(code: 'T-39', name: 'Pavimento O')
Phase.create(code: 'T-40', name: 'Pavimento S')
Phase.create(code: 'T-41', name: 'Alcantarillas y Desagües M')
Phase.create(code: 'T-42', name: 'Alcantarillas y Desagües O')
Phase.create(code: 'T-43', name: 'Alcantarillas y Desagües S')
Phase.create(code: 'T-44', name: 'Barreras y Vallas M')
Phase.create(code: 'T-45', name: 'Barreras y Vallas O')
Phase.create(code: 'T-46', name: 'Barreras y Vallas S')
Phase.create(code: 'T-47', name: 'Demarcación M')
Phase.create(code: 'T-48', name: 'Demarcación O')
Phase.create(code: 'T-49', name: 'Demarcación S')
Phase.create(code: 'T-50', name: 'Señalización M')
Phase.create(code: 'T-51', name: 'Señalización O')
Phase.create(code: 'T-52', name: 'Señalización S')
Phase.create(code: 'T-53', name: 'Parqueos M')
Phase.create(code: 'T-54', name: 'Parqueos O')
Phase.create(code: 'T-55', name: 'Parqueos S')
Phase.create(code: 'T-56', name: 'Acera cordón y caño M')
Phase.create(code: 'T-57', name: 'Acera cordón y caño O')
Phase.create(code: 'T-58', name: 'Acera cordón y caño S')
Phase.create(code: 'T-59', name: 'Cercas y Portones M')
Phase.create(code: 'T-60', name: 'Cercas y Portones O')
Phase.create(code: 'T-61', name: 'Cercas y Portones S')
Phase.create(code: 'T-62', name: 'Tapias M')
Phase.create(code: 'T-63', name: 'Tapias O')
Phase.create(code: 'T-64', name: 'Tapias S')
Phase.create(code: 'T-65', name: 'Mobiliario de Sitio M')
Phase.create(code: 'T-66', name: 'Mobiliario de Sitio O')
Phase.create(code: 'T-67', name: 'Mobiliario de Sitio S')
Phase.create(code: 'T-68', name: 'Campos de Juego M')
Phase.create(code: 'T-69', name: 'Campos de Juego O')
Phase.create(code: 'T-70', name: 'Campos de Juego S')
Phase.create(code: 'T-71', name: 'Capa Vegetal M')
Phase.create(code: 'T-72', name: 'Capa Vegetal O')
Phase.create(code: 'T-73', name: 'Capa Vegetal S')
Phase.create(code: 'T-74', name: 'Plantas M')
Phase.create(code: 'T-75', name: 'Plantas O')
Phase.create(code: 'T-76', name: 'Plantas S')
Phase.create(code: 'T-77', name: 'Rampa de acceso M')
Phase.create(code: 'T-78', name: 'Rampa de acceso O')
Phase.create(code: 'T-79', name: 'Rampa de acceso S')
Phase.create(code: 'T-80', name: 'Adoquines M')
Phase.create(code: 'T-81', name: 'Adoquines O')
Phase.create(code: 'T-82', name: 'Adoquines S')
Phase.create(code: 'S-01', name: 'Estructura')
Phase.create(code: 'S-02', name: 'Zanjeo M')
Phase.create(code: 'S-03', name: 'Zanjeo O')
Phase.create(code: 'S-04', name: 'Zanjeo S')
Phase.create(code: 'S-05', name: 'Muros de contención M')
Phase.create(code: 'S-06', name: 'Muros de contención O')
Phase.create(code: 'S-07', name: 'Muros de contención S')
Phase.create(code: 'S-08', name: 'Placas Corridas M')
Phase.create(code: 'S-09', name: 'Placas Corridas O')
Phase.create(code: 'S-10', name: 'Placas Corridas S')
Phase.create(code: 'S-11', name: 'Placas Aisladas M')
Phase.create(code: 'S-12', name: 'Placas Aisladas O')
Phase.create(code: 'S-13', name: 'Placas Aisladas S')
Phase.create(code: 'S-14', name: 'Drenajes y Aislamiento Perimetral M')
Phase.create(code: 'S-15', name: 'Drenajes y Aislamiento Perimetral O')
Phase.create(code: 'S-16', name: 'Drenajes y Aislamiento Perimetral S')
Phase.create(code: 'S-17', name: 'Pilotes M')
Phase.create(code: 'S-18', name: 'Pilotes O')
Phase.create(code: 'S-19', name: 'Pilotes S')
Phase.create(code: 'S-20', name: 'Vigas de Amarre M')
Phase.create(code: 'S-21', name: 'Vigas de Amarre O')
Phase.create(code: 'S-22', name: 'Vigas de Amarre S')
Phase.create(code: 'S-23', name: 'Refuerzo y Estabilización M')
Phase.create(code: 'S-24', name: 'Refuerzo y Estabilización O')
Phase.create(code: 'S-25', name: 'Refuerzo y Estabilización S')
Phase.create(code: 'S-26', name: 'Drenado de Terreno M')
Phase.create(code: 'S-27', name: 'Drenado de Terreno O')
Phase.create(code: 'S-28', name: 'Drenado de Terreno S')
Phase.create(code: 'S-29', name: 'Fundaciones Flotantes M')
Phase.create(code: 'S-30', name: 'Fundaciones Flotantes O')
Phase.create(code: 'S-31', name: 'Fundaciones Flotantes S')
Phase.create(code: 'S-32', name: 'Otras Condiciones Especiales M')
Phase.create(code: 'S-33', name: 'Otras Condiciones Especiales O')
Phase.create(code: 'S-34', name: 'Otras Condiciones Especiales S')
Phase.create(code: 'S-35', name: 'Contrapisos M')
Phase.create(code: 'S-36', name: 'Contrapisos O')
Phase.create(code: 'S-37', name: 'Contrapisos S')
Phase.create(code: 'S-38', name: 'Paredes 1 M')
Phase.create(code: 'S-39', name: 'Paredes 1 O')
Phase.create(code: 'S-40', name: 'Paredes 1 S')
Phase.create(code: 'S-41', name: 'Paredes 2 M')
Phase.create(code: 'S-42', name: 'Paredes 2 O')
Phase.create(code: 'S-43', name: 'Paredes 2 S')
Phase.create(code: 'S-44', name: 'Columnas M')
Phase.create(code: 'S-45', name: 'Columnas O')
Phase.create(code: 'S-46', name: 'Columnas S')
Phase.create(code: 'S-47', name: 'Viga corona M')
Phase.create(code: 'S-48', name: 'Viga corona O')
Phase.create(code: 'S-49', name: 'Viga corona S')
Phase.create(code: 'S-50', name: 'Tapicheles M')
Phase.create(code: 'S-51', name: 'Tapicheles O')
Phase.create(code: 'S-52', name: 'Tapicheles S')
Phase.create(code: 'S-53', name: 'Repellos grueso M')
Phase.create(code: 'S-54', name: 'Repellos grueso O')
Phase.create(code: 'S-55', name: 'Repellos grueso S')
Phase.create(code: 'S-56', name: 'Repellos fino M')
Phase.create(code: 'S-57', name: 'Repellos fino O')
Phase.create(code: 'S-58', name: 'Repellos fino S')
Phase.create(code: 'S-59', name: 'Losas en terreno M')
Phase.create(code: 'S-60', name: 'Losas en terreno O')
Phase.create(code: 'S-61', name: 'Losas en terreno S')
Phase.create(code: 'S-62', name: 'Estructura de entrepiso M')
Phase.create(code: 'S-63', name: 'Estructura de entrepiso O')
Phase.create(code: 'S-64', name: 'Estructura de entrepiso S')
Phase.create(code: 'S-65', name: 'Losa de entrepiso M')
Phase.create(code: 'S-66', name: 'Losa de entrepiso O')
Phase.create(code: 'S-67', name: 'Losa de entrepiso S')
Phase.create(code: 'S-68', name: 'Estructura Techos M')
Phase.create(code: 'S-69', name: 'Estructura Techos O')
Phase.create(code: 'S-70', name: 'Estructura Techos S')
Phase.create(code: 'S-71', name: 'Cubierta M')
Phase.create(code: 'S-72', name: 'Cubierta O')
Phase.create(code: 'S-73', name: 'Cubierta S')
Phase.create(code: 'S-71', name: 'Aislamientos para Techo M')
Phase.create(code: 'S-72', name: 'Aislamientos para Techo O')
Phase.create(code: 'S-73', name: 'Aislamientos para Techo S')
Phase.create(code: 'S-74', name: 'Hojalatería M')
Phase.create(code: 'S-75', name: 'Hojalatería O')
Phase.create(code: 'S-76', name: 'Hojalatería S')
Phase.create(code: 'S-77', name: 'Losas en Techos M')
Phase.create(code: 'S-78', name: 'Losas en Techos O')
Phase.create(code: 'S-79', name: 'Losas en Techos S')
Phase.create(code: 'S-80', name: 'Terrazas M')
Phase.create(code: 'S-81', name: 'Terrazas O')
Phase.create(code: 'S-82', name: 'Terrazas S')
Phase.create(code: 'S-83', name: 'Aceras y gradas para ingreso M')
Phase.create(code: 'S-84', name: 'Aceras y gradas para ingreso O')
Phase.create(code: 'S-85', name: 'Aceras y gradas para ingreso S')
Phase.create(code: 'S-86', name: 'Portón de garaje e instalación de motor M')
Phase.create(code: 'S-87', name: 'Portón de garaje e instalación de motor O')
Phase.create(code: 'S-88', name: 'Portón de garaje e instalación de motor S')
Phase.create(code: 'S-89', name: 'Cocheras M')
Phase.create(code: 'S-90', name: 'Cocheras O')
Phase.create(code: 'S-91', name: 'Cocheras S')
Phase.create(code: 'S-92', name: 'Vigas Entrepiso Metalicas')
Phase.create(code: 'S-93', name: 'Cubierta de techos de Policarbonato M')
Phase.create(code: 'S-94', name: 'Cubierta de techos de Policarbonato O')
Phase.create(code: 'S-95', name: 'Precinta M')
Phase.create(code: 'S-96', name: 'Precinta O')
Phase.create(code: 'S-97', name: 'Precinta S')
Phase.create(code: 'S-98', name: 'Viga Banquina M')
Phase.create(code: 'S-99', name: 'Viga Banquina O')
Phase.create(code: 'S-100', name: 'Viga Banquina S')
Phase.create(code: 'A-01', name: 'Acabados')
Phase.create(code: 'A-02', name: 'Pasta en paredes M')
Phase.create(code: 'A-03', name: 'Pasta en paredes O')
Phase.create(code: 'A-04', name: 'Pasta en paredes S')
Phase.create(code: 'A-05', name: 'Pintura en paredes M')
Phase.create(code: 'A-06', name: 'Pintura en paredes O')
Phase.create(code: 'A-07', name: 'Pintura en paredes S')
Phase.create(code: 'A-08', name: 'Pintura y pasta M')
Phase.create(code: 'A-09', name: 'Pintura y pasta O')
Phase.create(code: 'A-10', name: 'Pintura y pasta S')
Phase.create(code: 'A-11', name: 'Enchapes en paredes M')
Phase.create(code: 'A-12', name: 'Enchapes en paredes O')
Phase.create(code: 'A-13', name: 'Enchapes en paredes S')
Phase.create(code: 'A-14', name: 'Acabado especial en paredes M')
Phase.create(code: 'A-15', name: 'Acabado especial en paredes O')
Phase.create(code: 'A-16', name: 'Acabado especial en paredes S')
Phase.create(code: 'A-17', name: 'Ventanas M')
Phase.create(code: 'A-18', name: 'Ventanas O')
Phase.create(code: 'A-19', name: 'Ventanas S')
Phase.create(code: 'A-20', name: 'Cortinas de Seguridad M')
Phase.create(code: 'A-21', name: 'Cortinas de Seguridad O')
Phase.create(code: 'A-22', name: 'Cortinas de Seguridad S')
Phase.create(code: 'A-23', name: 'Muro cortina M')
Phase.create(code: 'A-24', name: 'Muro cortina O')
Phase.create(code: 'A-25', name: 'Muro cortina S')
Phase.create(code: 'A-26', name: 'Puertas externas madera M')
Phase.create(code: 'A-27', name: 'Puertas externas madera O')
Phase.create(code: 'A-28', name: 'Puertas externas madera S')
Phase.create(code: 'A-29', name: 'Puertas externas metal M')
Phase.create(code: 'A-30', name: 'Puertas externas metal O')
Phase.create(code: 'A-31', name: 'Puertas externas metal S')
Phase.create(code: 'A-32', name: 'Llavines exterior M')
Phase.create(code: 'A-33', name: 'Llavines exterior O')
Phase.create(code: 'A-34', name: 'Llavines exterior S')
Phase.create(code: 'A-35', name: 'Otras Puertas y Accesos M')
Phase.create(code: 'A-36', name: 'Otras Puertas y Accesos O')
Phase.create(code: 'A-37', name: 'Otras Puertas y Accesos S')
Phase.create(code: 'A-38', name: 'Puertas Internas M')
Phase.create(code: 'A-39', name: 'Puertas Internas O')
Phase.create(code: 'A-40', name: 'Puertas Internas S')
Phase.create(code: 'A-41', name: 'Llavines Interna M')
Phase.create(code: 'A-42', name: 'Llavines Interna O')
Phase.create(code: 'A-43', name: 'Llavines Interna S')
Phase.create(code: 'A-44', name: 'Aberturas en Vidrio M')
Phase.create(code: 'A-45', name: 'Aberturas en Vidrio O')
Phase.create(code: 'A-46', name: 'Aberturas en Vidrio S')
Phase.create(code: 'A-47', name: 'Escotillas de Techos M')
Phase.create(code: 'A-48', name: 'Escotillas de Techos O')
Phase.create(code: 'A-49', name: 'Escotillas de Techos S')
Phase.create(code: 'A-50', name: 'Monitores M')
Phase.create(code: 'A-51', name: 'Monitores O')
Phase.create(code: 'A-52', name: 'Monitores S')
Phase.create(code: 'A-53', name: 'Particiones Fijas M')
Phase.create(code: 'A-54', name: 'Particiones Fijas O')
Phase.create(code: 'A-55', name: 'Particiones Fijas S')
Phase.create(code: 'A-56', name: 'Particiones Desmontables M')
Phase.create(code: 'A-57', name: 'Particiones Desmontables O')
Phase.create(code: 'A-58', name: 'Particiones Desmontables S')
Phase.create(code: 'A-59', name: 'Particiones Retráctiles M')
Phase.create(code: 'A-60', name: 'Particiones Retráctiles O')
Phase.create(code: 'A-61', name: 'Particiones Retráctiles S')
Phase.create(code: 'A-62', name: 'Metales Ornamentales M')
Phase.create(code: 'A-63', name: 'Metales Ornamentales O')
Phase.create(code: 'A-64', name: 'Metales Ornamentales S')
Phase.create(code: 'A-65', name: 'Closets M')
Phase.create(code: 'A-66', name: 'Closets O')
Phase.create(code: 'A-67', name: 'Closets S')
Phase.create(code: 'A-68', name: 'Gradas M')
Phase.create(code: 'A-69', name: 'Gradas O')
Phase.create(code: 'A-70', name: 'Gradas S')
Phase.create(code: 'A-71', name: 'Baranda y Pasamanos M')
Phase.create(code: 'A-72', name: 'Baranda y Pasamanos O')
Phase.create(code: 'A-73', name: 'Baranda y Pasamanos S (vidrio)')
Phase.create(code: 'A-74', name: 'Cubículos M')
Phase.create(code: 'A-75', name: 'Cubículos O')
Phase.create(code: 'A-76', name: 'Cubículos S')
Phase.create(code: 'A-77', name: 'Señalización M')
Phase.create(code: 'A-78', name: 'Señalización O')
Phase.create(code: 'A-79', name: 'Señalización S')
Phase.create(code: 'A-80', name: 'Nivelación de Pisos M')
Phase.create(code: 'A-81', name: 'Nivelación de Pisos O')
Phase.create(code: 'A-82', name: 'Nivelación de Pisos S')
Phase.create(code: 'A-83', name: 'Enchapes Pisos M')
Phase.create(code: 'A-84', name: 'Enchapes Pisos O')
Phase.create(code: 'A-85', name: 'Enchapes Pisos S')
Phase.create(code: 'A-86', name: 'Alfombrado M')
Phase.create(code: 'A-87', name: 'Alfombrado O')
Phase.create(code: 'A-88', name: 'Alfombrado S')
Phase.create(code: 'A-89', name: 'Bordillos M')
Phase.create(code: 'A-90', name: 'Bordillos O')
Phase.create(code: 'A-91', name: 'Bordillos S')
Phase.create(code: 'A-92', name: 'Acabado de Accesos Peatonales M')
Phase.create(code: 'A-93', name: 'Acabado de Accesos Peatonales O')
Phase.create(code: 'A-94', name: 'Acabado de Accesos Peatonales S')
Phase.create(code: 'A-95', name: 'Estructura de Cielos M')
Phase.create(code: 'A-96', name: 'Estructura de Cielos O')
Phase.create(code: 'A-97', name: 'Estructura de Cielos S')
Phase.create(code: 'A-98', name: 'Cielos M')
Phase.create(code: 'A-99', name: 'Cielos O')
Phase.create(code: 'A-100', name: 'Cielos S')
Phase.create(code: 'A-101', name: 'Aleros M')
Phase.create(code: 'A-102', name: 'Aleros O')
Phase.create(code: 'A-103', name: 'Aleros S')
Phase.create(code: 'A-104', name: 'Otros Cielos M')
Phase.create(code: 'A-105', name: 'Otros Cielos O')
Phase.create(code: 'A-106', name: 'Otros Cielos S')
Phase.create(code: 'A-107', name: 'Pintura de cielos M')
Phase.create(code: 'A-108', name: 'Pintura de cielos O')
Phase.create(code: 'A-109', name: 'Pintura de cielos S')
Phase.create(code: 'A-110', name: 'Inodoros M')
Phase.create(code: 'A-111', name: 'Inodoros O')
Phase.create(code: 'A-112', name: 'Inodoros S')
Phase.create(code: 'A-113', name: 'Lavamanos M')
Phase.create(code: 'A-114', name: 'Lavamanos O')
Phase.create(code: 'A-115', name: 'Lavamanos S')
Phase.create(code: 'A-116', name: 'Loza Sanitaria M')
Phase.create(code: 'A-117', name: 'Loza Sanitaria O')
Phase.create(code: 'A-118', name: 'Loza Sanitaria S')
Phase.create(code: 'A-119', name: 'Fregaderos M')
Phase.create(code: 'A-120', name: 'Fregaderos O')
Phase.create(code: 'A-121', name: 'Fregaderos S')
Phase.create(code: 'A-122', name: 'Tina M')
Phase.create(code: 'A-123', name: 'Tina O')
Phase.create(code: 'A-124', name: 'Tina S')
Phase.create(code: 'A-125', name: 'Jacussi S')
Phase.create(code: 'A-126', name: 'Pilas M')
Phase.create(code: 'A-127', name: 'Pilas O')
Phase.create(code: 'A-128', name: 'Pilas S')
Phase.create(code: 'A-129', name: 'Duchas M')
Phase.create(code: 'A-130', name: 'Duchas O')
Phase.create(code: 'A-131', name: 'Duchas S')
Phase.create(code: 'A-132', name: 'Persianas y Otros Sistemas para Ventanas M')
Phase.create(code: 'A-133', name: 'Persianas y Otros Sistemas para Ventanas O')
Phase.create(code: 'A-134', name: 'Persianas y Otros Sistemas para Ventanas S')
Phase.create(code: 'A-135', name: 'Asientos Fijos M')
Phase.create(code: 'A-136', name: 'Asientos Fijos O')
Phase.create(code: 'A-137', name: 'Asientos Fijos S')
Phase.create(code: 'A-138', name: 'Jardinería de Interiores M')
Phase.create(code: 'A-139', name: 'Jardinería de Interiores O')
Phase.create(code: 'A-140', name: 'Jardinería de Interiores S')
Phase.create(code: 'A-141', name: 'Rodapié M')
Phase.create(code: 'A-142', name: 'Rodapié O')
Phase.create(code: 'A-143', name: 'Rodapié S')
Phase.create(code: 'A-144', name: 'Mamparas S')
Phase.create(code: 'A-145', name: 'Electrodomésticos, muebles, comedor, camas')
Phase.create(code: 'A-146', name: 'Accesorios para baño M')
Phase.create(code: 'A-147', name: 'Muebles de baño S')
Phase.create(code: 'A-148', name: 'Mueble de cocina S')
Phase.create(code: 'A-149', name: 'Repisas y nichos S')
Phase.create(code: 'A-150', name: 'Parasol en Madera y Metal')
Phase.create(code: 'A-151', name: 'Muebles no cotizados S')
Phase.create(code: 'E-01', name: 'Electricidad')
Phase.create(code: 'E-02', name: 'Electricidad M')
Phase.create(code: 'E-03', name: 'Electricidad O')
Phase.create(code: 'E-04', name: 'Electricidad S')
Phase.create(code: 'E-05', name: 'Alta Tensión M')
Phase.create(code: 'E-06', name: 'Alta Tensión O')
Phase.create(code: 'E-07', name: 'Alta Tensión S')
Phase.create(code: 'E-08', name: 'Baja Tensión M')
Phase.create(code: 'E-09', name: 'Baja Tensión O')
Phase.create(code: 'E-10', name: 'Baja Tensión S')
Phase.create(code: 'E-11', name: 'Ramales Eléctricos M')
Phase.create(code: 'E-12', name: 'Ramales Eléctricos O')
Phase.create(code: 'E-13', name: 'Ramales Eléctricos S')
Phase.create(code: 'E-14', name: 'Luminarias M')
Phase.create(code: 'E-15', name: 'Luminarias O')
Phase.create(code: 'E-16', name: 'Luminarias S')
Phase.create(code: 'E-17', name: 'Sistema de Intercomunicación M')
Phase.create(code: 'E-18', name: 'Sistema de Intercomunicación O')
Phase.create(code: 'E-19', name: 'Sistema de Intercomunicación S')
Phase.create(code: 'E-20', name: 'Sistema de datos y TV M')
Phase.create(code: 'E-21', name: 'Sistema de datos y TV O')
Phase.create(code: 'E-22', name: 'Sistema de datos y TV S')
Phase.create(code: 'E-23', name: 'Sistema de Alarma contra Incendio M')
Phase.create(code: 'E-24', name: 'Sistema de Alarma contra Incendio O')
Phase.create(code: 'E-25', name: 'Sistema de Alarma contra Incendio S')
Phase.create(code: 'E-26', name: 'Sistema de Seguridad y Detección M')
Phase.create(code: 'E-27', name: 'Sistema de Seguridad y Detección O')
Phase.create(code: 'E-28', name: 'Sistema de Seguridad y Detección S')
Phase.create(code: 'E-29', name: 'Sistemas de Falla a Tierra M')
Phase.create(code: 'E-30', name: 'Sistemas de Falla a Tierra O')
Phase.create(code: 'E-31', name: 'Sistemas de Falla a Tierra S')
Phase.create(code: 'E-32', name: 'Calentador de Agua M')
Phase.create(code: 'E-33', name: 'Calentador de Agua O')
Phase.create(code: 'E-34', name: 'Calentador de Agua S')
Phase.create(code: 'E-35', name: 'Ventiladores M')
Phase.create(code: 'E-36', name: 'Ventiladores O')
Phase.create(code: 'E-37', name: 'Ventiladores S')
Phase.create(code: 'E-38', name: 'Energía Solar M')
Phase.create(code: 'E-39', name: 'Energía Solar O')
Phase.create(code: 'E-40', name: 'Energía Solar S')
Phase.create(code: 'E-41', name: 'Distribución A/C M')
Phase.create(code: 'E-42', name: 'Distribución A/C O')
Phase.create(code: 'E-43', name: 'Distribución A/C S')
Phase.create(code: 'E-44', name: 'A/C M')
Phase.create(code: 'E-45', name: 'A/C O')
Phase.create(code: 'E-46', name: 'A/C S')
Phase.create(code: 'E-47', name: 'Extracción de aire M')
Phase.create(code: 'E-48', name: 'Extracción de aire O')
Phase.create(code: 'E-49', name: 'Extracción de aire S')
Phase.create(code: 'E-50', name: 'Sistemas de Automatización M')
Phase.create(code: 'E-51', name: 'Sistemas de Automatización O')
Phase.create(code: 'E-52', name: 'Sistemas de Automatización S')
Phase.create(code: 'E-53', name: 'Otros Controles e Instrumentaciones M')
Phase.create(code: 'E-54', name: 'Otros Controles e Instrumentaciones O')
Phase.create(code: 'E-55', name: 'Otros Controles e Instrumentaciones S')
Phase.create(code: 'E-56', name: 'Luminarias Colgantes G')
Phase.create(code: 'F-01', name: 'Fontanería')
Phase.create(code: 'F-02', name: 'Fontanería M')
Phase.create(code: 'F-03', name: 'Fontanería O')
Phase.create(code: 'F-04', name: 'Fontanería S')
Phase.create(code: 'F-05', name: 'Red Agua Fría M')
Phase.create(code: 'F-06', name: 'Red Agua Fría O')
Phase.create(code: 'F-07', name: 'Red Agua Fría S')
Phase.create(code: 'F-08', name: 'Red Agua Caliente M')
Phase.create(code: 'F-09', name: 'Red Agua Caliente O')
Phase.create(code: 'F-10', name: 'Red Agua Caliente S')
Phase.create(code: 'F-11', name: 'Red Aguas Servidas M')
Phase.create(code: 'F-12', name: 'Red Aguas Servidas O')
Phase.create(code: 'F-13', name: 'Red Aguas Servidas S')
Phase.create(code: 'F-14', name: 'Red Sanitaria M')
Phase.create(code: 'F-15', name: 'Red Sanitaria O')
Phase.create(code: 'F-16', name: 'Red Sanitaria S')
Phase.create(code: 'F-17', name: 'Red Ventilación M')
Phase.create(code: 'F-18', name: 'Red Ventilación O')
Phase.create(code: 'F-19', name: 'Red Ventilación S')
Phase.create(code: 'F-20', name: 'Red Pluvial M')
Phase.create(code: 'F-21', name: 'Red Pluvial O')
Phase.create(code: 'F-22', name: 'Red Pluvial S')
Phase.create(code: 'F-23', name: 'Red de Gas M')
Phase.create(code: 'F-24', name: 'Red de Gas O')
Phase.create(code: 'F-25', name: 'Red de Gas S')
Phase.create(code: 'F-26', name: 'Drenajes de Piso M')
Phase.create(code: 'F-27', name: 'Drenajes de Piso O')
Phase.create(code: 'F-28', name: 'Drenajes de Piso S')
Phase.create(code: 'F-29', name: 'Desagües de Techo M')
Phase.create(code: 'F-30', name: 'Desagües de Techo O')
Phase.create(code: 'F-31', name: 'Desagües de Techo S')
Phase.create(code: 'F-32', name: 'Piscinas M')
Phase.create(code: 'F-33', name: 'Piscinas O')
Phase.create(code: 'F-34', name: 'Piscinas S')
Phase.create(code: 'F-35', name: 'Fuentes Decorativas M')
Phase.create(code: 'F-36', name: 'Fuentes Decorativas O')
Phase.create(code: 'F-37', name: 'Fuentes Decorativas S')
Phase.create(code: 'F-38', name: 'Cuartos de máquinas M')
Phase.create(code: 'F-39', name: 'Cuartos de máquinas O')
Phase.create(code: 'F-40', name: 'Cuartos de máquinas S')
Phase.create(code: 'F-41', name: 'Tanque Almacenamiento Potable M')
Phase.create(code: 'F-42', name: 'Tanque Almacenamiento Potable O')
Phase.create(code: 'F-43', name: 'Tanque Almacenamiento Potable S')
Phase.create(code: 'F-44', name: 'Tanque Séptico M')
Phase.create(code: 'F-45', name: 'Tanque Séptico O')
Phase.create(code: 'F-46', name: 'Tanque Séptico S')
Phase.create(code: 'F-47', name: 'Drenaje M')
Phase.create(code: 'F-48', name: 'Drenaje O')
Phase.create(code: 'F-49', name: 'Drenaje S')
Phase.create(code: 'F-50', name: 'Cabezales y Tragantes M')
Phase.create(code: 'F-51', name: 'Cabezales y Tragantes O')
Phase.create(code: 'F-52', name: 'Cabezales y Tragantes S')
Phase.create(code: 'F-53', name: 'Pozos de Retención M')
Phase.create(code: 'F-54', name: 'Pozos de Retención O')
Phase.create(code: 'F-55', name: 'Pozos de Retención S')
Phase.create(code: 'F-56', name: 'Alcantarillas y Cunetas M')
Phase.create(code: 'F-57', name: 'Alcantarillas y Cunetas O')
Phase.create(code: 'F-58', name: 'Alcantarillas y Cunetas S')
Phase.create(code: 'F-59', name: 'Sistemas de riego M')
Phase.create(code: 'F-60', name: 'Sistemas de riego O')
Phase.create(code: 'F-61', name: 'Sistemas de riego S')
Phase.create(code: 'SP-01', name: 'Consultorías')
Phase.create(code: 'SP-02', name: 'Estudios Preliminares')
Phase.create(code: 'SP-03', name: 'Anteproyecto')
Phase.create(code: 'SP-04', name: 'Planos y especificaciones técnicas')
Phase.create(code: 'SP-05', name: 'Presupuesto')
Phase.create(code: 'SP-06', name: 'Dirección Técnica')
Phase.create(code: 'SP-07', name: 'Topografía')
Phase.create(code: 'CI-01', name: 'Costos indirectos')
Phase.create(code: 'CI-02', name: 'Imprevistos')
Phase.create(code: 'CI-03', name: 'Administración')
Phase.create(code: 'CI-04', name: 'Utilidad')
Phase.create(code: 'CI-05', name: 'Instituciones')
