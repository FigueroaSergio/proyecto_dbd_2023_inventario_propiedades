CREATE OR REPLACE FUNCTION create_parking (v_edificio VARCHAR2)
RETURN VARCHAR2
IS
    v_superficie number(10,0);
    v_codigo_parking VARCHAR2(10);

BEGIN

    v_superficie :=  DBMS_RANDOM.VALUE(500,1000);
    v_codigo_parking := random_id(10);
    dbms_output.put_line('Parking: edificio->' || v_edificio ||' superficie-> ' || v_superficie||' codigo_parking->' || v_codigo_parking);
    RETURN v_edificio;
END;
/
DECLARE
 v_cargo VARCHAR2(10);
BEGIN
 v_cargo:=create_parking('100000');
END;
/
CREATE OR REPLACE FUNCTION create_plaza(v_parking VARCHAR2)
RETURN VARCHAR2
IS
    v_id VARCHAR2(10);
    exist_id NUMBER;
BEGIN
    WHILE TRUE LOOP
        v_id := random_id(10);
        SELECT COUNT(*) into exist_id FROM Plazas WHERE codigo_plz = v_id AND codigo_ed=v_parking;
        IF exist_id = 0 THEN
            EXIT;
        END IF;
    END LOOP;

    dbms_output.put_line('Plaza: parking->' || v_parking ||' plaza-> '||v_id);
    RETURN v_id;
END;
/
DECLARE
 v_cargo VARCHAR2(10);
BEGIN
 v_cargo:=create_plaza('100000');
END;
/

CREATE OR REPLACE FUNCTION create_plaza_doble(id_edificio VARCHAR2, id_plaza VARCHAR2)
RETURN NUMBER
IS
BEGIN
    dbms_output.put_line('Plaza Doble: Edificio->' || id_edificio ||' plaza-> '||id_plaza);
    RETURN 1;
END;
/

DECLARE
 v_cargo VARCHAR2(10);
BEGIN
 v_cargo:=create_plaza_doble('100000','20000');
END;
/
CREATE OR REPLACE FUNCTION create_plaza_simple(id_edificio VARCHAR2, id_plaza VARCHAR2)
RETURN NUMBER
IS
BEGIN
    dbms_output.put_line('Plaza simple: Edificio->' || id_edificio ||' plaza-> '||id_plaza);
    RETURN 1;
END;
/
CREATE OR REPLACE FUNCTION create_empleado(v_plaza VARCHAR2, v_edificio VARCHAR2)
RETURN NUMBER
IS
    v_id NUMBER;
    v_nombre VARCHAR2(100);
    v_dni VARCHAR2(10);
    v_calle VARCHAR2(50);
    v_numero_direccion NUMBER(10,0);
    v_codigo_postal NUMBER(10, 0);
    v_fecha_inicio DATE;

    exist_id NUMBER;
BEGIN
    v_id := DBMS_RANDOM.VALUE(0,10000);
    v_dni := random_id(10);
    WHILE TRUE LOOP
        SELECT COUNT(*) into exist_id FROM empleado WHERE numero = v_id AND dni = v_dni;
        IF exist_id = 0 THEN
            EXIT;
        END IF;
        v_id := DBMS_RANDOM.VALUE(0,10000);
        v_dni := random_id(10);
    END LOOP;

    v_nombre := random_nombre;
    
    v_calle :=  random_calle_numero;
    v_numero_direccion:= DBMS_RANDOM.VALUE(0,10000);
    v_codigo_postal:= DBMS_RANDOM.VALUE(0,10000);
    v_fecha_inicio := SYSDATE;
    dbms_output.put_line('Empleado: numero-> '||v_id||' dni->' || v_dni ||' nombre->' ||v_nombre|| ' calle->' ||v_calle|| ' num_direccion->' ||v_numero_direccion|| ' codigo_postal->' ||v_calle|| ' codigo_postal->' ||v_codigo_postal|| ' fecha_inicio->' ||v_fecha_inicio);
    RETURN v_id;
END;
/
DECLARE
 v_cargo NUMBER(10,0);
BEGIN
 v_cargo:=create_empleado('10','120');
END;
/

CREATE OR REPLACE FUNCTION create_cargo(v_empleado NUMBER)
RETURN VARCHAR2
IS
    v_id VARCHAR2(10);
    v_nombre VARCHAR2(50);
    v_descripcion VARCHAR2(50);

    exist_id NUMBER;
