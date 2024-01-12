CREATE OR REPLACE FUNCTION random_nombre
RETURN VARCHAR2
IS
    v_nombre varchar2(50);
    v_apellido1 varchar2(30);
    v_apellido2 varchar2(30);
    v_random number;
BEGIN
    v_random := round(dbms_random.value(0,49),0);
    /*
    En la sentencia select con la cláusula offset indicamos que salte v_random
    filas y con la cláusula fetch next indicamos que recupere sólo 1 fila (la
    siguiente)
    */
    SELECT nombre
    INTO v_nombre
    from nombres
    offset v_random rows
    FETCH NEXT 1 ROWS ONLY;
    /*
    Obtención de dos apellidos aleatorios de los 56 que hay
    */
     v_random := round(dbms_random.value(0,49),0);
    SELECT apellido
    INTO v_apellido1
    from apellidos
    offset v_random rows
    FETCH NEXT 1 ROWS ONLY;
    v_random := round(dbms_random.value(0,49),0);
    SELECT apellido
    INTO v_apellido2
    from apellidos
    offset v_random rows
    FETCH NEXT 1 ROWS ONLY;
    v_nombre := v_apellido1 ||' '||v_apellido2||', '||v_nombre;
    return(v_nombre);
END;
/
DECLARE
 v_nombre VARCHAR2(100);
BEGIN
    v_nombre := random_nombre;
    dbms_output.put_line('nombre: '||v_nombre);
END;
/



CREATE OR REPLACE FUNCTION random_calle_numero
RETURN VARCHAR2 AS
BEGIN 
 RETURN 'Calle ' || TO_CHAR(FLOOR(DBMS_RANDOM.VALUE(1,200))); 
END; 
/

DECLARE
 v_calle VARCHAR2(100);
BEGIN
    v_calle := random_calle_numero;
    dbms_output.put_line('calle: '||v_calle);
END;
/

CREATE OR REPLACE FUNCTION random_id(p_leng INTEGER) RETURN VARCHAR2 AS
BEGIN
   RETURN DBMS_RANDOM.STRING('X', p_leng);
END;
/
DECLARE
 v_calle VARCHAR2(10);
BEGIN
    v_calle := random_id(10);
    dbms_output.put_line('Id: '||v_calle);
END;
/

CREATE OR REPLACE FUNCTION random_ciudad
RETURN VARCHAR2
IS
    v_ciudad varchar2(50);
    v_random number;
BEGIN
    v_random := round(dbms_random.value(0,9),0);
    SELECT nombre
    INTO v_ciudad
    from ciudades
    offset v_random rows
    FETCH NEXT 1 ROWS ONLY;
    RETURN v_ciudad;
END;
/

DECLARE
 v_ciudad VARCHAR2(30);
BEGIN
    v_ciudad := random_ciudad;
    dbms_output.put_line('Ciudad: '|| v_ciudad);
END;