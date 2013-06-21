{
* MercadoLibre de Bugs
*
* Grupo 5
*
* Gabriela Azcona - Sofia Morseletto - Mariano Stinson - Leandro Desuque - Leandro Devesa
*
}
program MercadoLibreBugs;
USES crt,Validaciones;
CONST
  Amarillo = 14;
	Blanco = 15;
	Rojo = 4;
	Verde=2;
	MaxLengthUsuario = 8;
	MaxLengthPass = 8;
	MaxVMovimientosSaldos = 10;
	DataFolder = 'Data/';
TYPE
	tFecha = string[8];
	tPyR = record
		pgta : string;
		rta : string;
	end;
	tVPyR = array of tPyR;
	{** Usuarios **}
	tUsuario = record
		Usuario : string[8];
		Pass : string[8];
		NomYApe : string[40];
		Telefono : string[10];
		Mail : string[30];
		Calificacion : integer;
		CantVentas : word;
		CantCompras : word;
		EsAdmin : boolean;
		Fecha : tFecha; {//Fecha de que?}
	end;
	tArcUsu = file of tUsuario;
	{** Publicaciones **}
	t_Autos = Record
		id : integer;
		usuario : string[8];
		producto : string[40];
		marca : string[20];
		esNuevo : boolean;
		antiguedad : tFecha;
		precio : real;
		esDestacada : boolean;
		estaDisponible : boolean;
		fechaPublic : tFecha;
		duracionPublic : byte;
		descr : string;
		{PyR : tvPyR;}
		Combustible : string[6];
		CantPuertas : byte;
		AnoFabricacion : string[4];
	End;
	t_ArchAutos = file Of t_Autos;
	t_Notebook = Record
		id : integer;
		usuario : string[8];
		producto : string[40];
		marca : string[20];
		esNuevo : boolean;
		antiguedad : tFecha;
		precio : real;
		esDestacada : boolean;
		estaDisponible : boolean;
		fechaPublic : tFecha;
		duracionPublic : byte;
		descr : string;
		{PyR : tvPyR;}
		Ram: string[5];
		HD: string[5];
		Pantalla: string[4];
	End;
	t_ArchNote = file of t_Notebook;
	{** Ventas/Compras **}
	tVentas = record
		id : integer;
		UsuarioVendedor : string[8];
		UsuarioComprador : string[8];
		Producto : string[8];
		CalifVendedor : byte;
		CalifComprador : byte;
		FechaVenta : tFecha;
	end;
	tArcVentas = file of tVentas;
	{** Indices **}
	tIndice = record
		Pos : longint;
		CampoClave : string;
	End;
	tIndiceUsu = array[1..500] of tIndice;  {ver el tamaño fisico del vector, seria la cantidad total de usuarios}
	{** Movimientos y saldos **}
	tMovimiento = record
		plata : real;
		fecha : tFecha;
	End;
	tvMovimientos = array [1..MaxVMovimientosSaldos] of tMovimiento;
	tSaldos = record
		Usuario : string[8];
		Saldo : real;
		movimientos : tvMovimientos;{//Movimiento - despues vemos que hacemos con esto}
	End;
	tArcSaldos = file of tSaldos;
	tPublic = record
			id:integer;
			usuario:string[8];
			producto:string[8];
			marca:string[20];
			precio:real;
	End;
var
	FechaSistema : tFecha;
{Funcion MercadoLibre de Bugs | Comprobar si el usuario se encuentra registrado}
FUNCTION UsuarioExiste(var ArchivoDeUsuarios: tArcUsu; var UnUsuario: tUsuario; NuevoUsuario: String):Boolean;
VAR
	Encontrado: Boolean;
BEGIN
	Reset(ArchivoDeUsuarios);
	Encontrado:=False;
	While (Not EOF(ArchivoDeUsuarios) and Not(Encontrado)) do
	BEGIN
		Read(ArchivoDeUsuarios, UnUsuario);
		If (UnUsuario.Usuario=NuevoUsuario) then
			Encontrado:=True
		Else
			Encontrado:=False
	END;
	UsuarioExiste:=Encontrado;
END;
{Funcion MercadoLibre de Bugs | Busca el usuario}
FUNCTION PosicionUsuarioIndice(usuario:string;TotalUsu:longint;var Indice:tIndiceUsu) : longint;
VAR
	limInferior : longint;
	limSuperior : longint;
	posCentral : longint;	
	ExisteUsuario : boolean;
BEGIN
	limInferior := 1;
	ExisteUsuario := false;
	limSuperior := TotalUsu;
	while (not(ExisteUsuario)) and (limInferior<=limSuperior) do
	begin
		posCentral:=round((limInferior+limSuperior)div 2);
		if ((usuario) = Indice[posCentral].CampoClave) then
			ExisteUsuario := true
		else
			if (usuario>Indice[posCentral].CampoClave) then
				limInferior:=posCentral+1
			else
				limSuperior:=posCentral-1;
	end;
	If (ExisteUsuario) Then
		PosicionUsuarioIndice := PosCentral
	Else
		PosicionUsuarioIndice := -1;
END;
{Funcion MercadoLibre de Bugs | Compara claves}
FUNCTION EsClaveCorrecta(var Indice:tIndiceUsu;contrasena:string;auxPos : longint): boolean ;
VAR
	arch : tArcUsu;
	RegUsuario : tUsuario;
BEGIN
	Assign(arch, DataFolder + 'ArchUsuarios.dat');
	reset(arch);
	seek(arch,indice[auxpos].pos);
	read(arch,RegUsuario);
	if (contrasena = RegUsuario.pass) then
		EsClaveCorrecta := true
	else
		EsClaveCorrecta := false;
	close(arch);			
END;
{Procedimiento MercadoLibre de Bugs | Ordena indice de usuarios}
Procedure OrdenarIndiceUsu(var Indice:tIndiceUsu; TotalUsu:longint);
VAR
	Ordenado : boolean;
	i,j : longint;
	aux : tIndice;
Begin
	i := 1;
	Ordenado := false;
	While (i <= TotalUsu - 1) and (not(ordenado)) do
	Begin
		Ordenado := true;
		j:=1;
		while (j <= TotalUsu - i) do
		begin
			if (Indice[j].CampoClave > Indice[j+1].CampoClave) then
			begin				
				aux.Pos := Indice[j].Pos;
				aux.CampoClave := Indice[j].CampoClave;
				Indice[j].Pos := Indice[j+1].Pos;
				Indice[j].CampoClave := Indice[j+1].CampoClave;
				Indice[j+1].Pos := aux.Pos;
				Indice[j+1].CampoClave := aux.CampoClave;
				ordenado := false;
			end;
			Inc(j);
		end;
		Inc(i);
	end;
End;
{Procedimiento MercadoLibre de Bugs | Crea indice de usuarios}
Procedure CrearIndiceUsu(var IndiceUsu:tIndiceUsu;var TotalUsu:longint);  {Declaro el archivo como variable para que no pese tanto}
VAR
	i : longint;
	auxUsu : tUsuario;
	ArchUsu : tArcUsu;
BEGIN
	i := 1;
	Assign(ArchUsu, DataFolder + 'ArchUsuarios.dat');
	Reset(ArchUsu);
	While (Not EOF(ArchUsu)) Do
	Begin
		Read(ArchUsu,auxUsu);
		IndiceUsu[i].Pos := FilePos(ArchUsu) - 1;
		IndiceUsu[i].CampoClave := auxUsu.usuario;
		Inc(i);
	End;
	TotalUsu := i - 1;
	Close(ArchUsu);
	OrdenarIndiceUsu(IndiceUsu,TotalUsu);
END;
{Procedimiento MercadoLibre de Bugs | MENSAJE PRINCIPAL}
PROCEDURE MensajePrincipal(FechaSistema : tFecha;auxUsu : string);
VAR
	i : byte;
	auxFecha : string[10];
BEGIN
	IF (length(auxUsu) <> 0) THEN
	BEGIN
		auxUsu := 'Bienvenido, ' + auxUsu;
		FOR i := 1 TO (8 - (length(auxUsu) - 12)) DO
		BEGIN
			auxUsu :=  ' ' + auxUsu ;
		END;
	END
	ELSE
		auxUsu := '                    ';
	IF (FechaSistema = '') Then
		auxFecha := '          '
	ELSE
		auxFecha := Copy(FechaSistema,1,4) + '/' + Copy(FechaSistema,5,2) + '/' + Copy(FechaSistema,7,2);
	TextColor(Blanco);
	writeln('*******************************************************************************');	
	writeln('* ',auxFecha,'                                             ',auxUsu,' *');
	writeln('*                          MercadoLibre de Bugs                               *');	
	writeln('*                               (Grupo 5)                                     *');
	writeln('*                                                                             *');
	writeln('*******************************************************************************');
	Writeln('');
END;
{Procedimiento MercadoLibre de Bugs | INGRESO FECHA}
PROCEDURE IngresoFecha(var FechaSistema : tFecha);
CONST
	{El programa esta seteado en un rango de 1000 años... confiamos en que la tecnologia no avance.}
	MinAnio = 2000;
	MaxAnio = 3000;
VAR
	auxAno : Integer;
	auxMes, AuxDia : Byte;
	auxStr : String[4];
	EsDiaIncorrecto : Boolean;
BEGIN
	AuxAno := 0;
	auxMes := 0;
	AuxDia := 0;
	MsjTitulo('Ingreso fecha');
	While (IOResult <> 0) or (AuxAno < MinAnio) or (AuxAno > MaxAnio) Do {Cargar año}
	BEGIN
		Write('Por favor ingrese el a',#164,'o (AAAA): '); {#164 = "ñ"}
		{$I-}
		Readln(AuxAno);
		{$I+}
		If (IOResult <> 0) or (AuxAno < MinAnio) or (AuxAno > MaxAnio) Then
		BEGIN
			MsjError('El ano ingresado es incorrecto. Por favor, verifique.');
		END
		Else
		BEGIN
			Str(AuxAno,AuxStr);
		END;
	END;
	FechaSistema:=AuxStr;
	While (IOResult<>0) or (AuxMes<1) or (AuxMes>12) Do {Cargar mes}
	BEGIN
		Write('Por favor ingrese el mes (MM): ');
		{$I-}
		Readln(AuxMes);
		{$I+}
		If (IOResult<>0) or (AuxMes<1) or (AuxMes>12) then
		BEGIN
			MsjError('El mes ingresado es incorrecto. Por favor, verifique.');
		END
		Else
		BEGIN
			Str(AuxMes,AuxStr);
			If(Length(auxStr) = 1) then	AuxStr := '0' + AuxStr;
		END;
	END;
	FechaSistema := FechaSistema + auxStr;
	EsDiaIncorrecto := True;
	While (EsDiaIncorrecto) Do {Cargar dia}
	BEGIN
		Write('Por favor ingrese el dia (DD): ');
		{$I-}
		Readln(AuxDia);
		{$I+}
		If (IOResult = 0) Then
		BEGIN
			If (EsDiaValido(AuxDia,AuxMes,AuxAno)) Then
			BEGIN
				EsDiaIncorrecto := False;
				Str(AuxDia,AuxStr);
				If(Length(AuxStr) = 1) then	AuxStr := '0' + AuxStr;
			END
			Else
			BEGIN
				MsjError('El dia ingresado no existe en ese mes. Por favor, verifique.');
			END;
		END
		Else
		BEGIN
			MsjError('El dia ingresado es incorrecto. Por favor, verifique.');
		END;
	END;
	FechaSistema := FechaSistema + AuxStr;
	ClrScr;
END;
{Funcion MercadoLibre de Bugs | DEVUELVE EL SALDO DE UN USUARIO}
FUNCTION SaldoUsuario(Usuario : tUsuario;Pos : longint) : real;
VAR
	Saldo : tSaldos;
	ArchSaldos : tArcSaldos;
	auxSaldo : real;
BEGIN
	Assign(ArchSaldos, DataFolder + 'ArchSaldos.dat');
	{$I-}
	Reset(ArchSaldos);
	{$I+}
	Seek(ArchSaldos,Pos);
	Read(ArchSaldos,Saldo);
	auxSaldo := Saldo.Saldo;
	Close(ArchSaldos);
	SaldoUsuario := auxSaldo;
END;
{Procedimiento MercadoLibre de Bugs | MODIFICAR SALDO DE USUARIO}
PROCEDURE ModSaldo(Acredita : boolean; CantPlata : real;Pos : longint);
VAR
	Saldo : tSaldos;
	ArchSaldos : tArcSaldos;
	i : byte;
BEGIN
	Assign(ArchSaldos, DataFolder + 'ArchSaldos.dat');
	Reset(ArchSaldos);
	Seek(ArchSaldos,Pos);
	Read(ArchSaldos,Saldo);
	For i := 1 to (MaxVMovimientosSaldos - 1) Do
	Begin
		Saldo.Movimientos[i].plata := Saldo.Movimientos[i + 1].plata;
		Saldo.Movimientos[i].fecha := Saldo.Movimientos[i + 1].fecha;
	End;
	If (Acredita) Then
	Begin
		Saldo.Saldo := Saldo.Saldo + CantPlata;
		Saldo.Movimientos[MaxVMovimientosSaldos].plata := CantPlata;
	End
	Else
	Begin
		Saldo.Saldo := Saldo.Saldo - CantPlata;
		Saldo.Movimientos[MaxVMovimientosSaldos].plata := CantPlata * -1;
	End;
	Saldo.Movimientos[MaxVMovimientosSaldos].fecha := FechaSistema;
	Seek(ArchSaldos,Pos); //Vuelvo a la pos que lei para reescribir
	Write(ArchSaldos,Saldo);
	write('Su saldo actual es de : ');
	TextColor(Verde);
	write(Saldo.Saldo:2:2);
	TextColor(Blanco);
	write(' (ENTER PARA CONTINUAR)');
	readln();
	Close(ArchSaldos);
END;
{Procedimiento MercadoLibre de Bugs | CALIFICAR USUARIO}
PROCEDURE CalificarUsuario(NomUsu : string;Pos : longint;VAR Calif : byte);
VAR
	ArchUsu : tArcUsu;
	auxUsu : tUsuario;
BEGIN
	writeln('');
	Assign(ArchUsu,DataFolder + 'ArchUsuarios.dat');
	Reset(ArchUsu);
	Seek(ArchUsu,Pos);
	Read(ArchUsu,auxUsu);
	write('Inserte un valor (del 1 al 5) con el cual desea calificar al usuario "',NomUsu,'" : ');
	readln(Calif);
	If (auxUsu.Calificacion = 0) Then //Si es 0, nunca fue calificado antes, entonces no divide
		auxUsu.Calificacion := Calif
	Else
		auxUsu.Calificacion := ((auxUsu.Calificacion + Calif) div 2); //Si es dif de 0, divide por 2 para hacer el promedio
	writeln(auxUsu.Calificacion);
	Calif := auxUsu.Calificacion;
	readln(Calif);
	Seek(ArchUsu,Pos);
	Write(ArchUsu,auxUsu);
	Close(ArchUsu);
END;
{Procedimiento MercadoLibre de Bugs | VERIFICO SI EL USU TIENE CALIFICACIONES PENDIENTES}
PROCEDURE VerificoCalificaciones(EligioUsuario : boolean;Usuario : tUsuario;TotalUsu:longint;var Indice:tIndiceUsu);
VAR
	Ventas : tVentas;
	ArchVentas : tArcVentas;
	Pos : longint;
	Calif : byte;
	Califica : boolean;
	Califico : boolean;
BEGIN
	Califico := false;
	writeln('1');
	Assign(ArchVentas,DataFolder + 'ArchVentas.dat');
	writeln('2');
	Reset(ArchVentas);
	writeln('3');
	While not EOF(ArchVentas) Do
	BEGIN
		Read(ArchVentas,Ventas);
		Califica := false;
		If (Ventas.UsuarioComprador = Usuario.Usuario) Then //Es comprador x ende califica a vendedor
		BEGIN
			If (EligioUsuario) Then
			BEGIN
				If (Ventas.CalifVendedor = 0) Then  //Como era comprador comparo contra vendedor
					Califica := true;
			END
			ELSE
			BEGIN
				If (DiferenciaFechas(FechaSistema,Ventas.FechaVenta) >= 3) AND (Ventas.CalifVendedor = 0) Then //Como era comprador comparo contra vendedor
					Califica := true;
			END;
			If (Califica) Then
			BEGIN
				Pos := Indice[PosicionUsuarioIndice(Ventas.UsuarioVendedor,TotalUsu,Indice)].pos;
				CalificarUsuario(Ventas.UsuarioVendedor,Pos,Calif);
				Ventas.CalifVendedor := Calif; //Como era comprador califica a vendedor
				Seek(ArchVentas,filepos(ArchVentas) - 1);
				Write(ArchVentas,Ventas); //Escribo en el archivo de ventas la calificacion de la venta
				Califico := true;
			END;
		END;
	END;
	//FALTA AGREGAR QUE VERIFIQUE QUE VENDEDOR CALIFIQUE A COMPRADOR (AL REVES DE ARRIBAX)
	If (Not Califico) AND (EligioUsuario) Then
	BEGIN
		MsjError('No tiene pendiente ninguna calificacion (ENTER PARA CONTINUAR)');
		readln();
	END;
	Close(ArchVentas);
END;
{Procedimiento MercadoLibre de Bugs | Cambiar disponibilidad}
Procedure PublicacionNoDisponible(var Publicacion : tPublic);
//acordarse ;););)
Var
	auto:t_Autos;
	notebook:t_Notebook;
	
	aAutos:t_ArchAutos;
	aNotebook:t_ArchNote;
	
BEGIN
	case Publicacion.Producto Of
	'auto':
		Begin
			Assign(aAutos,DataFolder + 'ArchAuto.dat');
			Reset(aAutos);
			Seek(aAutos,(publicacion.id - 1));
			Read(aAutos,auto);
			Auto.estaDisponible := False;
			Seek(aAutos,(publicacion.id - 1));
			Write(aAutos,auto);
			Close(aAutos);
		End;
	'notebook':
		Begin
			Assign(aNotebook,DataFolder + 'ArchNote.dat');
			Reset(aNotebook);
			seek(aNotebook,(publicacion.id - 1));
			read(aNotebook,notebook);
			notebook.estaDisponible := False;
			seek(aNotebook,(publicacion.id - 1));
			write(aNotebook,notebook);
			Close(aNotebook);
		End;
	end;
END;
{Procedimiento MercadoLibre de Bugs | Enviar mails}
procedure EnviarMails(var vendedor:tUsuario; var comprador:tUsuario; var publicacion:tPublic);
var
	mail1:Text;
	mail2:Text;
BEGIN
	Assign(mail1,DataFolder + 'MailComprador.txt');
	Rewrite(mail1);
	Writeln(mail1,'De: ',vendedor.Mail);
	Writeln(mail1,'A: ',comprador.Mail);
	Writeln(mail1,'Asunto: ',publicacion.producto,' ',publicacion.id);
	Writeln(mail1,'Felicitaciones, has comprado mi ',publicacion.producto,' marca ',publicacion.marca,' por un costo de ',publicacion.precio:2:2,'.');
	Writeln(mail1,'Contactate para coordinar la entrega.');
	Writeln(mail1,vendedor.NomYApe,vendedor.Telefono);
	Close(mail1);
	Assign(mail2,DataFolder + 'MailVendedor.txt');
	Rewrite(mail2);
	Writeln(mail2,'De: ',comprador.Mail);
	Writeln(mail2,'A: ',vendedor.Mail);
	Writeln(mail2,'Asunto: ',publicacion.producto,' ',publicacion.id);
	Writeln(mail2,'Hola, compre tu ',publicacion.producto,' marca ',publicacion.marca,' por un costo de ',publicacion.precio,'.');
	Writeln(mail2,'Contactate para coordinar la entrega.');
	Writeln(mail2,comprador.NomYApe,comprador.Telefono);
	Close(mail2);
END;
{Procedimiento MercadoLibre de Bugs | Coordinar pago con vendedor}
Procedure CoordinarConVendedor(var comprador:tUsuario; var vendedor:tUsuario; var publicacion:tPublic; var compraRealizada:boolean);
Begin
	PublicacionNoDisponible(Publicacion);
	EnviarMails(Vendedor,Comprador,Publicacion);
	CompraRealizada := True;
End;
{Procedimiento MercadoLibre de Bugs | Comprar publicacion}
Procedure ComprarDesdeCuenta(Comprador : tUsuario;PosComprador : longint;PosVendedor : longint; var publicacion:tPublic; var compraRealizada:boolean; var UsuarioVendedor : tUsuario);
Var
	Saldo : real;
	op : byte;
BEGIN
	Saldo := SaldoUsuario(Comprador,PosComprador);
	If (Saldo <= Publicacion.Precio) then
	Begin
		MsjTitulo('Desea: ');
		writeln('1.Coordinar compra con vendedor');
		writeln('2.Volver al menu');
		write('Ingrese la opcion deseada : ');
		validarByteIngresado(op,1,2);
		if (Op=1) then
			CoordinarConVendedor(Comprador,UsuarioVendedor,Publicacion,compraRealizada);
	End
	Else
	Begin
		ModSaldo(false,Publicacion.Precio,PosComprador);			//Debito comprador
		ModSaldo(true,Publicacion.Precio,PosVendedor);				//Acredito vendedor
		PublicacionNoDisponible(Publicacion);
		EnviarMails(UsuarioVendedor,Comprador,Publicacion);
		CompraRealizada := True;
	End;
END;
Procedure CargarVenta(var Publicacion:tPublic;var Comprador:tUsuario);
VAR
	Venta : tVentas;
	aVentas : tArcVentas;
BEGIN
	Assign(aVentas,DataFolder + 'ArchVentas.dat');
	{$I-}
	Reset(aVentas);
	if IOResult<>0 then
		rewrite(aVentas);
	{$I+}
	Venta.id := Publicacion.id;
	Venta.producto := Publicacion.producto;	//habrìa que agregarlo
	Venta.UsuarioVendedor := Publicacion.usuario;
	Venta.UsuarioComprador := Comprador.usuario;
	Venta.FechaVenta := FechaSistema;
	Venta.CalifVendedor := 10;	//para poner algo "inválido", después se sobreescribe
	Venta.CalifComprador := 10;
	Seek(aVentas,Filesize(aVentas));
	Write(aVentas,Venta);
	Close(aVentas);
END;
{Procedimiento MercadoLibre de Bugs | Comprar publicacion}
Procedure ComprarPublic(var Indice : tIndiceUsu;var Publicacion : tPublic;var Comprador : tUsuario;TotalUsu : longint);
VAR
	Op : byte;
	CompraRealizada : boolean;
	PosVendedor : longint;
	PosComprador : longint;
	ArchUsu : tArcUsu;
	UsuarioVendedor : tUsuario;
Begin
	clrscr();
	MensajePrincipal(FechaSistema,Comprador.Usuario);
	PosVendedor := Indice[PosicionUsuarioIndice(Publicacion.Usuario,TotalUsu,Indice)].pos;
	PosComprador := Indice[PosicionUsuarioIndice(Comprador.Usuario,TotalUsu,Indice)].pos;
	
	//Proced aparte
	Assign(ArchUsu,DataFolder + 'ArchUsuarios.dat');
	Reset(ArchUsu);
	Seek(ArchUsu,PosVendedor);
	Read(ArchUsu,UsuarioVendedor);
	close(ArchUsu);
	//Proced aparte
	
	CompraRealizada := False;
	MsjTitulo('Comprar publicacion :');
	writeln('Como desea realizar la compra?');
	writeln('1.Desde el saldo');
	writeln('2.Arreglar con vendedor');
	writeln('');
	write('Seleccione la opcion deseada : ');
	validarByteIngresado(op,1,2);
	case op of
		1:	ComprarDesdeCuenta(Comprador,PosComprador,PosVendedor,Publicacion,CompraRealizada,UsuarioVendedor);
		2:	CoordinarConVendedor(Comprador,UsuarioVendedor,Publicacion,compraRealizada);
	end;

	If CompraRealizada then
		CargarVenta(Publicacion,Comprador);
End;
{Procedimiento MercadoLibre de Bugs | CONFIGURACION CUENTA}
PROCEDURE ConfigCta(Usuario : tUsuario;Indice : tIndiceUsu;TotalUsu : longint);
VAR
	auxStr : string;
	OpcMenu : byte;
	CantPlata : real;
	auxSaldoUsu : real;
	EsValido : boolean;
	Pos : longint;
CONST
	MaxOpcion = 5;
BEGIN
	Pos := Indice[PosicionUsuarioIndice(Usuario.Usuario,TotalUsu,Indice)].pos;
	clrscr();
	MensajePrincipal(FechaSistema,Usuario.usuario);
	MsjTitulo('Configuracion de la cuenta');
	Writeln();
	Writeln('1) Acreditar saldo');
	Writeln('2) Retirar saldo');
	Writeln('3) Consultar saldo');
	Writeln('4) Calificar usuario/s pendientes de compras/ventas');
	Writeln('5) Estado de ventas');
	Writeln('0) Atras');
	Writeln();
	SeleccionOpcion(OpcMenu,MaxOpcion);
	Case OpcMenu of
	1: 	BEGIN
			CantPlata := 0;
			While (CantPlata <= 0) DO
			BEGIN
				write('Ingrese la cantidad a acreditar : ');
				{$I-}
				readln(CantPlata);
				{$I+}
				If (IOResult <> 0) Then
					MsjError('Inserte un numero por favor,');
				If (CantPlata <= 0) Then
					MsjError('Debe ingresar un valor mayor a 0.');
			END;
			ModSaldo(true,CantPlata,Pos);
			ConfigCta(Usuario,Indice,TotalUsu);
		END;
	2:	BEGIN
			EsValido := false;
			While not EsValido Do
				BEGIN
				CantPlata := 0;
				auxSaldoUsu := SaldoUsuario(Usuario,Pos);
				Str(auxSaldoUsu:2:2,auxStr);
				write('Su saldo actual es de : ');
				TextColor(Verde);
				writeln(auxSaldoUsu:2:2);
				TextColor(Blanco);
				While (CantPlata <= 0) DO
				BEGIN
					write('Ingrese la cantidad a retirar : ');
					{$I-}
					readln(CantPlata);
					{$I+}
					If (IOResult <> 0) Then
						MsjError('Inserte un numero por favor,');
					If (CantPlata <= 0) Then
						MsjError('Debe ingresar un valor mayor a 0.');
				END;
				If (auxSaldoUsu >= CantPlata) Then
				BEGIN
					ModSaldo(false,CantPlata,Pos);
					EsValido := true;
				END
				Else
				BEGIN
					MsjError('La cantidad ingresada es invalida. Por favor ingrese un valor menor a : ' + auxStr);
					Esvalido := false;
				END;
			END;
			ConfigCta(Usuario,Indice,TotalUsu);
		END;
	3:	BEGIN
			write('Su saldo actual es de : ');
			TextColor(Verde);
			write(SaldoUsuario(Usuario,Pos):2:2);
			TextColor(Blanco);
			write(' (ENTER PARA CONTINUAR)');
			readln();
			ConfigCta(Usuario,Indice,TotalUsu);
		END;
	4:	BEGIN
			VerificoCalificaciones(true,Usuario,TotalUsu,Indice);
			ConfigCta(Usuario,Indice,TotalUsu);
		END;
	5:	BEGIN
			{VerEstad();}
		END;
	0:
		BEGIN
			{;}
		END;
	END;
END;
{Procedimiento CargarAuto}
procedure cargarAuto(producto:byte; cantSemanas:byte; esDestacada:boolean; var usuario:tUsuario; var archAuto:t_ArchAutos);
CONST
	MaxMarcasAutos = 9;//contando el 'otra'
VAR auto:t_Autos;
	op:byte;
	auxStr : string;
	auxReal : real;
	EsValido : boolean;
BEGIN
	Assign(archAuto,DataFolder + 'ArchAuto.dat');
	{$I-}
	reset(archAuto);
	{$I+}
	If (IOResult <> 0) then Rewrite(archAuto);
	MsjTitulo('Marca :');
	writeln('1.Audi');
	writeln('2.Citroen');
	writeln('3.Fiat');
	writeln('4.Ford');
	writeln('5.Mercedes Benz');
	writeln('6.Peugeot');
	writeln('7.Renault');
	writeln('8.Volkswagen');
	writeln('9.Otra');
	write('Inserte la opcion elegida : ');
	validarByteIngresado(op,1,MaxMarcasAutos);
	Case op Of
		1 :	auto.marca := 'Audi';
		2 :	auto.marca := 'Citroen';
		3 :	auto.marca := 'Fiat';
		4 :	auto.marca := 'Ford';
		5 :	auto.marca := 'Mercedes Benz';
		6 :	auto.marca := 'Peugeot';
		7 :	auto.marca := 'Renault';
		8 :	auto.marca := 'Volkswagen';
		9 :	auto.marca := 'Otra';
	End;
	EsValido := false;
	While (Not EsValido) Do
	Begin
		write('Ingrese el modelo del auto (AAAA) : ');
		readln(auxStr);
		If (ValidoLength(auxStr,4)) Then
		BEGIN
			auto.AnoFabricacion := auxStr;
			EsValido := true;
		END
		ELSE
			MsjError('Formato invalido');
	End;
	MsjTitulo('Es nuevo?');
	write('1.Si      2.No :');
	validarByteIngresado(Op,1,2);
	if (Op = 1) then
		auto.esNuevo := True
	else
		auto.esNuevo := False;
	EsValido := false;
	While (Not EsValido) Do
	Begin
		MsjTitulo('Precio? ');
		{$I-}
		readln(auxReal);
		{$I+}
		If (IOResult = 0) and (auxReal > 0) Then
		BEGIN
			EsValido := true;
			auto.precio := auxReal;
		END
		ELSE
			MsjError('Valor ingresado invalido, por favor reintente');
	End;
	MsjTitulo('Cantidad de puertas?: 3, 4 o 5');
	validarByteIngresado(Op,3,5);
	auto.CantPuertas := op;
	MsjTitulo('Tipo de combustible?:');
	writeln('1.Diesel');
	writeln('2.GNC');
	writeln('3.Nafta');
	validarByteIngresado(Op,1,3);
	Case op Of
		1 :	auto.combustible := 'Diesel';
		2 :	auto.combustible := 'GNC';
		3 :	auto.combustible := 'Nafta';
	End;
	auto.id := filesize(archAuto) + 1;
	auto.usuario := usuario.usuario;
	auto.esDestacada := esDestacada;
	auto.duracionPublic := cantSemanas;
	auto.antiguedad := FechaSistema;
	auto.estaDisponible := True;
	
	seek(archAuto,filesize(archAuto));
	write(archAuto,auto);	
	close(archAuto);
END;
{Procedimiento CargarNotebook}
procedure cargarNotebook(producto:byte; cantSemanas:byte; esDestacada:boolean; var usuario:tUsuario; var archNote:t_ArchNote);
var notebook:t_Notebook;
	op:byte;
	auxReal : real;
	EsValido : boolean;
BEGIN
	Assign(archNote,DataFolder + 'ArchNote.dat');
	{$I-}
	reset(archNote);
	{$I+}
	If (IOResult <> 0) then Rewrite(archNote);	
	notebook.id:=filesize(archNote)+1;
	notebook.usuario:=usuario.usuario;
	notebook.esDestacada:=esDestacada;
	notebook.duracionPublic:=cantSemanas;
	notebook.antiguedad:=FechaSistema;
	notebook.estaDisponible:=True;
	writeln('');
	MsjTitulo('Marca :');
	writeln('1.Dell');
	writeln('2.HP Compaq');
	writeln('3.Lenovo');
	writeln('4.Samsung');
	writeln('5.Sony Vaio');
	writeln('6.Toshiba');
	writeln('7.Otra');
	write('Inserte la opcion elegida : ');
	validarByteIngresado(Op,1,7);
	Case Op Of
		1:	notebook.marca	:=	'Dell';
		2:	notebook.marca	:=	'HP Compaq';
		3:	notebook.marca	:=	'Lenovo';
		4:	notebook.marca	:=	'Samsung';
		5:	notebook.marca	:=	'Sony Vaio';
		6:	notebook.marca	:=	'Toshiba';
		7:	notebook.marca	:=	'Otra';
	End;
	Op := 0;
	MsjTitulo('Es nuevo?');
	write('1.Si    2.No');
	validarByteIngresado(Op,1,2);
	if (op=1) then
		notebook.esNuevo := True
	else
		notebook.esNuevo := False;
	EsValido := false;
	While (Not EsValido) Do
	Begin
		MsjTitulo('Precio?');
		{$I-}
		readln(auxReal);
		{$I+}
		If (IOResult = 0) and (auxReal > 0) Then
		BEGIN
			EsValido := true;
			notebook.precio := auxReal;
		END
		ELSE
			MsjError('Valor ingresado invalido, por favor reintente');
	End;
	MsjTitulo('Cantidad de RAM?');
	writeln('1.1GB');
	writeln('2.2GB');
	writeln('3.4GB');
	writeln('4.8GB');
	writeln('5.Otro');
	write('Inserte la opcion elegida : ');
	validarByteIngresado(Op,1,5);
	Case Op Of
		1: notebook.Ram := '1GB';
		2: notebook.Ram := '2GB';
		3: notebook.Ram := '4GB';
		4: notebook.Ram := '8GB';
		5: notebook.Ram := 'Otro';
	End;
	MsjTitulo('Cantidad de HD?');
	writeln('1.120GB');
	writeln('2.320GB');
	writeln('3.500GB');
	writeln('4.1TB');
	writeln('5.2TB');
	writeln('6.Otra');
	write('Inserte la opcion elegida : ');
	validarByteIngresado(Op,1,6);
	Case Op Of
		1: notebook.HD:='120GB';
		2: notebook.HD:='320GB';
		3: notebook.HD:='500GB';
		4: notebook.HD:='1TB';
		5: notebook.HD:='2TB';
		6: notebook.HD:='Otra';
	End;
	MsjTitulo('Tamano de pantalla?');
	writeln('1.13"');
	writeln('2.14"');
	writeln('3.15"');
	writeln('4.16"');
	writeln('5.Otro');
	write('Inserte la opcion elegida : ');
	validarByteIngresado(Op,1,5);
	Case Op Of
		1: notebook.Pantalla:= '13"';
		2: notebook.Pantalla:= '14"';
		3: notebook.Pantalla:= '15"';
		4: notebook.Pantalla:= '16"';
		5: notebook.Pantalla:= 'Otro';
	End;
	Seek(archNote,filesize(archNote));
	Write(archNote,notebook);
	Close(archNote);
END;
{Procedimiento InicioPublicacion}
Procedure InicioPublicacion(producto:byte; var costo:real; var cantSemanas:byte; var esDestacada:boolean; var saldo:real);
CONST
	AutoPorSemana = 25;
	NotePorSemana = 10;
	MaxCantSemanasPublic = 10; //HASTA 10 SEMANAS, PUEDE SER MÁS
	Descuento = 0.1;
	Destacada = 1.2;
VAR
	i:byte;
	semana:real;
BEGIN
	case producto of
		1: Semana := AutoPorSemana;
		2: Semana := NotePorSemana;
		end;
	Costo := Semana;
	if (Costo <= Saldo) then
		begin
			CantSemanas := 0;
			Write('Cuantas semanas quiere mantener la publicacion (maximo ',MaxCantSemanasPublic,') ?: ');//AVISAR MAXCANTSEMANAS?
			ValidarByteIngresado(CantSemanas,1,MaxCantSemanasPublic);
			if (cantSemanas > 1) then
			begin
				for i:=1 to CantSemanas - 1 do
					begin
						Semana := Semana * (1 - Descuento);
						Costo := Costo + Semana;
					end;
			end;
			
			if (Costo <= Saldo) and (Saldo >= (Costo * Destacada)) then
			begin
				i:=0;
				writeln('Publicacion destacada?');
				writeln('1.Si');
				writeln('2.No');
				write('Inserte la opcion elegida : ');
				validarByteIngresado(i,1,2);
				if (i=1) then
					begin
						esDestacada:=True;
						costo:=costo*Destacada;
					end
				else
					esDestacada:=False;
			end;	
		end
	else
	BEGIN
		MsjError('No dispone del saldo suficiente para realizar la compra (ENTER PARA CONTINUAR)');
		readln();
		CantSemanas := 0;
	END;
END;
{Procedimiento NuevaPublicacion}
Procedure NuevaPublic(Usuario : tUsuario;Indice : tIndiceUsu;TotalUsu : longint);
CONST
	MaxOpcion = 2;
VAR
	OpcMenu : byte;
	CantSemanas : byte;
	Costo : real;
	Saldo : real;
	Pos : longint;
	EsDestacada : boolean;
	
	archAutos : t_ArchAutos;
	archNote : t_ArchNote;
BEGIN
	clrscr();
	MensajePrincipal(FechaSistema,Usuario.Usuario);
	MsjTitulo('Nueva publicacion');
	writeln('Desea publicar: ');
	writeln('');
	writeln('1)Auto');
	writeln('2)Notebook');
	writeln('0)Atras');
	writeln('');
	SeleccionOpcion(OpcMenu,MaxOpcion);
	Pos := Indice[PosicionUsuarioIndice(Usuario.Usuario,TotalUsu,Indice)].pos;
	Saldo := SaldoUsuario(Usuario,Pos); //Obtengo el saldo disponible del usu a traves de la pos(indice)
	InicioPublicacion(OpcMenu,Costo,CantSemanas,EsDestacada,Saldo);
	If (CantSemanas <> 0) Then //Si el usu no tiene saldo suficiente pone a cantsemanas como 0 y de aca lo mando a menuppal
	Begin
		If (Costo <= Saldo) Then
		Begin
			case OpcMenu of
				1: cargarAuto(OpcMenu,cantSemanas,esDestacada,Usuario,archAutos);
				2: cargarNotebook(OpcMenu,cantSemanas,esDestacada,Usuario,archNote);
			end;
			ModSaldo(false,Costo,Pos);
		End;
	End;
END;
{Procedimiento MercadoLibre de Bugs | FILTRO NOTEBOOK: mostrar}
Procedure Mostrarnotefiltrados(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	j,k : integer;
	rnote : t_notebook;
	aux : byte;
	publicacion : tpublic;
	rnote2 : t_notebook;
	Archnote_copia1 : t_archnote;
BEGIN
	aux := 0;
	assign(Archnote_copia1,DataFolder+'Archnote_copia2.dat');
	reset(Archnote_copia1);
	clrscr;
	MensajePrincipal(FechaSistema,comprador.usuario);
	MsjTitulo('Publicaciones filtradas:');
	if (filesize(Archnote_copia1)=0) then
	begin
		writeln('No hay publicaciones con las caracteristicas pedidas');
		readln();
	end	
	else
	begin
		k:=0;			
		while ((not(eof(archnote_copia1))) and (aux<>1) and (aux<>2) and (aux<>3))do
		begin
			seek(Archnote_copia1,k);
			clrscr;
			MsjTitulo('Publicaciones filtradas:');
			writeln('Presione las teclas 4(anterior) y 5(siguiente) respectivamente para navegar entre las paginas');
			writeln('y seleccione la opcion deseada para comprar:');
			for j:=1 to 3 do
			begin
				if (not(eof(archnote_copia1))) then
				begin
					read(archnote_copia1,rnote);		
					writeln('Opcion ',j,' :');
					writeln();
					writeln('marca:', rnote.marca);
					writeln('descripcion:',rnote.descr);
					writeln('hd:',rnote.hd);
					writeln('precio:',rnote.precio:2:2);
					writeln('publicador:',rnote.usuario);
					writeln('producto:',rnote.producto);
					writeln('ram:',rnote.ram);
					writeln('pantalla:',rnote.pantalla);
					writeln();
				end;
			end;	
			writeln('Ingrese opción deseada: ');
			ValidarByteIngresado(aux,1,5);	
			case aux of
				4 : begin
					if k>0 then
						k:=k-3;
				end;
				5: begin
					if (not(eof(archnote_copia1))) then
						k:=k+3;
				end;
			end;
		end;
		case aux of
			1 : begin
					seek(archnote_copia1,k);
					read(archnote_copia1,rnote2);
					publicacion.usuario := rnote2.usuario;
					publicacion.id := rnote2.id;
					publicacion.marca := rnote2.marca;
					publicacion.producto := rnote2.producto;
					publicacion.precio := rnote2.precio;
					close(archnote_copia1);
					ComprarPublic(indice,publicacion,comprador,totalusu);
			end;					
			2 :	begin
					seek(archnote_copia1,k+1);
					read(archnote_copia1,rnote2);
					publicacion.usuario:=rnote2.usuario;
					publicacion.id := rnote2.id;
					publicacion.marca := rnote2.marca;
					publicacion.producto := rnote2.producto;
					publicacion.precio := rnote2.precio;
					close(archnote_copia1);
					ComprarPublic(indice,publicacion,comprador,totalusu);
			end;
			3 :	begin
					seek(archnote_copia1,k+2);
					read(archnote_copia1,rnote2);
					publicacion.usuario:=rnote2.usuario;
					publicacion.id := rnote2.id;
					publicacion.marca := rnote2.marca;
					publicacion.producto := rnote2.producto;
					publicacion.precio := rnote2.precio;
					close(archnote_copia1);		
					ComprarPublic(indice,publicacion,comprador,totalusu);
			end;
		end;
	end;	
	close(archnote_copia1);
END;
{Procedimiento MercadoLibre de Bugs | FILTRO NOTEBOOK: nuevo}
procedure MenuNote_nuevo(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	rnote : t_notebook;
	aux : byte;
	archnote_copia1,archnote_copia2:t_archnote;
BEGIN
	aux := 0;
	assign(Archnote_copia1,DataFolder+'Archnote_copia1.dat');	
	assign(archnote_copia2,DataFolder+'Archnote_copia2.dat');
	reset(ArchNote_copia1);
	rewrite(ArchNote_copia2);
	writeln('Busca un producto nuevo o usado?:');
	writeln('1)nuevo');
	writeln('2)usado');
	ValidarByteIngresado(aux,1,2);
	case aux of
		1 : begin
			while (not(eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.esnuevo = true) then
					write(Archnote_copia2, rnote);
			end;
		end;
		2 : begin
			while (not(eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.esnuevo = false) then
					write(Archnote_copia2, rnote);
			end;
		end;
	end;
	close(archnote_copia1);
	close(archnote_copia2);
	Mostrarnotefiltrados(indice, totalusu, comprador);
end;
{Procedimiento MercadoLibre de Bugs | FILTRO NOTEBOOK: Pantalla}
Procedure MenuNote_Pantalla(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	rnote : t_notebook;
	aux : byte;
	archnote_copia1,archnote_copia2:t_archnote;
BEGIN
	aux := 0;
	assign(Archnote_copia1,DataFolder+'Archnote_copia1.dat');	
	assign(archnote_copia2,DataFolder+'Archnote_copia2.dat');
	rewrite(ArchNote_copia1);
	reset(ArchNote_copia2);
	writeln('Tamano de pantalla?');
	writeln('1.13"');
	writeln('2.14"');
	writeln('3.15"');
	writeln('4.16"');
	writeln('5.Otro');
	ValidarByteIngresado(aux,1,5);
	case aux of
		1 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.pantalla = '13') then
					write(Archnote_copia1, rnote);
			end;
			end;
		2 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.pantalla = '14') then
					write(Archnote_copia1, rnote);
			end;
			end;
		3 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.pantalla = '15') then
					write(Archnote_copia1, rnote);
			end;
			end;
		4 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.pantalla = '16') then
					write(Archnote_copia1, rnote);
			end;
			end;
		5 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.pantalla = 'Otro') then
					write(Archnote_copia1, rnote);
			end;
			end;
	end;
	close(archnote_copia1);
	close(archnote_copia2);
	Menunote_nuevo(indice, totalusu ,comprador);
end;
{Procedimiento MercadoLibre de Bugs | FILTRO NOTEBOOK: HD}
Procedure MenuNote_HD(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	archnote_copia1,archnote_copia2:t_archnote;
	aux : byte;
	rnote : t_notebook;
BEGIN
	aux := 0;
	assign(Archnote_copia1,DataFolder+'Archnote_copia1.dat');	
	assign(archnote_copia2,DataFolder+'archnote_copia2.dat');
	reset(ArchNote_copia1);
	rewrite(ArchNote_copia2);
	writeln('Tamaño del HD?');
	writeln('1)120GB');
	writeln('2)320GB');
	writeln('3)500GB');
	writeln('4)1TB');
	writeln('5)2TB');
	writeln('6)Otra');
	validarByteIngresado(aux,1,6);
	case aux of
		1 :	begin
			while not eof(Archnote_copia1) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.hd = '120GB') then
					write(Archnote_copia2, rnote);
			end;
			end;
		2 : begin
			while not eof(Archnote_copia1) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.hd = '320GB') then
					write(Archnote_copia2, rnote);
			end;
			end;
		3 : begin
			while not eof(Archnote_copia1) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.hd = '500GB') then
					write(Archnote_copia2, rnote);
			end;
			end;
		4 : begin
			while not eof(Archnote_copia1) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.hd = '1TB') then
					write(Archnote_copia2, rnote);
			end;
			end;
		5 : begin
			while not eof(Archnote_copia1) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.hd = '2TB') then
					write(Archnote_copia2, rnote);
			end;
			end;
		6 : begin
			while (not(eof(Archnote_copia1)))do
			begin
				read(Archnote_copia1,rnote);
				if (rnote.HD = 'Otra') then
					write(Archnote_copia2,rnote);
			end;
			end;
	end;
	close(Archnote_copia1);
	close(Archnote_copia2);
	Menunote_Pantalla(indice, totalusu ,comprador);
