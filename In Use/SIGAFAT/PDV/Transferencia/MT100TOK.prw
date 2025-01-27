// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : MT100TOK
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 20/08/19 | TOTVS | Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} novo
Montagem da tela de processamento

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     20/08/2019
/*/
//------------------------------------------------------------------------------------------
User Function MT100TOK()

Local aArea 	:= GetArea()
Local cCFOP 	:= GetMv("VA_CONFCFO",,"1152|2152|1409|2409")
Local nPosCF	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_CF"})
Local nX		:= 0
Local lRet 		:= .T.
/*
DbSelectArea("SF1")
DbSetOrder(1)  
If DbSeek(xFilial("SF1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO))
	
	If cTipo == 'N'  .And. !Upper(Alltrim(Funname()))=='MATA920'
		
		For nX := 1 To Len(aCols)
			
			if ( Alltrim(aCols[nX][nPosCF]) $ cCFOP)
				
				If DbSeek(xFilial("SF1")+cNFiscal+cSerie+cA100For+cLoja)
					
					IF EMPTY(SF1->F1_XCONF)
						MsgInfo("Necessário efetuar a conferencia cega.","Atenção")
						lRet := .F.
						Exit
					endif
					
				Else
					
					MsgInfo("Necessário efetuar a conferencia cega.","Atenção")
					lRet := .F.
					Exit
				EndIf
				
			EndIF
			
		Next
		
	EndIf
	RestArea(aArea)
EndIF              
*/
return(lRet)
