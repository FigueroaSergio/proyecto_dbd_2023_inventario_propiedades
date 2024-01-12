/*Material*/
CREATE TABLE MATERIAL ( 

    codigo_m VARCHAR2(10) CONSTRAINT PK_MATERIAL PRIMARY KEY, 

    descripcion VARCHAR2(100) NOT NULL

); 


/*Edificio*/ 

CREATE TABLE Edificio ( 

    codigo_ed VARCHAR2(10) CONSTRAINT PK_EDIFICIO PRIMARY KEY, 

    calle VARCHAR2(50) NOT NULL, 

    numero NUMBER(10, 0) NOT NULL, 

    codigo_postal NUMBER(10, 0) NOT NULL, 

    ciudad VARCHAR2(30) NOT NULL, 

    superficie REAL CHECK (superficie >= 0) NOT NULL

); 
/*Almacen*/

CREATE TABLE Almacen ( 

    codigo_m VARCHAR2(10), 

    codigo_ed VARCHAR2(10), 

    fecha DATE NOT NULL, 

    cantidad NUMBER(10, 0) CHECK (cantidad >= 0) NOT NULL, 

    CONSTRAINT PK_ALMACEN PRIMARY KEY (codigo_ed, codigo_m), 

    CONSTRAINT FK_ALMACEN_MATERIAL FOREIGN KEY (codigo_m) REFERENCES MATERIAL(codigo_m) ON DELETE CASCADE 

DEFERRABLE INITIALLY DEFERRED, 

    CONSTRAINT FK_ALMACEN_EDIFICIO FOREIGN KEY (codigo_ed) REFERENCES EDIFICIO(codigo_ed) DEFERRABLE INITIALLY DEFERRED 

); 


/*Taller y Reparaciones: primero creamos el clúster para 25 párkings cada uno de ellos con 40 plazas. */

CREATE CLUSTER PARKING_PLAZAS 

(codigo_ed VARCHAR(10)) 

HASHKEYS 2000; 

/*Parking */

CREATE TABLE Parking( 

    superficie NUMBER(10, 0) CHECK (superficie >= 0) NOT NULL, 

    codigo_ed VARCHAR2(10) NOT NULL, 

    CONSTRAINT PK_PARKING PRIMARY KEY (codigo_ed), 

    CONSTRAINT FK_PARKING_EDFICIO FOREIGN KEY (codigo_ed) REFERENCES Edificio(codigo_ed) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED) 

CLUSTER PARKING_PLAZAS(codigo_ed); 

/* Plazas */

CREATE TABLE Plazas( 

    codigo_plz VARCHAR2(10), 

    codigo_ed VARCHAR2(10), 

    CONSTRAINT PK_PLAZAS PRIMARY KEY (codigo_plz, codigo_ed), 

    CONSTRAINT FK_PLAZAS_PARKING FOREIGN KEY (codigo_ed) REFERENCES PARKING(codigo_ed) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED) 

CLUSTER PARKING_PLAZAS(codigo_ed); 


/* Simples */ 

CREATE TABLE Simples ( 

    codigo_plz VARCHAR2(10), 

    codigo_ed VARCHAR2(10), 

    CONSTRAINT pk_Simples PRIMARY KEY (codigo_plz, codigo_ed), 
    
    CONSTRAINT fk_Simples_Plazas 
        FOREIGN KEY (codigo_plz, codigo_ed) 
        REFERENCES Plazas(codigo_plz, codigo_ed) 
        ON DELETE CASCADE 

); 


/*Dobles*/ 

CREATE TABLE Dobles ( 

    codigo_plz VARCHAR2(10), 

    codigo_ed VARCHAR2(10), 

    CONSTRAINT pk_Dobles PRIMARY KEY (codigo_plz, codigo_ed), 

    CONSTRAINT fk_Dobles_Plazas FOREIGN KEY (codigo_plz, codigo_ed) 
        REFERENCES Plazas(codigo_plz, codigo_ed)
        ON DELETE CASCADE 
); 




/*
TODO:
CREATE TRIIGGER VALID FECHA INICIO: 
 https://asktom.oracle.com/ords/asktom.search?tag=sysdate-in-check-constraints#:~:text=No%2C%20you%20can't%20use,But%20sysdate%20is%20non%2Ddeterministic.
 */
/*Empleado*/ 

CREATE TABLE Empleado ( 

    numero NUMBER(10, 0) PRIMARY KEY, 

    DNI VARCHAR2(10) UNIQUE NOT NULL, 

    nombre VARCHAR2(100) NOT NULL, 

    calle VARCHAR2(50) NOT NULL, 

    numero_direccion NUMBER(10, 0) NOT NULL, 

    codigo_postal NUMBER(10, 0) NOT NULL, 

    fecha_inicio DATE NOT NULL, 

    fecha_fin DATE, 

    codigo_plz VARCHAR2(10) UNIQUE NOT NULL, 

    codigo_ed VARCHAR2(10) NOT NULL, 

    CONSTRAINT fk_Empleado_Dobles 
        FOREIGN KEY (codigo_plz,codigo_ed) 
        REFERENCES Dobles(codigo_plz, codigo_ed)
        ON DELETE CASCADE,
        
    CONSTRAINT chk_Empleado_Fecha 
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)

); 