END;
{Procedimiento MercadoLibre de Bugs | FILTRO NOTEBOOK: RAM}
Procedure MenuNote_Ram(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	archnote_copia1,archnote_copia2:t_archnote;
	aux : byte;
	rnote : t_notebook;
BEGIN
	aux := 0; //ram := 0; gb:='gb';
	assign(Archnote_copia1,DataFolder+'Archnote_copia1.dat');	
	assign(archnote_copia2,DataFolder+'Archnote_copia2.dat');
	rewrite(archnote_copia1);
	reset(archnote_copia2);
	writeln('Cantidad de RAM?');
	writeln('1)1Gb');
	writeln('2)2Gb');
	writeln('3)4Gb');
	writeln('4)8Gb');
	writeln('5)Otro');
	validarByteIngresado(aux,1,6);
	case aux of
		1 :	begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.ram = '1GB') then
					write(Archnote_copia1, rnote);
			end;
			end;
		2 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.ram = '2GB') then
					write(Archnote_copia1, rnote);
			end;
			end;
		3 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.ram = '4GB') then
					write(Archnote_copia1, rnote);
			end;
			end;
		4 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.ram = '8GB') then
					write(Archnote_copia1, rnote);
			end;
			end;
		5 : begin
			while not eof(Archnote_copia2) do
			begin
				read(Archnote_copia2, rnote);
				if (rnote.ram = 'Otro') then
					write(Archnote_copia1, rnote);
			end;	
			end;
	end;
	close(archnote_copia1);
	close(archnote_copia2);
	MenuNote_HD(indice, totalusu ,comprador);
