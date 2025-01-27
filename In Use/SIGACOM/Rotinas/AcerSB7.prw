#Include "PROTHEUS.CH"
#include "rwmake.ch"
///////////////////////
User Function AcerSB7()
///////////////////////
//

If MsgBox("Tem certeza que deseja incluir Inventário Zerado para os produtos que não constam no Inventário?","Confirma?","YesNo")
	Processa({|| AcSB7()},"Acerto de Inventário")
EndIf

Return

/////////////////////
Static Function AcSB7
/////////////////////

Private _nCont := 0
Private _dDatInv := "20180731"

DbSelectArea("SB7")
DbSetOrder(1)  //B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE

DbSelectArea("SB2")
DbSetOrder(1)  //B2_FILIAL+B2_COD+B2_LOCAL
Do While SB2->(!Eof())
	
	IncProc()
	
	If SB2->B2_LOCAL == "01" // .AND. Rtrim(SB2->B2_COD) = "254-50.0001" //
	
		DbSelectArea("SB7")
		DbSetOrder(1)
		DbSeek(SB2->B2_FILIAL+_dDatInv+SB2->B2_COD+SB2->B2_LOCAL,.F.)
		If !Found() .and. SB2->B2_QATU <> 0
	
			DbSelectArea("SB7")
			RecLock("SB7",.T.)
			SB7->B7_FILIAL  := SB2->B2_FILIAL
			SB7->B7_COD     := SB2->B2_COD
			SB7->B7_LOCAL   := SB2->B2_LOCAL
			SB7->B7_TIPO    := Posicione("SB1",1,xFilial("SB1")+SB2->B2_COD,"B1_TIPO")
			SB7->B7_DOC     := "ZERADO"
			SB7->B7_QUANT   := 0
			SB7->B7_DATA    := SToD("20180731") // _dDatInv)
			SB7->B7_DTVALID := ddatabase // SToD("31/08/2010")
			SB7->B7_ORIGEM 	:= "MATA270"
			SB7->B7_STATUS 	:= "1"
			MsUnLock()
			_nCont++
			
		EndIf
		
	EndIf
	
	DbSelectArea("SB2")
	DbSkip()
	
EndDo

Alert("Acerto no Inventário Finalizado!"+Chr(13)+"Registros Atualizados: "+Str(_nCont,9))

Return