#Include "Protheus.ch"
#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SF2460I  ºAutor  ³Microsiga           º Data ³  29/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada apos a gravacao do documento de saida     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SF2460I()

Local aArea			:= GetArea()
Local aAreaSB1 		:= SB1->(GetArea())
Local aCabec     	:= {}
Local aLinha		:= {}
Local aItens 		:= {}
Local cFilAtu		:= cFilAnt
Local cFilDestino	:= ""
Local nTamItem 		:= TamSX3('D1_ITEM')[1]
Local cItem			:= StrZero( 1 , nTamItem )
Local cCondPg		:= GetMv("MV_CONDPAD")
Local cQryD2		:= ""
Local qTMP          := GetNextAlias()

Private cNota  		:= SF2->F2_DOC
Private cSerie 		:= SF2->F2_SERIE
Private cCliente  	:= SF2->F2_CLIENTE
Private cLoja 	  	:= SF2->F2_LOJA
Private lMsErroAuto := .F.
Private lMostraErro	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nota Normal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
If (SF2->F2_TIPO <> "N")
	RestArea(aArea)
	Return
EndIf

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja ))
cFilDestino := SA1->A1_01IDLOJ

SA2->(DbOrderNickName("SYVA00403"))
SA2->(DbSeek(xFilial("SA2") + cFilAtu )) // A filial logada vira o fornecedor na nota de entrada da outra filial

//SD2->( dbSetOrder(3) )//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
//SD2->( dbSeek(xFilial("SD2")+cNota+cSerie+cCliente+cLoja) )

cQryD2 := retQrySD2(cNota,cSerie,cCliente,cLoja)

TCQuery cQryD2 New Alias &qTMP


// Verifica se e uma transferencia.
SC5->(DbSetOrder(1))
IF SC5->(DbSeek(xFilial("SC5")+(qTMP)->D2_PEDIDO))
	If Empty(SC5->C5_01OST)
		RestArea(aArea)
		Return( .T. )
	Endif
Endif

//Parametro para informar se deve gerar a pre-nota automatica, caso seja falso usar a rotina SYVM002.
If GetMv("MV_01GPNFE",,.T.)
	
	//Atualiza o campo para controle do semaforo.
	RecLock("SF2",.F.)
	SF2->F2_01OST := SC5->C5_01OST+cCliente+cNota+cSerie
	Msunlock()
	
	// Cabecalho da nota fiscal de entrada
	aCabec := {}
	aadd(aCabec,{"F1_TIPO"   	,"N"})
	aadd(aCabec,{"F1_FORMUL" 	,"N"})
	aadd(aCabec,{"F1_DOC"    	,cNota})
	aadd(aCabec,{"F1_SERIE"  	,cSerie})
	aadd(aCabec,{"F1_EMISSAO"	,SF2->F2_EMISSAO})
	aadd(aCabec,{"F1_FORNECE"	,SA2->A2_COD})
	aadd(aCabec,{"F1_LOJA"		,SA2->A2_LOJA})
	aadd(aCabec,{"F1_ESPECIE"	,"SPED"})
	aadd(aCabec,{"F1_COND"		,cCondPg})
	aadd(aCabec,{"F1_EST"		,SA2->A2_EST})
	
	//While SD2->( !Eof() .And. xFilial("SD2")+cNota+cSerie+cCliente+cLoja == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) )
	While (qTMP)->( !Eof() .And. xFilial("SD2")+cNota+cSerie+cCliente+cLoja == (qTMP)->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) )
		
		aLinha := {}
		
		aadd(aLinha,{"D1_ITEM"		,cItem									,Nil})
		aadd(aLinha,{"D1_COD"		,(qTMP)->D2_COD							,"AlwaysTrue()"})
		aadd(aLinha,{"D1_UM"		,(qTMP)->D2_UM							,"AlwaysTrue()"})
		aadd(aLinha,{"D1_QUANT"		,(qTMP)->D2_QUANT						,Nil})
		aadd(aLinha,{"D1_VUNIT"		,(qTMP)->D2_PRCVEN						,Nil})
		aadd(aLinha,{"D1_TOTAL"		,(qTMP)->D2_TOTAL						,Nil})
		aadd(aLinha,{"D1_LOCAL"		,(qTMP)->D2_LOCAL						,Nil})
		
		If SD1->(FieldPos("D1_DESCR")) > 0 .And. SD1->(FieldPos("D1_POSIPI")) > 0
			DbSelectArea("SB1")
			DbSetOrder(1) // B1_FILIAL+B1_COD
			If DbSeek(xFilial("SB1")+(qTMP)->D2_COD)
				aadd(aLinha,{"D1_DESCR"		,SB1->B1_DESC						,"AlwaysTrue()"})
				aadd(aLinha,{"D1_POSIPI"	,SB1->B1_POSIPI						,"AlwaysTrue()"})
			EndIf
		EndIf
		
		cItem := Soma1(cItem,nTamItem)
		
		aadd(aItens,aLinha)
		
		(qTMP)->(DbSkip())
	EndDo
	(qTMP)->(dbCloseArea())
	// Caso tenha itens e cabecalho definidos
	If Len(aItens) > 0 .And. Len(aCabec) > 0
		
		// Atualiza para a filial destino
		cFilant:=cFilDestino
		
		// Reinicializa ambiente para o fiscal
		If MaFisFound()
			MaFisEnd()
		EndIf
		
		LjMsgRun('Por favor Aguarde, gerando pré nota de entrada.' , , { || MATA140(aCabec,aItens,3) } )
		
		// Checa erro de rotina automatica
		If lMsErroAuto
			lMostraErro	:=.T.
		EndIf
		
		// Atualiza para a filial origem
		cFilant:=cFilAtu
		
	EndIf
	
	//Mostra o erro
	If lMostraErro
		RecLock("SF2",.F.)
		SF2->F2_01OST := ""
		Msunlock()
		
		MostraErro()
	Else
		//Atualiza o campo com os dados da transferencia.
		RecLock("SF1",.F.)
		SF1->F1_01OST := SC5->C5_01OST+cFilant+cNota+cSerie
		Msunlock()
	Endif
		
Endif

RestArea(aAreaSB1)
RestArea(aArea)

Return( .T. )


//Matheus 27/05/2020
static function retQrySD2(cNota,cSerie,cCliente,cLoja)
local cRet := ""
	
cRet := "SELECT "
cRet += "	* "
cRet += "FROM "
cRet += "	" + retSqlName("SD2") + " SD2 "
cRet += "WHERE "
cRet += "	D2_FILIAL = '" + xFilial("SD2") + "' AND "
cRet += "	D2_DOC = '" + cNota + "' AND "
cRet += "	D2_SERIE = '" + cSerie + "' AND "
cRet += "	D2_CLIENTE = '" + cCliente + "' AND "
cRet += "	D2_LOJA = '" + cLoja + "' AND "
cRet += "	D_E_L_E_T_ <> '*' "
cRet += " ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM,D2_COD "
	
return cRet
