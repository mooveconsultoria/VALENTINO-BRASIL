#INCLUDE "PROTHEUS.CH"

/*
{Protheus.doc} LJ7002
Ponto de Entrada chamado depois da gravação de todos os dados 
e da impressão do cupom fiscal na Venda Assistida e após o processamento do Job LjGrvBatch(FRONT LOJA).
@author 		Luciano.Braga
@version V12
@since   04/2023
*/

User Function LJ7002()

	Local aArea 	:= GetArea()
	Local cCliente	:= SL1->L1_CLIENTE
	Local cLoja		:= SL1->L1_LOJA
	Local cDoc		:= SL1->L1_DOC
	Local cSerie    := SL1->L1_SERIE
    
    Private nTipo		:= paramixb[1] // 1 - orçamento   2 - cupom  3-nota
    
	dbselectArea("SF2")
	dbSetOrder(1)
	if SF2->(dbSeek(xFilial("SF2")+cDoc+cSerie+cCliente+cloja))
		RecLock("SF2", .F.)
		    SF2->F2_ZZPEDCL:= SL1->L1_ZZPEDCL
		    dbCommit()
		MsUnlock()
	endif

	
	RestArea(aArea)
    	
Return()