/*Cargo*/
CREATE TABLE Cargo ( 

    codigo_c VARCHAR2(10) CONSTRAINT PK_CODIGO_CARGO PRIMARY KEY, 

    descripción VARCHAR2(100) NOT NULL CONSTRAINT DESCRIPCION_UNICA UNIQUE, 

    nombre VARCHAR2(100)  NOT NULL CONSTRAINT NOMBRE_UNICO UNIQUE, 

    numero_em NUMBER(10, 0) NOT NULL, 

    CONSTRAINT FK_CARGO_EMPLEADO FOREIGN KEY (numero_em) REFERENCES Empleado(numero) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED 

); 

/*Ahora si se puede añadir la clave foranea que nos bloqueba en ciclo de edificio*/


ALTER TABLE Edificio
	ADD codigo_c VARCHAR2(10) NOT NULL;

ALTER TABLE Edificio
	ADD CONSTRAINT FK_EDIFICIO_CARGO 
	FOREIGN KEY (codigo_c) 
	REFERENCES Cargo(codigo_c) DEFERRABLE INITIALLY DEFERRED;

 



 

/*Dependencia*/ 

CREATE TABLE Dependencia ( 

    codigo_d VARCHAR2(10), 

    codigo_ed VARCHAR2(10), 

    codigo_c VARCHAR2(10) NOT NULL, 

    CONSTRAINT pk_Dependencia PRIMARY KEY (codigo_d, codigo_ed), 

    CONSTRAINT fk_Dependencia_Edificio FOREIGN KEY (codigo_ed) REFERENCES Edificio(codigo_ed), 

    CONSTRAINT fk_Dependencia_Cargo FOREIGN KEY (codigo_c) REFERENCES Cargo(codigo_c) 

); 

/*Restringido*/ 

CREATE TABLE Restringido ( 

    codigo_d VARCHAR2(10), 

    codigo_ed VARCHAR2(10), 

    CONSTRAINT pk_Restringido PRIMARY KEY (codigo_d, codigo_ed), 

    CONSTRAINT fk_Restringido_Dependencia FOREIGN KEY (codigo_d, codigo_ed) REFERENCES Dependencia(codigo_d,codigo_ed) ON DELETE CASCADE

); 

/*Particular*/ 

CREATE TABLE Particular ( 

    codigo_d VARCHAR2(10), 

    numero NUMBER(10, 0), 

    codigo_ed VARCHAR2(10), 

    CONSTRAINT pk_Particular PRIMARY KEY (codigo_d, codigo_ed), 

    CONSTRAINT fk_Particular_Dependencia FOREIGN KEY (codigo_d,codigo_ed) REFERENCES Dependencia(codigo_d,codigo_ed) ON DELETE CASCADE, 

    CONSTRAINT fk_Particular_Empleado FOREIGN KEY (numero) REFERENCES Empleado(numero) ON DELETE CASCADE

); 

 




/*Uso res*/
CREATE TABLE Uso_Res ( 

    numero NUMBER(10, 0), 

    codigo_d VARCHAR2(10), 

    codigo_ed VARCHAR2(10), 

    CONSTRAINT pk_Uso_Res PRIMARY KEY (numero, codigo_d, codigo_ed), 

    CONSTRAINT fk_Uso_Res_Dependencia FOREIGN KEY (codigo_d, codigo_ed) REFERENCES Restringido(codigo_d, codigo_ed) ON DELETE CASCADE, 

    CONSTRAINT fk_Uso_Res_Empleado FOREIGN KEY (numero) REFERENCES Empleado(numero) ON DELETE CASCADE

); 

 

/*Mueble*/

CREATE TABLE Mueble ( 

    codigo_mu VARCHAR2(10) PRIMARY KEY, 

    tipo VARCHAR2(10) NOT NULL, 

    estado VARCHAR2(20) NOT NULL, 

    codigo_d VARCHAR2(10), 

    codigo_ed VARCHAR2(10), 

    CONSTRAINT fk_Mueble_Dependencia FOREIGN KEY (codigo_d, codigo_ed) REFERENCES Dependencia(codigo_d, codigo_ed)

); 

/* Aparato */

CREATE TABLE Aparato ( 

    modelo VARCHAR2(50), 

    marca VARCHAR2(20), 

    fecha_compra DATE NOT NULL, 

    fecha_fin_garantia DATE NOT NULL, 

    tiempo_garantia NUMBER(10, 0), 

    codigo_mu VARCHAR2(10) PRIMARY KEY, 

    CONSTRAINT fk_Aparato_Mueble FOREIGN KEY (codigo_mu) REFERENCES Mueble(codigo_mu) ON DELETE CASCADE,
           
    CONSTRAINT chk_tiempo_garantia
        CHECK (tiempo_garantia = (fecha_fin_garantia - fecha_compra))


); 