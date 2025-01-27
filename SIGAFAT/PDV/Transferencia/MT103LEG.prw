// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : MT103LEG
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
User Function MT103LEG
	Local aLegenda	:= aClone(ParamIxb[1])

	aAdd(aLegenda, {"BR_BRANCO" ,"Conferida"})
	aAdd(aLegenda, {"BR_PRETO" ,"Conferida Parcial"})

return(aLegenda)