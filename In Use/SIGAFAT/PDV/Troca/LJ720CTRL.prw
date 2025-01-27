#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} LJ720CTRL
Ponto de entrada para controle de Objetos da Tela de Troca.
@type    Function
@author  Douglas Telles
@since   01/07/2018
@version P12 V1.17
/*/
User Function LJ720CTRL()
	Local aRet		:= ParamIXB
	Local nOpcProc	:= SuperGetMv("AS_LJ720A1", .F., 2)
	Local lAltProc	:= SuperGetMv("AS_LJ720A2", .F., .T.)
	Local nOpcOrig	:= SuperGetMv("AS_LJ720B1", .F., 1)
	Local lAltOrig	:= SuperGetMv("AS_LJ720B2", .F., .T.)
	Local nOpcBusc	:= SuperGetMv("AS_LJ720C1", .F., 2)
	Local lAltBusc	:= SuperGetMv("AS_LJ720C2", .F., .T.)

	//-------------------------
	//Radio Button "Processo"
	//-------------------------
	aRet[1][2] := nOpcProc //1=Troca; 2=Devolução
	aRet[1][3] := lAltProc //.T.=Permite editar, .F.=Não permite editar

	//-------------------------
	//Radio Button "Origem"
	//-------------------------
	aRet[2][2] := nOpcOrig //1=Com Documento de Entrada; 2=Sem Documento de Entrada
	aRet[2][3] := lAltOrig //.T.=Permite editar, .F.=Não permite editar

	//-------------------------
	//Radio Button "Buscar Venda Por"
	//-------------------------
	aRet[3][2] := nOpcBusc //1=Cliente e Data; 2=No. Cupom / Nota; 3=Vale-Troca
	aRet[3][3] := lAltBusc //.T.=Permite editar, .F.=Não permite editar

	//-------------------------
	//Consulta Padrao Cliente
	//-------------------------
	//aRet[4][2] := "XXX" //Consulta Padrão do Cliente (deve existir no SXB)
	//aRet[4][3] := .T. //.T.=Permite editar, .F.=Não permite editar
Return aRet
