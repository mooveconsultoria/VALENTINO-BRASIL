#include "protheus.ch"
#include "topconn.ch

User Function VisualMenu() //CONSULTA NO MENU

DbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	SF2->(dbSeek(xFilial("SF2")+SL1->L1_DOC+SL1->L1_SERIE))
	Mc090Visual("SF2",SF2->(RecNo()),1)  
                             
Return 