END;
{Procedimiento MercadoLibre de Bugs | FILTRO NOTEBOOK: crear archivo}
procedure Crear_archivo_note();
VAR
	rnote : t_notebook;
	archnote,archnote_copia1{,archnote_copia2}:t_Archnote;
BEGIN
	assign(Archnote,DataFolder+'ArchNote.dat');
	reset(Archnote);
	assign(Archnote_copia1,DataFolder+'Archnote_copia1.dat');
	rewrite(Archnote_copia1);
	{assign(Archnote_copia2,DataFolder+'Archnote_copia2.dat');
	rewrite(archnote_copia2);}
	while not eof(archnote) do
	begin
		read(Archnote, rnote);
		if (not rnote.estadisponible = false) then			
			write(Archnote_copia1, rnote);
	end;	
	{reset(Archnote_copia1);
	while not eof(archnote_copia1) do
	begin
		read(archnote_copia1,rnote);
		write(archnote_copia2,rnote);
	end;}	
	close(Archnote);
	close(Archnote_copia1);
	//close(Archnote_copia2);
END;

{Procedimiento MercadoLibre de Bugs | FILTRO NOTEBOOK: marcas}
Procedure MenuNote_Marca(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	{archnote,}Archnote_copia1,Archnote_copia2 : t_ArchNote;
	aux : byte;
	rnote : t_notebook;
BEGIN
	aux := 0;
	crear_archivo_note;
	assign(Archnote_copia1,DataFolder+'Archnote_copia1.dat');	
	assign(archnote_copia2,DataFolder+'Archnote_copia2.dat');
	reset(Archnote_copia1);
	rewrite(Archnote_copia2);
	writeln('Marca:');
	writeln('1.Dell');
	writeln('2.HP Compaq');
	writeln('3.Lenovo');
	writeln('4.Samsung');
	writeln('5.Sony Vaio');
	writeln('6.Toshiba');
	writeln('7.Otra');
	validarByteIngresado(aux,1,9);
	case aux of
		1:	begin
			while (not(eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.marca = 'Dell') then
					write(Archnote_copia2, rnote);
			end;
			end;
		2: begin
			while (not(eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.marca = 'HP Compaq') then
					write(Archnote_copia2, rnote);
			end;
			end;
		3: begin
			while (not (eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.marca = 'Lenovo') then
					write(Archnote_copia2, rnote);
			end;
			end;
		4: begin
			while (not(eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.marca = 'Samsung') then
					write(Archnote_copia2, rnote);
			end;
			end;
		5:begin
			while (not(eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.marca = 'Sony Vaio') then
					write(Archnote_copia2, rnote);
			end;
			end;
		6: begin
			while (not(eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1, rnote);
				if (rnote.marca = 'Toshiba') then
					write(Archnote_copia2, rnote);
			end;
			end;
		7 : begin
			while (not(eof(Archnote_copia1))) do
			begin
				read(Archnote_copia1,rnote);
				write(Archnote_copia2,rnote);
			end;
			end;
	end;
	close(Archnote_copia1);
	close(Archnote_copia2);
	MenuNote_Ram(indice, totalusu ,comprador);
END;

{Procedimiento MercadoLibre de Bugs | FILTRO AUTOS: mostrar}
Procedure MostrarAutosfiltrados(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	j,k : integer;
	rauto : t_autos;
	aux : byte;
	publicacion : tpublic;
	rauto2 : t_autos;
	ArchAuto_copia1 : t_ArchAutos;
BEGIN
	aux := 0;
	assign(ArchAuto_copia1,DataFolder+'ArchAuto_copia1.dat');
	reset(ArchAuto_copia1);
	clrscr;
	MensajePrincipal(FechaSistema,comprador.usuario);
	MsjTitulo('Publicaciones filtradas:');
	if (filesize(ArchAuto_copia1)=0) then
	begin
		writeln('No hay publicaciones con las caracteristicas pedidas');
		readln();
	end	
	else
	begin
	
	k := 0;			
	while (not eof(archauto_copia1) and (aux<>1) and (aux<>2) and (aux<>3))do
	begin
		seek(ArchAuto_copia1,k);
		writeln('Presione las teclas 4(anterior) y 5(siguiente) respectivamente para navegar entre las paginas');
		writeln('y seleccione la opcion deseada para comprar:');
		for j:=1 to 3 do
		begin	
			if not(eof(archauto_copia1)) then
			begin
				read(archauto_copia1,rauto);
				writeln('Opcion',j,' :');
				writeln();
				writeln('marca: ', rauto.marca);
				writeln('descripcion: ',rauto.descr);
				writeln('anio de fabricacion: ',rauto.anofabricacion);
				writeln('precio: ',rauto.precio:2:2);
				writeln('publicador: ',rauto.usuario);
				writeln('producto: ',rauto.producto);
				writeln('combustible: ',rauto.combustible);
				writeln('cantidad de puertas: ',rauto.cantpuertas);
				writeln();
			end;
		end;	
		writeln('Ingrese opción deseada: ');
		ValidarByteIngresado(aux,1,5);	
		case aux of
			4: begin
				if k>0 then
				k:=k-3;
			end;
			5: begin
				if not(eof(archauto_copia1)) then
				k:=k+3;
			end;
		end;
	end;		
	case aux of
		1: begin
			seek(archauto_copia1,k);
			read(archauto_copia1,rauto2);
			publicacion.usuario := rauto2.usuario;
			publicacion.id := rauto2.id;
			publicacion.marca := rauto2.marca;
			publicacion.producto := rauto2.producto;
			publicacion.precio := rauto2.precio ;									
		    close(ArchAuto_copia1);
		    ComprarPublic(indice,publicacion,comprador,totalusu);
		end;							
		2: begin
			seek(archauto_copia1,k+1);
			read(archauto_copia1,rauto2);
			publicacion.usuario:=rauto2.usuario;
			publicacion.id := rauto2.id;
			publicacion.marca := rauto2.marca;
			publicacion.producto := rauto2.producto;
			publicacion.precio := rauto2.precio;
			close(ArchAuto_copia1);
			ComprarPublic(indice,publicacion,comprador,totalusu);
		end;
		3: begin
			seek(archauto_copia1,k+2);
			read(archauto_copia1,rauto2);
			publicacion.usuario:=rauto2.usuario;
			publicacion.id := rauto2.id;
			publicacion.marca := rauto2.marca;
			publicacion.producto := rauto2.producto;
			publicacion.precio := rauto2.precio;
			close(ArchAuto_copia1);
			ComprarPublic(indice,publicacion,comprador,totalusu);
		end;
	end;
	end;
	close(ArchAuto_copia1);
END;

{Procedimiento MercadoLibre de Bugs | FILTRO AUTOS: antig}
Procedure MenuFiltroAuto_CantPuertas(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
var aux:byte; rautos:t_autos;
 ArchAuto_copia1,ArchAuto_copia2:t_archautos;
BEGIN
	aux:=0;
	assign(ArchAuto_copia1,DataFolder+'ArchAuto_copia1.dat');
	assign(ArchAuto_copia2,DataFolder+'ArchAuto_copia2.dat');
	rewrite(ArchAuto_copia1);
	reset(ArchAuto_copia2);
	writeln('ingrese el numero correspondiente a la cantidad de puertas deseadas:');
	writeln('1)3p');
	writeln('2)4p');
	writeln('3)5p');
	writeln('4)ignorar');
	validarByteIngresado(aux,1,4);
	case aux of
		1:begin	
				while (not(eof(ArchAuto_copia2))) do
				begin
					read(ArchAuto_copia2, rAutos);
					if (rAutos.CantPuertas = 3) then
						write(ArchAuto_copia1, rAutos);
				end;
			end;
		2:begin	
				while (not(eof(ArchAuto_copia2))) do
				begin
					read(ArchAuto_copia2, rAutos);
					if (rAutos.CantPuertas = 4) then
						write(ArchAuto_copia1, rAutos);
				end;
			end;
		3:begin	
				while (not(eof(ArchAuto_copia2))) do
				begin
						read(ArchAuto_copia2, rAutos);
						if (rAutos.CantPuertas = 5) then
							write(ArchAuto_copia1, rAutos);
				end;
			end;
		4:begin	
				while (not(eof(ArchAuto_copia2))) do
				begin
					read(ArchAuto_copia2, rAutos);
					write(ArchAuto_copia1, rAutos);
				end;
			end;
	end;
	close(ArchAuto_copia1);
	close(ArchAuto_copia2);
	MostrarAutosfiltrados(indice, totalusu ,comprador);
END;

{Procedimiento MercadoLibre de Bugs | FILTRO AUTOS: antig}
Procedure MenuFiltroAuto_antig(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	rAutos : t_autos;
	aux : byte;
	aniomin, aniomax : string[4];
	ArchAuto_copia1,ArchAuto_copia2 : t_archautos;
BEGIN
	aux := 0;
	assign(ArchAuto_copia1,DataFolder+'ArchAuto_copia1.dat');
	assign(ArchAuto_copia2,DataFolder+'ArchAuto_copia2.dat');
	reset(ArchAuto_copia1);
	rewrite(ArchAuto_copia2);
	writeln('Desea filtrar las publiaciones segun el anio de fabricacion');
	writeln('del producto?:');
	writeln('1)Si');
	writeln('2)No');
	validarByteIngresado(aux,1,2);
	if (aux = 1) then
	begin
		writeln('Ingrese el anio minimo entre los cuales desea buscar el producto: ');
		readln(aniomin);
		writeln('Ingrese el anio de maximo entre los cuales desea buscar el producto: ');
		readln(aniomax);
		while (not(eof(ArchAuto_copia1))) do
		begin
			read(ArchAuto_copia1, rAutos);
			if ((rAutos.AnoFabricacion < aniomin) and (rautos.AnoFabricacion > aniomax))then
				write(ArchAuto_copia2, rAutos);
		end;
	end
	else if aux = 2 then
	begin
		while (not(eof(ArchAuto_copia1))) do
			begin
			read(ArchAuto_copia1,rAutos);
			write(ArchAuto_copia2,rAutos);
			end;
	end;
	close(ArchAuto_copia1);
	close(ArchAuto_copia2);		
	MenuFiltroAuto_CantPuertas(indice, totalusu ,comprador);
END;

{Procedimiento MercadoLibre de Bugs | FILTRO AUTOS: combustible}
Procedure MenuFiltroCombustible(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	ArchAuto_copia1,ArchAuto_copia2 : t_ArchAutos;
	rAutos : t_Autos;
	aux : byte;
BEGIN
	aux := 0;
	assign(ArchAuto_copia1,DataFolder+'ArchAuto_copia1.dat');
	assign(ArchAuto_copia2,DataFolder+'ArchAuto_copia2.dat');
	rewrite(ArchAuto_copia1);
	reset(ArchAuto_copia2);
	writeln('Tipo de combustible?:');
	writeln('1)Diesel');
	writeln('2)GNC');
	writeln('3)Nafta');
	validarByteIngresado(aux,1,3);
	case aux of
		1 : begin
				while (not(eof(ArchAuto_copia2))) do
				begin
					read(ArchAuto_copia2, rAutos);
					if (rAutos.combustible = 'Diesel') then
						write(ArchAuto_copia1, rAutos);
				end;
			end;
		2:begin
				while not eof(ArchAuto_copia2) do
				begin
					read(ArchAuto_copia2, rAutos);
					if (rAutos.combustible = 'GNC') then
						write(ArchAuto_copia1, rAutos);
				end;
			end;
		3:begin
				while not eof(ArchAuto_copia2) do
				begin
					read(ArchAuto_copia2, rAutos);
					if (rAutos.combustible = 'Nafta') then
						write(ArchAuto_copia1, rAutos);
				end;
			end;
	end;	
	close(ArchAuto_copia1);
	close(ArchAuto_copia2);
	MenuFiltroAuto_Antig(indice, totalusu ,comprador);
end;


{Procedimiento MercadoLibre de Bugs | FILTRO AUTOS: crear archivo}
Procedure Crear_Archivo_Autos();
VAR
 rAuto:t_autos;
 ArchAuto,ArchAuto_copia1{,ArchAuto_copia2}:t_ArchAutos;
BEGIN
	assign(ArchAuto,DataFolder+'ArchAuto.dat');
	reset(ArchAuto);
	assign(ArchAuto_copia1,DataFolder+'ArchAuto_copia1.dat');
	rewrite(ArchAuto_copia1);
	{assign(ArchAuto_copia2,DataFolder+'ArchAuto_copia2.dat');
	rewrite(archauto_copia2);}
	while (not(eof(archauto))) do
		begin
			read(ArchAuto, rAuto);
			if rauto.estadisponible then			
				write(Archauto_copia1, rAuto);
		end;	
	{reset(ArchAuto_copia1);
	while not eof(archauto_copia1) do
		begin
			read(archauto_copia1,rauto);
			write(archauto_copia2,rauto);
		end;}	
	close(ArchAuto);
	close(ArchAuto_copia1);
	//close(ArchAuto_copia2);
END;

{Procedimiento MercadoLibre de Bugs | FILTRO AUTOS: marcas}
Procedure MenuFiltroAuto_Marcas(var indice:tindiceusu;var totalusu:longint; var comprador:tusuario);
VAR
	aux : byte;
	rAutos : t_Autos;
	{ArchAuto , }ArchAuto_copia1, ArchAuto_copia2 : t_ArchAutos;
BEGIN
	aux := 0;
	crear_archivo_autos;
	assign(ArchAuto_copia1,DataFolder+'ArchAuto_copia1.dat');
	assign(ArchAuto_copia2,DataFolder+'ArchAuto_copia2.dat');
	reset(ArchAuto_copia1);
	rewrite(ArchAuto_copia2);
	writeln('Presione el numero correspondiente a la opcion mas acorde al producto que busca:');
	writeln('Marca:');
	writeln('1)Audi');
	writeln('2)Citroen');
	writeln('3)Fiat');
	writeln('4)Ford');
	writeln('5)Mercedes Benz');
	writeln('6)Peugeot');
	writeln('7)Renault');
	writeln('8)Volkswagen');
	writeln('9)Otra');
	validarByteIngresado(aux,1,9);
	case aux of
		1: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if (rAutos.marca = 'Audi') then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
		2: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if (rAutos.marca = 'Citroen') then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
		3: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if rAutos.marca = 'Fiat' then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
		4: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if (rAutos.marca = 'Ford') then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
		5: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if (rAutos.marca = 'Mercedes Benz') then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
		6: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if (rAutos.marca = 'Peugeot') then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
		7: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if (rAutos.marca = 'Renault') then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
		8: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if (rAutos.marca = 'Volkswagen') then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
		9: begin
				while (not(eof(ArchAuto_copia1))) do
				begin
					read(ArchAuto_copia1, rAutos);
					if (rAutos.marca = 'Otra') then
						write(ArchAuto_copia2, rAutos);
				end;
			end;
	end;	
	close(ArchAuto_copia1);
	close(ArchAuto_copia2);
	MenuFiltroCombustible(indice, totalusu ,comprador);
END;

{Procedimiento MercadoLibre de Bugs | VER PUBLICACIONES}
Procedure VerPublic(var Indice : tIndiceUsu; var TotalUsu : longint; var Comprador : tUsuario);
VAR
	aux : byte;
BEGIN
	aux := 0;
	writeln('Presione el numero correspondiente a la opcion mas acorde al producto que busca:');
	writeln('1) Automovil');
	writeln('2) Notebook');
	writeln('3) volver');
	validarByteIngresado(aux,1,3);
	case aux of
	 1: MenuFiltroAuto_marcas(indice, totalusu ,comprador);
	 2: MenuNote_marca(indice, totalusu ,comprador);
	end;
END;

{Procedimiento MercadoLibre de Bugs | MENU PRINCIPAL}
PROCEDURE MenuPrincipal(Usuario : tUsuario;Indice : tIndiceUsu;TotalUsu : longint);
VAR
	OpcMenu : byte;
	MaxOpcion : byte;
BEGIN
	OpcMenu := 0;
	clrscr;
	MensajePrincipal(FechaSistema,Usuario.Usuario);
	IF (Usuario.Usuario = 'Invitado') THEN
	BEGIN
		{verPublicaciones();}
	END
	ELSE
	BEGIN
		MsjTitulo('Menu principal');
		Writeln('1) Ver publicaciones');
		Writeln('2) Agregar nueva publicacion');
		Writeln('3) Configurar cuenta');
	END;
	IF (Usuario.EsAdmin) THEN
	BEGIN
		Writeln('4) Estadisticas');
		MaxOpcion := 4;
	END
	ELSE
		MaxOpcion := 3;	
	Writeln('0) Salir');
	Writeln();
	SeleccionOpcion(OpcMenu,MaxOpcion);
	Case OpcMenu of
	1: 	BEGIN
			VerPublic(Indice,TotalUsu,Usuario);
			MenuPrincipal(Usuario,Indice,TotalUsu);
		END;
	2:	BEGIN
			NuevaPublic(Usuario,Indice,TotalUsu);
			MenuPrincipal(Usuario,Indice,TotalUsu);
		END;
	3:	BEGIN
			ConfigCta(Usuario,Indice,TotalUsu);
			MenuPrincipal(Usuario,Indice,TotalUsu);
		END;
	4:	BEGIN
			{VerEstad();}
		END;
	0:
		BEGIN
			Writeln('Hasta la proxima compra!');
		END;
	END;
	
END;
{Procedimiento MercadoLibre de Bugs | REGISTRO USUARIO}
PROCEDURE RegistroUsuario();
VAR
	auxStr,NuevoUsuario, PassAux1, PassAux2 : String;
	ArchivoDeUsuarios : tArcUsu;
	ArchivoDeSaldos : tArcSaldos;
	EsValido : Boolean;
	ClavesCoinciden : Boolean;
	UnUsuario : tUsuario;
	UnSaldo : tSaldos;
	Indice : tIndiceUsu;
	TotalUsu : longint;
	i : byte;
BEGIN
	ClavesCoinciden := False;
	EsValido := False;
	Assign(ArchivoDeUsuarios, DataFolder + 'ArchUsuarios.dat');
	{$I-}
	Reset(ArchivoDeUsuarios); {Abro el archivo, en caso de no existir, lo creo}
	{$I+}
	If (IOResult <> 0) then Rewrite(ArchivoDeUsuarios);
	Writeln();
	MsjTitulo('Registrate');
	Writeln();
	REPEAT	{Valido los 8 caracteres permitidos}
		REPEAT
			Write('Usuario: ');
			Readln(NuevoUsuario);
			If ValidoLength(NuevoUsuario,MaxLengthUsuario) then
				EsValido := True
			Else
			BEGIN
				EsValido := False;
				Str(MaxLengthUsuario,auxStr);
				MsjError('El usuario ingresado supera los (' + auxStr + ') caracteres permitidos. Por favor, verifique.');
			END;
		UNTIL EsValido;
		EsValido := False;	{Valido que el usuario no exista en la "base de datos"}
		If (UsuarioExiste(ArchivoDeUsuarios, UnUsuario, NuevoUsuario)=False) then
		BEGIN
			EsValido := True;
			TextColor(Verde);
			Writeln('El usuario ingresado es correcto!');
			UnUsuario.Usuario := NuevoUsuario;
			TextColor(Blanco);
		END
		Else
		BEGIN
			EsValido := False;
			MsjError('Ya hay un usuario registrado con ese nombre. Ingrese uno distinto.');
		END;
	UNTIL EsValido;
	Write('Nombre y Apellido: ');
	Readln(UnUsuario.NomyApe);
	Write('E-mail: ');
	Readln(UnUsuario.Mail);
	REPEAT
		REPEAT	{Valido los 8 caracteres permitidos}
			Write('Clave: ');
			Readln(PassAux1);
			If ValidoLength(PassAux1,MaxLengthPass)=True then
				EsValido := True
			Else
			BEGIN
				EsValido := False;
				Str(MaxLengthPass,auxStr);
				MsjError('La clave ingresada supera los (' + auxStr + ') caracteres permitidos. Por favor, verifique.');
			END;
		UNTIL EsValido;
		Write('Repetir Clave: ');
		Readln(PassAux2);
		If (PassAux1=PassAux2) then	{Valido que las dos claves sean iguales}
		BEGIN
			ClavesCoinciden:=True;
			UnUsuario.Pass:=PassAux1;
		END
		Else
		BEGIN
			ClavesCoinciden:=False;
			MsjError('Las claves no coinciden! Por favor, verifique.');
		END;
	UNTIL ClavesCoinciden;
	UnUsuario.EsAdmin := false;
	UnUsuario.Calificacion := 0;
	
	
	{Escribo el archivo de saldos para este usuario}
	Assign(ArchivoDeSaldos, DataFolder + 'ArchSaldos.dat');
	{$I-}
	Reset(ArchivoDeSaldos);
	{$I+}
	If (IOResult <> 0) then Rewrite(ArchivoDeSaldos);
	UnSaldo.Usuario := UnUsuario.Usuario;
	UnSaldo.Saldo := 0;
	For i := 1 to MaxVMovimientosSaldos Do
	Begin
		UnSaldo.Movimientos[i].plata := 0;
		UnSaldo.Movimientos[i].fecha :=  '19000101';
	End;
		
	Seek(ArchivoDeUsuarios,filesize(ArchivoDeUsuarios));
	Write(ArchivoDeUsuarios, UnUsuario); {Escribo usuarios con UnUsuario}
	Seek(ArchivoDeSaldos,filesize(ArchivoDeSaldos));
	Write(ArchivoDeSaldos, UnSaldo); {Escribo saldos con UnSaldo}
	Close(ArchivoDeUsuarios); {Cierro el archivo}
	Close(ArchivoDeSaldos); {Cierro el archivo}
	
	CrearIndiceUsu(Indice,TotalUsu);
	MenuPrincipal(UnUsuario,Indice,TotalUsu);
END;
{Procedimiento MercadoLibre de Bugs | INGRESO INVITADO}
PROCEDURE IngresoInvitado();
VAR
	UsuarioInvitado : tUsuario;
	IndiceVacio : tIndiceUsu;
BEGIN
	UsuarioInvitado.Usuario := 'Invitado';
	UsuarioInvitado.EsAdmin := false;
	IndiceVacio[1].Pos := 0;
	MenuPrincipal(UsuarioInvitado,IndiceVacio,0);
END;
{Procedimiento MercadoLibre de Bugs | INGRESO USUARIO}
PROCEDURE IngresoUsuario();
VAR
	auxStr : string;
	StrPass : string;
	StrUsuario : string;
	auxPos : longint;
	TotalUsu : longint;
	EsValido : boolean;
	Indice : tIndiceUsu;
	Usuario : tUsuario;
	ArchUsu : tArcUsu;
BEGIN
	Assign(ArchUsu, DataFolder + 'ArchUsuarios.dat');
	writeln('');
	MsjTitulo('Ingreso');
	CrearIndiceUsu(Indice,TotalUsu);
	EsValido := false;
	Repeat
		write('Por favor ingrese su nombre de usuario: ');
		readln(StrUsuario);
		If (ValidoLength(StrUsuario,MaxLengthUsuario)) Then
		BEGIN
			auxPos := PosicionUsuarioIndice(StrUsuario,TotalUsu,Indice);
			If (auxPos = -1) Then
				MsjError('El usuario ingresado no existe.')
			Else
				EsValido := true;
		END
		Else
		BEGIN
			Esvalido := false;
			Str(MaxLengthUsuario,auxStr);
			MsjError('El usuario ingresado supera los (' + auxStr + ') caracteres permitidos.');
		END;
	until (EsValido);
	EsValido := false;
	Repeat
		write('Por favor ingrese su contrase',#164,'a: ');
		readln(StrPass);
		If (ValidoLength(StrPass,MaxLengthPass)) Then
			if (not (EsClaveCorrecta(Indice,StrPass,auxPos))) then
			BEGIN
				MsjError('La contrasenia no es correcta.');
				EsValido := false;
			END
			ELSE
				EsValido := true;
	until (EsValido);
	Reset(ArchUsu);
	Seek(ArchUsu,Indice[auxPos].pos);
	Read(ArchUsu,Usuario);
	close(ArchUsu);
	VerificoCalificaciones(false,Usuario,TotalUsu,Indice);
	writeln('6');
	MenuPrincipal(Usuario,Indice,TotalUsu);
END;
{Procedimiento MercadoLibre de Bugs | INGRESO SISTEMA}
PROCEDURE IngresoSistema();
CONST
	MaxOpcion = 3;
VAR
	OpcMenu : Byte;
BEGIN
	OpcMenu := 0;
	MsjTitulo('Ingreso al sistema');
	Writeln();
	Writeln('1) Registrarse');
	Writeln('2) Ingresar como Usuario');
	Writeln('3) Ingresar como Invitado');
	Writeln('0) Salir');
	Writeln();
	SeleccionOpcion(OpcMenu,MaxOpcion);
	Case OpcMenu of
	1: 	BEGIN
			RegistroUsuario();
		END;
	2:	BEGIN
			IngresoUsuario();
		END;
	3:	BEGIN
			IngresoInvitado();
		END;
	0:
		BEGIN
			Writeln('Hasta la proxima compra!');
		END;
	END;
END;
{Programa principal MercadoLibre de Bugs}
BEGIN
	MensajePrincipal('','');
	IngresoFecha(FechaSistema);
	MensajePrincipal(FechaSistema,'');
	IngresoSistema();
END.

