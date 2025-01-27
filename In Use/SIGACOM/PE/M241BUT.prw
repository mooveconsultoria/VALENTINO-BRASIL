#include "protheus.ch"
#include "topconn.ch"
#Include "Rwmake.ch"

User Function M241BUT( )

Local aButtons := {}

aAdd(aButtons , {'AUTOM', { || ImpMovIntII() }, OemtoAnsi('Importar')})

Return(aButtons)

Static Function ImpMovIntII()
Local cAlias   := Alias()
Local aArea    := GetArea()
Local oDlgOp   := Nil
Local lOk      := .T.

Local cNomeArq	 := ""
Local pD3Cod 	 := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_COD    "})
Local pD3OP		 := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_OP     "})
Local pD3UM		 := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_UM     "})
Local pD3Arm	 := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_LOCAL  "})
Local pD3Quant   := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_QUANT  "})
Local pD3Custo   := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_CUSTO1 "})
Local pD3QtSegUm := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_QTSEGUM"})
//Private aGets    := {}
//Private aTela    := {}
//Private lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)
//?Verifica se trabalha com segunda unidade de medida           ?
Private lUsaSegUm   := .T.
Private nPosQtSegUm := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_QTSEGUM"})
Private nPosQuant   := aScan(aHeader, {| aVet | PadR(aVet[2], 10) == "D3_QUANT  "})

DBSelectArea("SX3")
DBSetOrder(2)
DBSeek("B1_SEGUM")
If !X3USO(X3_USADO)
	DBSeek("B2_QTSEGUM")
	If !X3USO(X3_USADO)
		lUsaSegUm := .F.
	EndIf
EndIf
DBSetOrder(1)
DBSelectArea(cAlias)


RegToMemory("SD3", .T., .T., .T.)

If lOk
	If (select('TMOV') > 0)
		TMOV->( dbCloseArea() )
	EndIf
	
	//dbUseArea(.T.,,"\importar\MOV.dbf","TMOV",.T.,.F.)
	dbUseArea(.T.,,"\importar\MOV.dtc","TMOV",.T.,.F.)
	
	TMOV->(dbGoTop())
	
	aColsOld  := aClone(aCols)
	aCols 	 := {}
	
	Do While TMOV->(!Eof())
		
		cProduto := (Alltrim(TMOV->PRODUTO)+Space(tamsx3("D3_COD")[1]-Len(Alltrim(TMOV->PRODUTO))))
		
        DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cProduto)
		If !Found()
            Alert("Produto: "+cProduto+", Nao Existe!")
			TMOV->(DBSkip())
		    Loop
		EndIf
		
		DbSelectArea("SB2")
		DbSetOrder(1)
		DBSeek(xFilial("SB2") + cProduto + SB1->B1_LOCPAD)
		If !Found()
			RECLOCK('SB2',.T.)
			SB2->B2_FILIAL := xFilial("SB2")
			SB2->B2_COD		:= cProduto
			SB2->B2_LOCAL	:= SB1->B1_LOCPAD
			SB2->(MSUNLOCK())
		EndIf
		
		
		aAdd(aCols, aClone(aColsOld[1]))
		
		aCols[Len(aCols), pD3Cod	] := cProduto
		aCols[Len(aCols), pD3UM     ] := SB1->B1_UM
		aCols[Len(aCols), pD3Quant  ] := TMOV->QUANT
		//aCols[Len(aCols), pD3OP		] := Alltrim(TMOV->OP)
		aCols[Len(aCols), pD3Arm    ] := SB1->B1_LOCPAD
		aCols[Len(aCols), pD3QtSegUm] := ConvUm(cProduto, TMOV->QUANT, 0, 2)
		aCols[Len(aCols), pD3Custo]   := TMOV->CUSTO
		aCols[Len(aCols), Len(aHeader) + 1] := .F.
		
		TMOV->(DBSkip())
	EndDo
	TMOV->(DBCloseArea())
EndIf

oGet:SetArray(aCols)
oGet:oBrowse:Refresh()

RestArea(aArea)
DBSelectArea(cAlias)
Return(Nil)