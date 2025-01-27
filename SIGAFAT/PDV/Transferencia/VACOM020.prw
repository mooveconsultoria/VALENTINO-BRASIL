// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : VACOM020
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 16/05/19 | TOTVS | Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} novo
Permite a manutenção de dados armazenados em CB1.

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     16/05/2019
/*/
//------------------------------------------------------------------------------------------
user function VACOM020()
	//--< variáveis >---------------------------------------------------------------------------
	
	//Indica a permissão ou não para a operação (pode-se utilizar 'ExecBlock')
	local cVldAlt := ".T." // Operacao: ALTERACAO
	local cVldExc := ".T." // Operacao: EXCLUSAO
	
	//trabalho/apoio
	local cAlias
	
	//--< procedimentos >-----------------------------------------------------------------------
	cAlias := "CB1"
	chkFile(cAlias)
	dbSelectArea(cAlias)
	//indices
	dbSetOrder(1)
	axCadastro(cAlias, "Cadastro de Operadores", cVldExc, cVldAlt)
	
return
//--< fim de arquivo >----------------------------------------------------------------------
