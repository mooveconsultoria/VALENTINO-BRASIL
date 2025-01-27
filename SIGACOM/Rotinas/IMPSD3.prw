User Function IMPSD3()

local cDir
local cArq

Processa( {|| U_IMPD3() }, "Aguarde...", "Realizado importação!",.F.)

return

User Function IMPD3()
 
Local cLinha   := ""
Local lPrim    := .T.
Local aCampos  := {}
Local aDados   := {}
Local xAutoDad := {}
Local _PosVal  := 0
Local _PosQtd  := 0
Local x        := 0 
Local _Emissao 
Private cArqTxt   := cGetFile("Arquivos CSV|*.CSV|Todos os Arquivos|*.*",OemToAnsi("Acertos..."),,,.T.,GETF_LOCALHARD)
Private aErro := {}
private lBloq := .F.
 
//If !File(cDir+cArq)
If !File(cArqTxt)
	MsgStop("O arquivo " +cArqTxt+ " não foi encontrado. A importação será abortada!","- ATENCAO")
	Return
EndIf

*---------------------*
* Abre o Arquivo Texto   *
*---------------------*
FT_FUSE(cArqTxt) 
//FT_FUSE(cDir+cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
	
	IncProc("Lendo arquivo texto...")
 
	cLinha := FT_FREADLN()
 
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
	FT_FSKIP()
EndDo

ProcRegua(Len(aDados))

For y := 1 to Len(aDados)	
  	xAutoDad := {}      

	IncProc("Aplicando o execauto...")

	AADD(xAutoDad,{"D3_EMISSAO" , ddatabase , Nil})	
	For z := 1 to Len(aCampos)
		If aDados[y][z] <> ""
			AADD(xAutoDad,{aCampos[z] , aDados[y,z] , Nil}) 
		EndIf	
	Next z                                              

	_PosCOD := aScan(xAutoDad,{|x| x[1] == "D3_COD" })
	_PosVal := aScan(xAutoDad,{|x| x[1] == "D3_CUSTO1" })
	_PosQtd := aScan(xAutoDad,{|x| x[1] == "D3_QUANT" })
		
	If _PosVal <> 0 
		xAutoDad[_PosVal][2] := Val(STRTRAN(xAutoDad[_PosVal][2],",","."))
	EndIf
	If _PosQtd <> 0 
		xAutoDad[_PosQtd][2] := Val(STRTRAN(xAutoDad[_PosQtd][2],",",".")  )
	EndIf

    DbSelectArea("SB1")
    DbSetOrder(1)
    DbSeek(xFilial("SB1")+xAutoDad[_PosCOD][2])
    If SB1->B1_MSBLQL == '1'
       Reclock("SB1",.F.)
       SB1->B1_MSBLQL := '2'
       MsUnlock()
       lBloq := .T.
    EndIf 
	lMsErroAuto := .F.

	MSExecAuto({|x,y| mata240(x,y)},xAutoDad,3) //Inclusao
	If lMsErroAuto
		DisarmTransaction() 
		MostraErro()
	EndIf 
	If lBloq
	   DbSeek(xFilial("SB1")+xAutoDad[_PosCOD][2])
       Reclock("SB1",.F.)
       SB1->B1_MSBLQL := '1'
       MsUnlock()
       lBloq := .F.
    EndIf 
Next y	

FT_FUSE()
 
ApMsgInfo("Importação de movimentos concluída!","[IMPSD3]")
 
Return