BEGIN
    v_id := random_id(10);
    WHILE TRUE LOOP
        SELECT COUNT(*) into exist_id FROM cargo WHERE codigo_c = v_id;
        IF exist_id = 0 THEN
            EXIT;
        END IF;
        v_id := random_id(10);
    END LOOP;

    v_nombre := random_nombre;
    v_descripcion :=  random_nombre;
    dbms_output.put_line('Cargo: codigo-> '||v_id||' nombre->' || v_nombre ||' descripción->' ||v_descripcion|| ' empleado->' ||v_empleado);
    RETURN v_id;
END;
/
DECLARE
 v_cargo VARCHAR2(10);
BEGIN
 v_cargo:=create_cargo(10);
END;
/
CREATE OR REPLACE PROCEDURE create_edificio
IS
    -- Variables para creacion edificio
    codigo_edificio VARCHAR2(10);
    v_calle VARCHAR2(50);
    v_number NUMBER(10,0);
    v_ciudad VARCHAR2(30);
    v_superficie NUMBER(10,0);
    v_cargo VARCHAR2(10);

    -- Variables auxiliares
    cod_parking VARCHAR(10);
    cod_plaza VARCHAR(10);
    cod_plaza_doble NUMBER(10,0);
    cod_empleado NUMBER(10,0);
    -- almacen
    v_fecha DATE;
    v_cantidad NUMBER(10,0);
    record_material material%ROWTYPE;
    exist_id NUMBER;
BEGIN
    codigo_edificio := random_id(10);
    -- verificar que el id del edificio no existe
    WHILE TRUE LOOP
        SELECT COUNT(*) into exist_id FROM edificio WHERE codigo_ed = codigo_edificio;
        IF exist_id = 0 THEN
            EXIT;
        END IF;
        codigo_edificio := random_id(10);
    END LOOP;

    v_calle := random_calle_numero;
    v_number :=  DBMS_RANDOM.VALUE(1, 1000000);
    v_ciudad := random_ciudad;
    v_superficie := DBMS_RANDOM.VALUE(500,10000);
    dbms_output.put_line('Creating Edificio');

    cod_parking:=create_parking(codigo_edificio);
    -- Creacion de los 10 empleados del edificio con sus parquaderos
    FOR i IN 1..10 LOOP
        cod_plaza:=create_plaza(cod_parking);
        cod_plaza_doble:=create_plaza_doble(cod_parking, cod_plaza);
        cod_empleado:=create_empleado(cod_parking, cod_plaza    );
        IF i = 1 THEN
            v_cargo := create_cargo(cod_empleado);
        END IF;
    END LOOP;

    -- Creacion de la 6 plazas dobles faltantes para el edificio
    FOR i IN 1..6 LOOP
        cod_plaza:=create_plaza(cod_parking);
        cod_plaza_doble:=create_plaza_doble(cod_parking, cod_plaza);
    END LOOP;

    -- Creacion de la 34 plazas simple del el edificio para completar las 40 plazas
    FOR i IN 1..34 LOOP
        cod_plaza:=create_plaza(cod_parking);
        cod_plaza_doble:=create_plaza_simple(cod_parking, cod_plaza);
    END LOOP;
    -- Creacion de los elementos en almacen
    FOR record_material IN (SELECT * FROM MATERIAL)     LOOP
        v_fecha := SYSDATE;
        v_cantidad :=  DBMS_RANDOM.VALUE(1, 1000);
        dbms_output.put_line(record_material.codigo_m);
        INSERT INTO Almacen(codigo_m,codigo_ed,fecha,cantidad) VALUES(record_material.codigo_m,codigo_edificio,v_fecha, v_cantidad);
    END LOOP;
    

    dbms_output.put_line('Edificio: codigo->'||codigo_edificio||' calle->' || v_calle ||' numero->' ||v_number|| ' ciudad->' ||v_ciudad||' superficie->'||v_superficie || ' cargo->'||v_cargo);
END;
/
BEGIN
    create_edificio;
END;
/
CREATE OR REPLACE PROCEDURE create_materiales
IS
    v_material VARCHAR2(50);
    codigo VARCHAR2(10);
    exist_id  NUMBER;
BEGIN
    FOR i IN 1..100 LOOP
        v_material := random_material;
        codigo := random_id(10);
        WHILE TRUE LOOP
            SELECT COUNT(*) into exist_id FROM material;
            IF exist_id > 0 THEN
                SELECT COUNT(*) into exist_id FROM material WHERE codigo_m = codigo;
            END IF;
            IF exist_id = 0 THEN
                EXIT;
            END IF;
            codigo := random_id(10);
        END LOOP;
        INSERT INTO MATERIAL(codigo_m,descripcion) VALUES(codigo,v_material);
        dbms_output.put_line('Material: codigo->'|| codigo|| ' material->' || v_material );
    END LOOP;
END;
/

BEGIN
    create_materiales;
END;
/

